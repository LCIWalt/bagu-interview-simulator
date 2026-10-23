enum SessionMode { drill, mock }

enum SessionStatus { active, completed, abandoned }

/// 面试官风格；不做羞辱性文案（指南 §8.1）。
enum InterviewerStyle { friendly, neutral, stress }

/// 整场配置。练习模式只用其中一部分字段。
class SessionConfig {
  const SessionConfig({
    required this.mode,
    required this.role,
    required this.level,
    this.durationMinutes = 20,
    this.difficulty = 3,
    this.followupDepth = 2,
    this.allowHints = false,
    this.style = InterviewerStyle.friendly,
    this.topics = const <String>[],
    this.jdText,
  });

  final SessionMode mode;
  final String role;
  final String level;
  final int durationMinutes;
  final int difficulty;
  final int followupDepth;
  final bool allowHints;
  final InterviewerStyle style;
  final List<String> topics;
  final String? jdText;

  static SessionConfig fromJson(Map<String, Object?> json) {
    SessionMode mode = SessionMode.drill;
    for (final value in SessionMode.values) {
      if (value.name == json['mode']) mode = value;
    }
    InterviewerStyle style = InterviewerStyle.friendly;
    for (final value in InterviewerStyle.values) {
      if (value.name == json['style']) style = value;
    }
    return SessionConfig(
      mode: mode,
      role: json['role']?.toString() ?? 'backend',
      level: json['level']?.toString() ?? 'mid',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 20,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 3,
      followupDepth: (json['followupDepth'] as num?)?.toInt() ?? 2,
      allowHints: json['allowHints'] == true,
      style: style,
      topics: (json['topics'] as List<Object?>? ?? const <Object?>[])
          .map((Object? item) => '$item')
          .toList(growable: false),
      jdText: json['jdText']?.toString(),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'mode': mode.name,
    'role': role,
    'level': level,
    'durationMinutes': durationMinutes,
    'difficulty': difficulty,
    'followupDepth': followupDepth,
    'allowHints': allowHints,
    'style': style.name,
    'topics': topics,
    if (jdText != null) 'jdText': jdText,
  };
}

class TurnScorePoint {
  const TurnScorePoint({
    required this.point,
    required this.verdict,
    this.evidence = '',
  });

  final String point;

  /// `hit` / `partial` / `miss` / `not_asked`
  final String verdict;
  final String evidence;
}

class FactualError {
  const FactualError({
    required this.quote,
    required this.issue,
    this.sources = const <String>[],
  });

  final String quote;
  final String issue;
  final List<String> sources;
}

/// 一条联网核查记录（只降分；支持/未知都不加分）。
class TurnScoreFactCheck {
  const TurnScoreFactCheck({
    required this.claim,
    required this.verdict,
    this.evidence = '',
    this.sources = const <String>[],
  });

  final String claim;

  /// `supported` / `contradicted` / `unknown`
  final String verdict;
  final String evidence;
  final List<String> sources;
}

/// 单题评分（`turns.score_json`）。
class TurnScore {
  const TurnScore({
    required this.correctness,
    required this.depth,
    required this.structure,
    required this.coverage,
    this.points = const <TurnScorePoint>[],
    this.factualErrors = const <FactualError>[],
    this.factChecks = const <TurnScoreFactCheck>[],
    this.comment = '',
    this.degraded = false,
    this.lowConfidence = false,
  });

  final double correctness;
  final double depth;
  final double structure;
  final double coverage;
  final List<TurnScorePoint> points;
  final List<FactualError> factualErrors;
  final List<TurnScoreFactCheck> factChecks;
  final String comment;
  final bool degraded;
  final bool lowConfidence;

  double get total => 0.50 * correctness + 0.35 * depth + 0.15 * structure;
}

class Turn {
  const Turn({
    required this.id,
    required this.sessionId,
    required this.seq,
    required this.questionId,
    required this.questionText,
    required this.answerText,
    required this.tStartedAt,
    required this.tSubmittedAt,
    this.score,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final int seq;
  final String? questionId;
  final String questionText;
  final String answerText;
  final DateTime tStartedAt;
  final DateTime tSubmittedAt;
  final TurnScore? score;
  final DateTime createdAt;

  /// 估算作答时长（系统听写拿不到精确时长，指南 §7.4）。
  Duration get answerDuration => tSubmittedAt.difference(tStartedAt);
}

class Session {
  const Session({
    required this.id,
    required this.mode,
    required this.config,
    required this.startedAt,
    required this.status,
    this.endedAt,
    this.totalScore,
  });

  final String id;
  final SessionMode mode;
  final SessionConfig config;
  final DateTime startedAt;
  final DateTime? endedAt;
  final SessionStatus status;
  final double? totalScore;
}

class AnswerInput {
  const AnswerInput({
    this.id,
    required this.questionId,
    required this.questionText,
    required this.text,
    required this.tStartedAt,
    this.tSubmittedAt,
  });

  /// 客户端生成的 turn id；重试/恢复时用于幂等。
  final String? id;
  final String questionId;
  final String questionText;
  final String text;
  final DateTime tStartedAt;
  final DateTime? tSubmittedAt;
}

/// 复盘报告的六段结构（指南 §7.7）。v1 报告聚合在 T-044 实现。
class SessionReport {
  const SessionReport({
    required this.sessionId,
    required this.headline,
    required this.dimensions,
    required this.turns,
    required this.weakestTopics,
    required this.sevenDayPlan,
    required this.interviewerView,
    this.sampleShortfall = false,
    this.markdown,
  });

  final String sessionId;
  final String headline;
  final Map<String, double> dimensions;
  final List<Turn> turns;
  final List<String> weakestTopics;
  final List<String> sevenDayPlan;
  final String interviewerView;

  /// 提前结束/题量不足时标注（Q1）。
  final bool sampleShortfall;
  final String? markdown;
}

abstract interface class SessionRepository {
  Future<Session> create(SessionConfig cfg);

  Future<Turn> appendAnswer(String sessionId, AnswerInput input);

  Future<SessionReport> finish(String sessionId);
}
