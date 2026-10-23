import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/util/redact.dart';
import 'package:mockmate/features/bank/data/question_store.dart';

import '../domain/turn_score_codec.dart';

/// 会话持久化（T-031）。先落盘回答，再异步评分；`turns.score_json` 可后补。
class DriftSessionRepository implements SessionRepository {
  DriftSessionRepository(this._db, {DateTime Function()? now, Random? random})
    : _now = now ?? DateTime.now,
      _random = random ?? Random.secure();

  final AppDatabase _db;
  final DateTime Function() _now;
  final Random _random;

  @override
  Future<Session> create(SessionConfig cfg) async {
    final startedAt = _now();
    final id = _newId('s');
    await _db
        .into(_db.sessions)
        .insert(
          SessionsCompanion.insert(
            id: id,
            mode: cfg.mode.name,
            configJson: jsonEncode(cfg.toJson()),
            startedAt: startedAt,
            status: const Value('active'),
          ),
        );
    return Session(
      id: id,
      mode: cfg.mode,
      config: cfg,
      startedAt: startedAt,
      status: SessionStatus.active,
    );
  }

  @override
  Future<Turn> appendAnswer(String sessionId, AnswerInput input) async {
    return _db.transaction(() async {
      final sessionRow = await _sessionRow(sessionId);
      if (sessionRow == null) {
        throw const NotFoundFailure('session not found');
      }
      if (parseSessionStatus(sessionRow.status) != SessionStatus.active) {
        throw const UnknownFailure('session is not active');
      }
      if (input.id != null) {
        final existing = await (_db.select(
          _db.turns,
        )..where((Turns t) => t.id.equals(input.id!))).getSingleOrNull();
        if (existing != null) return _turnFromRow(existing);
      }
      final next = await _db
          .customSelect(
            'SELECT COALESCE(MAX(seq), 0) + 1 AS next_seq FROM turns WHERE session_id = ?',
            variables: <Variable<Object>>[Variable<String>(sessionId)],
            readsFrom: <ResultSetImplementation<dynamic, dynamic>>{_db.turns},
          )
          .getSingle();
      final seq = (next.data['next_seq'] as int?) ?? 1;
      final submittedAt = input.tSubmittedAt ?? _now();
      final turn = Turn(
        id: input.id ?? _newId('t'),
        sessionId: sessionId,
        seq: seq,
        questionId: input.questionId,
        questionText: input.questionText,
        answerText: input.text,
        tStartedAt: input.tStartedAt,
        tSubmittedAt: submittedAt,
        createdAt: _now(),
      );
      await _db
          .into(_db.turns)
          .insert(
            TurnsCompanion.insert(
              id: turn.id,
              sessionId: sessionId,
              seq: seq,
              questionId: Value(input.questionId),
              questionText: Value(input.questionText),
              answerText: Value(input.text),
              tStartedAt: turn.tStartedAt,
              tSubmittedAt: submittedAt,
              createdAt: turn.createdAt,
            ),
          );
      return turn;
    });
  }

