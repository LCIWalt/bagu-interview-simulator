import 'dart:async';
import 'dart:convert';

import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';

/// 评分官（T-033）：评分点三态、证据校验、事实错误、JSON 重试/降级。
///
/// 关键约束（指南 §7.3.2）：
/// - 覆盖率只看命中，不看字数；
/// - 证据必须逐字来自回答，否则该点判 miss；
/// - 事实错误只接受引用自回答的条目，并按 0.5/条扣 correctness；
/// - JSON 解析失败重试 1 次，仍失败则返回 `degraded` 结果。
class ScoringEngine {
  ScoringEngine({
    required this.client,
    required this.prompts,
    required this.model,
    this.maxAttempts = 2,
    this.maxAnswerChars = 12000,
    this.maxTokens = 1600,
  });

  final LlmClient client;
  final PromptRegistry prompts;
  final String model;
  final int maxAttempts;
  final int maxAnswerChars;
  final int maxTokens;

  Future<TurnScore> score({
    required Question question,
    required String answerText,
    int followupDepth = 0,
    CancelToken? cancel,
  }) async {
    final template = prompts.require('scorer.rubric');
    final prompt = template.render(<String, String>{
      'questionTitle': question.title,
      'keyPoints': _numbered(question.answer.keyPoints),
      'pitfalls': question.answer.pitfalls.isEmpty
          ? '（无）'
          : question.answer.pitfalls.map((String p) => '- $p').join('\n'),
      'answerText': _truncate(answerText, maxAnswerChars),
      'followupDepth': '$followupDepth',
    });

    final request = ChatRequest(
      model: model,
      messages: <ChatMessage>[ChatMessage.system(prompt)],
      temperature: template.temperature,
      maxTokens: maxTokens,
      forceJson: true,
    );

    String? lastRaw;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      cancel?.throwIfCancelled();
      final buffer = StringBuffer();
      await for (final delta in client.chat(request, cancel: cancel)) {
        if (delta is LlmTextDelta) buffer.write(delta.text);
        if (delta is LlmDoneDelta) break;
      }
      final raw = buffer.toString();
      lastRaw = raw;
      try {
        return _parse(raw, question, answerText);
      } on ParseFailure {
        if (attempt + 1 >= maxAttempts) break;
      }
    }
    return _degraded(lastRaw ?? '');
  }

  TurnScore _parse(String raw, Question question, String answerText) {
    final json = _decodeObject(raw);
    final points = _parsePoints(json['points'], question, answerText);

    final effective = points
        .where((TurnScorePoint point) => point.verdict != 'not_asked')
        .toList(growable: false);
    final hits = effective
        .where((TurnScorePoint p) => p.verdict == 'hit')
        .length;
    final partials = effective
        .where((TurnScorePoint p) => p.verdict == 'partial')
        .length;
    final coverage = effective.isEmpty
        ? 0.0
        : (hits + 0.5 * partials) / effective.length;

    final factualErrors = _parseErrors(json['factualErrors'], answerText);
    final modelCorrectness = _readScore(json['correctness']);
    final modelDepth = _readScore(json['depth']);
    final modelStructure = _readScore(json['structure']);

    // 与覆盖率相乘后取低者；每个事实错误扣 0.5（上限 2.5）。
    final coverageCeiling = 1 + 4 * coverage;
    final penalty = (factualErrors.length * 0.5).clamp(0.0, 2.5);
    final correctness =
        (modelCorrectness < coverageCeiling
            ? modelCorrectness
            : coverageCeiling) -
        penalty;
    return TurnScore(
      correctness: correctness.clamp(1, 5).toDouble(),
      depth: modelDepth.clamp(1, 5).toDouble(),
      structure: modelStructure.clamp(1, 5).toDouble(),
      coverage: coverage,
      points: points,
      factualErrors: factualErrors,
      comment: json['comment']?.toString().trim() ?? '',
    );
  }

  List<TurnScorePoint> _parsePoints(
    Object? raw,
    Question question,
    String answerText,
  ) {
    if (raw is! List) throw const ParseFailure('points must be an array');
    final byPoint = <String, Map<String, dynamic>>{};
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final point = item['point']?.toString();
      if (point == null || point.trim().isEmpty) continue;
      byPoint[_normalize(point)] = item;
    }

    return question.answer.keyPoints
        .map((String point) {
          final item = byPoint[_normalize(point)];
          if (item == null) {
            return TurnScorePoint(point: point, verdict: 'miss');
          }
          final rawVerdict =
              item['verdict']?.toString().toLowerCase() ?? 'miss';
          var verdict =
              <String>{
                'hit',
                'partial',
                'miss',
                'not_asked',
              }.contains(rawVerdict)
              ? rawVerdict
              : 'miss';
          final evidence = item['evidence']?.toString().trim() ?? '';
          if (verdict == 'hit' || verdict == 'partial') {
            if (evidence.isEmpty || !_containsEvidence(answerText, evidence)) {
              // 无证据不给分。
              verdict = 'miss';
            }
          }
          return TurnScorePoint(
            point: point,
            verdict: verdict,
            evidence: verdict == 'hit' || verdict == 'partial' ? evidence : '',
          );
        })
        .toList(growable: false);
  }

  List<FactualError> _parseErrors(Object? raw, String answerText) {
    if (raw is! List) return const <FactualError>[];
    final errors = <FactualError>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final quote = item['quote']?.toString().trim() ?? '';
      final issue = item['issue']?.toString().trim() ?? '';
      if (quote.isEmpty || issue.isEmpty) continue;
      // 引用必须来自回答，防止评分官编造。
      if (!_containsEvidence(answerText, quote)) continue;
      final sources = (item['sources'] as List<Object?>? ?? const <Object?>[])
          .map((Object? source) => '$source')
          .toList(growable: false);
      errors.add(FactualError(quote: quote, issue: issue, sources: sources));
    }
    return errors;
  }

  Map<String, dynamic> _decodeObject(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      final firstNewline = text.indexOf('\n');
      final lastFence = text.lastIndexOf('```');
      if (firstNewline >= 0 && lastFence > firstNewline) {
        text = text.substring(firstNewline + 1, lastFence).trim();
      }
    }
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw const ParseFailure('scorer output has no JSON object');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(text.substring(start, end + 1));
    } on FormatException catch (error) {
      throw ParseFailure('invalid scorer JSON', cause: error);
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ParseFailure('scorer JSON must be an object');
    }
    return decoded;
  }

  double _readScore(Object? raw) {
    final value = raw is num ? raw.toDouble() : double.tryParse('${raw ?? ''}');
    if (value == null) {
      throw const ParseFailure('missing correctness/depth/structure');
    }
    return value;
  }

  TurnScore _degraded(String raw) {
    return TurnScore(
      correctness: 0,
      depth: 0,
      structure: 0,
      coverage: 0,
      degraded: true,
      comment: _truncate(raw, 2000),
    );
  }

  static String _numbered(List<String> keyPoints) {
    var index = 0;
    return keyPoints.map((String point) => '${++index}. $point').join('\n');
  }

  static bool _containsEvidence(String answer, String evidence) {
    final normalizedAnswer = _normalize(answer);
    final normalizedEvidence = _normalize(evidence);
    return normalizedEvidence.isNotEmpty &&
        normalizedAnswer.contains(normalizedEvidence);
  }

  static String _normalize(String value) => value
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'[，。；：、,.;:]'), '');

  static String _truncate(String value, int max) =>
      value.length <= max ? value : '${value.substring(0, max)}…[truncated]';
}
