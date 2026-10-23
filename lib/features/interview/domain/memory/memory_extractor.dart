import 'dart:convert';

import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';

import 'session_memory.dart';

class MemoryExtraction {
  const MemoryExtraction({
    this.projects = const <MemoryProject>[],
    this.claims = const <MemoryClaim>[],
    this.numbers = const <String>[],
    this.contradictions = const <String>[],
    this.unanswered = const <String>[],
    this.weakTopics = const <String>[],
  });

  final List<MemoryProject> projects;
  final List<MemoryClaim> claims;
  final List<String> numbers;
  final List<String> contradictions;
  final List<String> unanswered;
  final List<String> weakTopics;
}

/// 结构化记忆抽取（T-043）：只抽技术事实，不编造；失败返回 null。
class MemoryExtractor {
  MemoryExtractor({
    required this.client,
    required this.prompts,
    required this.model,
    this.maxAttempts = 2,
  });

  final LlmClient client;
  final PromptRegistry prompts;
  final String model;
  final int maxAttempts;

  Future<MemoryExtraction?> extract({
    required SessionConfig config,
    required String turnText,
    CancelToken? cancel,
  }) async {
    final template = prompts.require('memory.extract');
    final prompt = template.render(<String, String>{
      'role': config.role,
      'level': config.level,
      'turnText': turnText,
    });
    final request = ChatRequest(
      model: model,
      messages: <ChatMessage>[ChatMessage.system(prompt)],
      temperature: template.temperature,
      maxTokens: 700,
      forceJson: true,
    );
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final buffer = StringBuffer();
      await for (final delta in client.chat(request, cancel: cancel)) {
        if (delta is LlmTextDelta) buffer.write(delta.text);
        if (delta is LlmDoneDelta) break;
      }
      final parsed = _parse(buffer.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  MemoryExtraction? _parse(String raw) {
    final text = raw.trim();
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    try {
      final decoded = jsonDecode(text.substring(start, end + 1));
      if (decoded is! Map<String, dynamic>) return null;
      List<Map<String, dynamic>> maps(Object? value) =>
          (value as List<Object?>? ?? const <Object?>[])
              .whereType<Map<String, dynamic>>()
              .toList(growable: false);
      List<String> strings(Object? value) =>
          (value as List<Object?>? ?? const <Object?>[])
              .map((Object? item) => '$item')
              .map((String item) => item.trim())
              .where((String item) => item.isNotEmpty)
              .toList(growable: false);
      return MemoryExtraction(
        projects: maps(decoded['projects'])
            .map(MemoryProject.fromJson)
            .toList(growable: false),
        claims: maps(decoded['claims'])
            .where(
              (Map<String, dynamic> c) =>
                  (c['text']?.toString() ?? '').trim().isNotEmpty,
            )
            .map(MemoryClaim.fromJson)
            .toList(growable: false),
        numbers: strings(decoded['numbers']),
        contradictions: strings(decoded['contradictions']),
        unanswered: strings(decoded['unanswered']),
        weakTopics: strings(decoded['weakTopics']),
      );
    } on FormatException {
      return null;
    }
  }
}