  @override
  Future<SessionReport> finish(String sessionId) async {
    final row = await _sessionRow(sessionId);
    if (row == null) throw const NotFoundFailure('session not found');
    final turns = await turnsFor(sessionId);
    final scores = turns
        .map((TurnRow turn) => TurnScoreCodec.decode(turn.scoreJson))
        .toList();
    final scored = scores.whereType<TurnScore>().toList(growable: false);
    final dimensions = <String, double>{
      'correctness': _average(scored.map((TurnScore s) => s.correctness)),
      'depth': _average(scored.map((TurnScore s) => s.depth)),
      'structure': _average(scored.map((TurnScore s) => s.structure)),
    };
    final total = _average(scored.map((TurnScore s) => s.total));
    final weakness = await _topicWeakness(turns);
    final weakestTopics = weakness.keys.take(3).toList(growable: false);
    final headline = _headline(
      dimensions['correctness'] ?? 0,
      dimensions['depth'] ?? 0,
      dimensions['structure'] ?? 0,
    );
    final plan = _sevenDayPlan(weakestTopics);
    final interviewerView = weakestTopics.isEmpty
        ? '整体基础可用；下一场我会提高追问难度，观察稳定性。'
        : '下一场我会继续追问你在「${weakestTopics.first}」上的取舍与边界。';
    final endedAt = row.endedAt ?? _now();
    await (_db.update(
      _db.sessions,
    )..where((Sessions t) => t.id.equals(sessionId))).write(
      SessionsCompanion(
        status: const Value('completed'),
        endedAt: Value(endedAt),
        totalScore: Value(scored.isEmpty ? null : total),
      ),
    );
    await _db
        .into(_db.sessionScores)
        .insertOnConflictUpdate(
          SessionScoresCompanion.insert(
            sessionId: sessionId,
            aggregateJson: jsonEncode(<String, Object?>{
              'dimensions': dimensions,
              'turns': turns.length,
              'scoredTurns': scored.length,
              'total': scored.isEmpty ? null : total,
            }),
            rubricVersion: 'v1',
            model: '',
            createdAt: _now(),
          ),
        );
    final report = SessionReport(
      sessionId: sessionId,
      headline: headline,
      dimensions: dimensions,
      turns: turns.map(_turnFromRow).toList(growable: false),
      weakestTopics: weakestTopics,
      sevenDayPlan: plan,
      interviewerView: interviewerView,
      sampleShortfall: turns.length < 3,
    );
    return SessionReport(
      sessionId: report.sessionId,
      headline: report.headline,
      dimensions: report.dimensions,
      turns: report.turns,
      weakestTopics: report.weakestTopics,
      sevenDayPlan: report.sevenDayPlan,
      interviewerView: report.interviewerView,
      sampleShortfall: report.sampleShortfall,
      markdown: _markdown(report),
    );
  }

  Future<Map<String, double>> _topicWeakness(List<TurnRow> turns) async {
    final ids = turns
        .map((TurnRow t) => t.questionId)
        .whereType<String>()
        .toSet()
        .toList();
    if (ids.isEmpty) return const <String, double>{};
    final rows = await (_db.select(
      _db.questions,
    )..where((Questions q) => q.id.isIn(ids))).get();
    final topicsById = <String, List<String>>{
      for (final row in rows) row.id: QuestionStoreTopics.decode(row.topics),
    };
    final scores = <String, double>{};
    for (final turn in turns) {
      final score = TurnScoreCodec.decode(turn.scoreJson);
      if (score == null) continue;
      final topics = topicsById[turn.questionId] ?? const <String>[];
      for (final point in score.points) {
        if (point.verdict != 'miss' && point.verdict != 'partial') continue;
        final weight = point.verdict == 'miss' ? 1.0 : 0.5;
        for (final topic in topics) {
          scores[topic] = (scores[topic] ?? 0) + weight;
        }
      }
    }
    final entries = scores.entries.toList()
      ..sort(
        (MapEntry<String, double> a, MapEntry<String, double> b) =>
            b.value.compareTo(a.value),
      );
    return <String, double>{
      for (final entry in entries) entry.key: entry.value,
    };
  }

  String _headline(double correctness, double depth, double structure) {
    if (correctness < 3) return '关键点覆盖不足：先把核心原理讲准，再补深度与取舍。';
    if (depth < 3) return '原理基础不错，但深度、取舍与边界还需要补。';
    if (structure < 3) return '内容基本到位，建议先给结论，再分点论证。';
    return '三维较均衡，下一场用更难的追问与系统设计拉开差距。';
  }

