import 'dart:convert';

import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';

class ExtractedClaim {
  const ExtractedClaim({
    required this.text,
    required this.risk,
    this.reasons = const <String>[],
    this.queries = const <String>[],
  });

  final String text;

  /// `high` / `low`
  final String risk;
  final List<String> reasons;
  final List<String> queries;

  bool get isHighRisk => risk == 'high';
}

/// 断言抽取 + 风险分级（T-052）。只保留可证伪且高风险时才进入核查。
class ClaimExtractor {
  ClaimExtractor({
    required this.client,
    required this.prompts,
    required this.model,
    this.maxClaims = 8,
  });

  final LlmClient client;
  final PromptRegistry prompts;
  final String model;
  final int maxClaims;

  Future<List<ExtractedClaim>> extract({
    required String answerText,
    CancelToken? cancel,
  }) async {
    if (answerText.trim().isEmpty) return const <ExtractedClaim>[];
    final template = prompts.require('claim.extract');
    final prompt = template.render(<String, String>{'answerText': answerText});
    final buffer = StringBuffer();
    await for (final delta in client.chat(
      ChatRequest(
        model: model,
        messages: <ChatMessage>[ChatMessage.system(prompt)],
        temperature: template.temperature,
        maxTokens: 800,
        forceJson: true,
      ),
      cancel: cancel,
    )) {
      if (delta is LlmTextDelta) buffer.write(delta.text);
      if (delta is LlmDoneDelta) break;
    }
    final parsed = _parse(buffer.toString(), answerText);
    return parsed.take(maxClaims).toList(growable: false);
  }

  List<ExtractedClaim> _parse(String raw, String answerText) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return const <ExtractedClaim>[];
    try {
      final decoded = jsonDecode(raw.substring(start, end + 1));
      if (decoded is! Map<String, dynamic>) return const <ExtractedClaim>[];
      final claims = decoded['claims'];
      if (claims is! List) return const <ExtractedClaim>[];
      final result = <ExtractedClaim>[];
      for (final item in claims) {
        if (item is! Map<String, dynamic>) continue;
        final text = item['text']?.toString().trim() ?? '';
        if (text.isEmpty) continue;
        // 引用必须来自回答，防止编造断言。
        if (!_normalize(answerText).contains(_normalize(text))) continue;
        var risk = item['risk']?.toString().toLowerCase() ?? 'low';
        final reasons = (item['reasons'] as List<Object?>? ?? const <Object?>[])
            .map((Object? reason) => '$reason')
            .toList(growable: false);
        final queries = (item['queries'] as List<Object?>? ?? const <Object?>[])
            .map((Object? query) => '$query'.trim())
            .where((String query) => query.isNotEmpty)
            .toList(growable: false);
        if (risk != 'high') {
          risk = _heuristicRisk(text, reasons) ? 'high' : 'low';
        }
        result.add(
          ExtractedClaim(
            text: text,
            risk: risk,
            reasons: reasons,
            queries: queries,
          ),
        );
      }
      return result;
    } on FormatException {
      return const <ExtractedClaim>[];
    }
  }

  bool _heuristicRisk(String text, List<String> reasons) {
    if (reasons.isNotEmpty) return true;
    if (RegExp(r'\d+\s*(ms|s|qps|万|亿|%|倍)|\d+(\.\d+)+').hasMatch(text)) {
      return true;
    }
    return RegExp(r'总是|从不|一定|必然|绝对').hasMatch(text);
  }

  String _normalize(String value) => value.replaceAll(RegExp(r'\s+'), '');
}
