import 'dart:convert';

class MemoryProject {
  const MemoryProject({
    required this.name,
    this.stack = const <String>[],
    this.claims = const <String>[],
  });

  final String name;
  final List<String> stack;
  final List<String> claims;

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'stack': stack,
    'claims': claims,
  };

  static MemoryProject fromJson(Map<String, dynamic> json) => MemoryProject(
    name: json['name']?.toString() ?? '',
    stack: _asStrings(json['stack']),
    claims: _asStrings(json['claims']),
  );
}

class MemoryClaim {
  const MemoryClaim({required this.text, this.verified = false, this.turnSeq});

  final String text;
  final bool verified;
  final int? turnSeq;

  Map<String, Object?> toJson() => <String, Object?>{
    'text': text,
    'verified': verified,
    if (turnSeq != null) 'turnSeq': turnSeq,
  };

  static MemoryClaim fromJson(Map<String, dynamic> json, {int? turnSeq}) =>
      MemoryClaim(
        text: json['text']?.toString() ?? '',
        verified: json['verified'] == true,
        turnSeq: json['turnSeq'] as int? ?? turnSeq,
      );
}

/// 结构化记忆（指南 §7.6），只存技术事实，不做人格/情感记忆。
class SessionMemory {
  const SessionMemory({
    required this.sessionId,
    required this.role,
    required this.level,
    required this.mode,
    this.projects = const <MemoryProject>[],
    this.claims = const <MemoryClaim>[],
    this.numbers = const <String>[],
    this.contradictions = const <String>[],
    this.unanswered = const <String>[],
    this.weakTopics = const <String>[],
    this.askedQuestionIds = const <String>[],
  });

  final String sessionId;
  final String role;
  final String level;
  final String mode;
  final List<MemoryProject> projects;
  final List<MemoryClaim> claims;
  final List<String> numbers;
  final List<String> contradictions;
  final List<String> unanswered;
  final List<String> weakTopics;
  final List<String> askedQuestionIds;

  SessionMemory copyWith({
    List<MemoryProject>? projects,
    List<MemoryClaim>? claims,
    List<String>? numbers,
    List<String>? contradictions,
    List<String>? unanswered,
    List<String>? weakTopics,
    List<String>? askedQuestionIds,
  }) {
    return SessionMemory(
      sessionId: sessionId,
      role: role,
      level: level,
      mode: mode,
      projects: projects ?? this.projects,
      claims: claims ?? this.claims,
      numbers: numbers ?? this.numbers,
      contradictions: contradictions ?? this.contradictions,
      unanswered: unanswered ?? this.unanswered,
      weakTopics: weakTopics ?? this.weakTopics,
      askedQuestionIds: askedQuestionIds ?? this.askedQuestionIds,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'sessionId': sessionId,
    'role': role,
    'level': level,
    'mode': mode,
    'projects': projects
        .map((MemoryProject p) => p.toJson())
        .toList(growable: false),
    'claims': claims.map((MemoryClaim c) => c.toJson()).toList(growable: false),
    'numbers': numbers,
    'contradictions': contradictions,
    'unanswered': unanswered,
    'weakTopics': weakTopics,
    'askedQuestionIds': askedQuestionIds,
  };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  static SessionMemory fromJson(Map<String, dynamic> json) {
    return SessionMemory(
      sessionId: json['sessionId']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      mode: json['mode']?.toString() ?? 'mock',
      projects: (json['projects'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map<String, dynamic>>()
          .map(MemoryProject.fromJson)
          .toList(growable: false),
      claims: (json['claims'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map<String, dynamic>>()
          .map(MemoryClaim.fromJson)
          .toList(growable: false),
      numbers: _asStrings(json['numbers']),
      contradictions: _asStrings(json['contradictions']),
      unanswered: _asStrings(json['unanswered']),
      weakTopics: _asStrings(json['weakTopics']),
      askedQuestionIds: _asStrings(json['askedQuestionIds']),
    );
  }
}

List<String> _asStrings(Object? raw) =>
    (raw as List<Object?>? ?? const <Object?>[])
        .map((Object? item) => '$item')
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