  List<String> _sevenDayPlan(List<String> weakest) {
    final focus = weakest.isEmpty ? '核心高频题' : weakest.first;
    return <String>[
      for (var day = 1; day <= 7; day++)
        day.isOdd
            ? '第 $day 天：重做 3 道「$focus」题，对照评分点逐条自评。'
            : '第 $day 天：用 5 分钟口述「$focus」的取舍与边界，并记录一个反例。',
    ];
  }

  String _markdown(SessionReport report) {
    final buffer = StringBuffer()
      ..writeln('# MockMate 面试报告')
      ..writeln()
      ..writeln('- 会话：${report.sessionId}')
      ..writeln('- 结论：${redact(report.headline)}')
      ..writeln('- 样本${report.sampleShortfall ? '不足（题量 < 3）' : '充足'}')
      ..writeln()
      ..writeln('## 能力分布')
      ..writeln()
      ..writeln('| 维度 | 分数 |')
      ..writeln('|---|---|')
      ..writeln(
        '| 正确性 | ${(report.dimensions['correctness'] ?? 0).toStringAsFixed(1)} / 5 |',
      )
      ..writeln(
        '| 深度 | ${(report.dimensions['depth'] ?? 0).toStringAsFixed(1)} / 5 |',
      )
      ..writeln(
        '| 结构 | ${(report.dimensions['structure'] ?? 0).toStringAsFixed(1)} / 5 |',
      )
      ..writeln()
      ..writeln('## 薄弱主题')
      ..writeln();
    if (report.weakestTopics.isEmpty) {
      buffer.writeln('- 暂无');
    } else {
      for (final topic in report.weakestTopics) {
        buffer.writeln('- $topic');
      }
    }
    buffer
      ..writeln()
      ..writeln('## 7 天计划')
      ..writeln();
    for (final item in report.sevenDayPlan) {
      buffer.writeln('- $item');
    }
    buffer
      ..writeln()
      ..writeln('## 面试官视角')
      ..writeln()
      ..writeln(report.interviewerView)
      ..writeln()
      ..writeln('## 逐题回顾');
    for (final turn in report.turns) {
      buffer
        ..writeln()
        ..writeln('### ${turn.seq}. ${redact(turn.questionText)}')
        ..writeln()
        ..writeln('**我的回答**')
        ..writeln()
        ..writeln('> ${redact(turn.answerText)}')
        ..writeln();
      final score = turn.score;
      if (score == null) {
        buffer.writeln('（未评分）');
        continue;
      }
      buffer
        ..writeln(
          '得分：${score.total.toStringAsFixed(1)} / 5（覆盖 ${(score.coverage * 100).toStringAsFixed(0)}%）',
        )
        ..writeln();
      for (final point in score.points) {
        buffer.writeln(
          '- [${point.verdict}] ${point.point}${point.evidence.isEmpty ? '' : '（证据：${redact(point.evidence)}）'}',
        );
      }
      for (final error in score.factualErrors) {
        buffer.writeln(
          '- 事实错误：“${redact(error.quote)}”→ ${redact(error.issue)}',
        );
      }
    }
    return buffer.toString();
  }

  Future<void> deleteSession(String sessionId) async {
    await (_db.delete(
      _db.sessions,
    )..where((Sessions t) => t.id.equals(sessionId))).go();
  }

  /// 评分官异步写入单题分数（旁路，不阻塞下一题）。
  Future<void> saveScore(String turnId, TurnScore score) async {
    await (_db.update(_db.turns)..where((Turns t) => t.id.equals(turnId)))
        .write(TurnsCompanion(scoreJson: Value(TurnScoreCodec.encode(score))));
  }

  Future<Session?> byId(String sessionId) async {
    final row = await _sessionRow(sessionId);
    return row == null ? null : _sessionFromRow(row);
  }

