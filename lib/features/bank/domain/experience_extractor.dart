import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';

class ExtractedQuestionDraft {
  const ExtractedQuestionDraft({
    required this.title,
    required this.role,
    required this.level,
    required this.difficulty,
    required this.topics,
    required this.keyPoints,
    this.followups = const <String>[],
    this.evidence = '',
  });

  final String title;
  final String role;
  final String level;
  final int difficulty;
  final List<String> topics;
  final List<String> keyPoints;
  final List<String> followups;
  final String evidence;

  Question toQuestion() {
    final normalized = title.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final hash = sha256
        .convert(utf8.encode(normalized))
        .toString()
        .substring(0, 10);
    return Question(
      id: 'exp-$hash',
      bankVersion: 'experience-import',
      title: title,
      bodyMarkdown: title,
      topics: topics,
      role: role,
      level: switch (level) {
        'junior' => 1,
        'senior' => 4,
        'staff' => 5,
        _ => 3,
      },
      difficulty: difficulty.clamp(1, 5),
      type: QuestionType.knowledge,
      answer: QuestionAnswer(
        summary: keyPoints.join('；'),
        keyPoints: keyPoints,
      ),
      followups: followups,
      status: QuestionStatus.user,
      updatedAt: DateTime.now(),
    );
  }
}

/// T-022：面经文本 → 题目草稿（人工确认后入库）。
class ExperienceExtractor {
  ExperienceExtractor({
    required this.client,
    required this.prompts,
    required this.model,
    this.maxQuestions = 8,
  });

  final LlmClient client;
  final PromptRegistry prompts;
  final String model;
  final int maxQuestions;

  Future<List<ExtractedQuestionDraft>> extract(
    String experienceText, {
    CancelToken? cancel,
  }) async {
    if (experienceText.trim().isEmpty) return const <ExtractedQuestionDraft>[];
    final template = prompts.require('experience.extract');
    final prompt = template.render(<String, String>{
      'experienceText': experienceText,
    });
    final buffer = StringBuffer();
    await for (final delta in client.chat(
      ChatRequest(
        model: model,
        messages: <ChatMessage>[ChatMessage.system(prompt)],
        temperature: template.temperature,
        maxTokens: 1800,
        forceJson: true,
      ),
      cancel: cancel,
    )) {
      if (delta is LlmTextDelta) buffer.write(delta.text);
      if (delta is LlmDoneDelta) break;
    }
    return _parse(buffer.toString(), experienceText);
  }

  List<ExtractedQuestionDraft> _parse(String raw, String source) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return const <ExtractedQuestionDraft>[];
    try {
      final decoded = jsonDecode(raw.substring(start, end + 1));
      if (decoded is! Map<String, dynamic>) {
        return const <ExtractedQuestionDraft>[];
      }
      final list = decoded['questions'];
      if (list is! List) return const <ExtractedQuestionDraft>[];
      final normalizedSource = _normalize(source);
      final drafts = <ExtractedQuestionDraft>[];
      final seen = <String>{};
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final title = item['title']?.toString().trim() ?? '';
        final evidence = item['evidence']?.toString().trim() ?? '';
        final keyPoints = _strings(item['keyPoints']);
        if (title.isEmpty || keyPoints.isEmpty) continue;
        // 证据必须逐字来自面经，防止模型编题。
        if (evidence.isEmpty ||
            !normalizedSource.contains(_normalize(evidence))) {
          continue;
        }
        final key = _normalize(title);
        if (!seen.add(key)) continue;
        final role = _oneOf(item['role'], const <String>{
          'backend',
          'frontend',
          'algorithm',
        }, 'backend');
        final level = _oneOf(item['level'], const <String>{
          'junior',
          'mid',
          'senior',
          'staff',
        }, 'mid');
        final difficulty = ((item['difficulty'] as num?)?.toInt() ?? 3).clamp(
          1,
          5,
        );
        final topics = _strings(item['topics']);
        drafts.add(
          ExtractedQuestionDraft(
            title: title,
            role: role,
            level: level,
            difficulty: difficulty,
            topics: topics.isEmpty ? <String>[role] : topics,
            keyPoints: keyPoints,
            followups: _strings(item['followups']),
            evidence: evidence,
          ),
        );
        if (drafts.length >= maxQuestions) break;
      }
      return drafts;
    } on FormatException {
      return const <ExtractedQuestionDraft>[];
    }
  }

  List<String> _strings(Object? value) =>
      (value as List<Object?>? ?? const <Object?>[])
          .map((Object? item) => '$item'.trim())
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);

  String _oneOf(Object? value, Set<String> allowed, String fallback) {
    final text = value?.toString() ?? '';
    return allowed.contains(text) ? text : fallback;
  }

  String _normalize(String value) => value.replaceAll(RegExp(r'\s+'), '');
}