  /// 最近一个进行中的会话（T-045 恢复用）。
  Future<Session?> activeSession() async {
    final row =
        await (_db.select(_db.sessions)
              ..where((Sessions t) => t.status.equals('active'))
              ..orderBy(<OrderClauseGenerator<$SessionsTable>>[
                ($SessionsTable t) => OrderingTerm.desc(t.startedAt),
              ])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _sessionFromRow(row);
  }

  Future<List<TurnRow>> turnsFor(String sessionId) {
    return (_db.select(_db.turns)
          ..where((Turns t) => t.sessionId.equals(sessionId))
          ..orderBy(<OrderClauseGenerator<$TurnsTable>>[
            ($TurnsTable t) => OrderingTerm.asc(t.seq),
          ]))
        .get();
  }

  Future<SessionRow?> _sessionRow(String id) {
    return (_db.select(
      _db.sessions,
    )..where((Sessions t) => t.id.equals(id))).getSingleOrNull();
  }

  Session _sessionFromRow(SessionRow row) {
    Map<String, Object?> config = const <String, Object?>{};
    try {
      final decoded = jsonDecode(row.configJson);
      if (decoded is Map<String, dynamic>) config = decoded;
    } on FormatException {
      // 配置损坏时回退到默认值，不让历史会话打不开。
    }
    return Session(
      id: row.id,
      mode: row.mode == 'mock' ? SessionMode.mock : SessionMode.drill,
      config: SessionConfig.fromJson(config),
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      status: parseSessionStatus(row.status),
      totalScore: row.totalScore,
    );
  }

  Turn _turnFromRow(TurnRow row) {
    return Turn(
      id: row.id,
      sessionId: row.sessionId,
      seq: row.seq,
      questionId: row.questionId,
      questionText: row.questionText,
      answerText: row.answerText,
      tStartedAt: row.tStartedAt,
      tSubmittedAt: row.tSubmittedAt,
      score: TurnScoreCodec.decode(row.scoreJson),
      createdAt: row.createdAt,
    );
  }

  double _average(Iterable<double> values) {
    if (values.isEmpty) return 0;
    final sum = values.fold<double>(
      0,
      (double previous, double value) => previous + value,
    );
    return sum / values.length;
  }

  String _newId(String prefix) {
    final timestamp = _now().microsecondsSinceEpoch.toRadixString(36);
    final suffix = _random.nextInt(0x7fffffff).toRadixString(36);
    return '${prefix}_$timestamp$suffix';
  }
}

extension SessionAppeals on DriftSessionRepository {
  /// T-034 申诉：追加到 settings（`appeal.<turnId>`），不自动改分。
  Future<void> saveAppeal(
    String turnId, {
    required String point,
    required String userNote,
  }) async {
    final key = 'appeal.$turnId';
    final row = await (_db.select(
      _db.settings,
    )..where((Settings t) => t.key.equals(key))).getSingleOrNull();
    final entries = <Object?>[];
    if (row != null) {
      try {
        final decoded = jsonDecode(row.value);
        if (decoded is List) entries.addAll(decoded);
      } on FormatException {
        // 忽略损坏的历史申诉。
      }
    }
    entries.add(<String, Object?>{
      'point': point,
      'note': userNote,
      'at': DateTime.now().toUtc().toIso8601String(),
    });
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: key,
            value: jsonEncode(entries),
            updatedAt: DateTime.now(),
          ),
        );
  }
}

extension SessionHistory on DriftSessionRepository {
  /// 最近跨场练过的题目（出题避重，T-032）。
  Future<List<String>> recentQuestionIds({int limit = 20}) async {
    final rows = await _db
        .customSelect(
          'SELECT question_id FROM turns WHERE question_id IS NOT NULL '
          'GROUP BY question_id ORDER BY MAX(t_submitted_at) DESC LIMIT ?',
          variables: <Variable<Object>>[Variable<int>(limit)],
          readsFrom: <ResultSetImplementation<dynamic, dynamic>>{_db.turns},
        )
        .get();
    return rows
        .map((QueryRow row) => row.data['question_id']?.toString())
        .whereType<String>()
        .toList(growable: false);
  }
}
