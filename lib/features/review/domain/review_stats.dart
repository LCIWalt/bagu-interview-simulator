import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';

import '../../interview/domain/turn_score_codec.dart';

class TrendPoint {
  const TrendPoint({
    required this.date,
    required this.score,
    required this.sessionId,
  });

  final DateTime date;
  final double score;
  final String sessionId;
}

class TopicMastery {
  const TopicMastery({
    required this.topic,
    required this.hits,
    required this.partials,
    required this.misses,
  });

  final String topic;
  final int hits;
  final int partials;
  final int misses;

  int get total => hits + partials + misses;

  double get rate => total == 0 ? 0 : (hits + 0.5 * partials) / total;
}

class ReviewStats {
  const ReviewStats({required this.trend, required this.topics});

  final List<TrendPoint> trend;
  final List<TopicMastery> topics;
}

class ReviewStatsBuilder {
  ReviewStatsBuilder(this._db);

  final AppDatabase _db;

  Future<ReviewStats> build({int maxSessions = 20}) async {
    final sessions =
        await (_db.select(_db.sessions)
              ..where((Sessions t) => t.status.equals('completed'))
              ..orderBy(<OrderClauseGenerator<$SessionsTable>>[
                ($SessionsTable t) => OrderingTerm.asc(t.startedAt),
              ]))
            .get();
    final recent = sessions.length <= maxSessions
        ? sessions
        : sessions.sublist(sessions.length - maxSessions);

    final allTurns = await (_db.select(
      _db.turns,
    )..where((Turns t) => t.scoreJson.isNotNull())).get();
    final turnsBySession = <String, List<TurnRow>>{};
    for (final turn in allTurns) {
      turnsBySession.putIfAbsent(turn.sessionId, () => <TurnRow>[]).add(turn);
    }

    final trend = <TrendPoint>[];
    for (final session in recent) {
      final turns = turnsBySession[session.id] ?? const <TurnRow>[];
      final scores = turns
          .map((TurnRow turn) => TurnScoreCodec.decode(turn.scoreJson!))
          .whereType<TurnScore>()
          .toList(growable: false);
      final score =
          session.totalScore ??
          (scores.isEmpty
              ? null
              : scores
                        .map((TurnScore s) => s.total)
                        .reduce((double a, double b) => a + b) /
                    scores.length);
      if (score == null) continue;
      trend.add(
        TrendPoint(
          date: session.startedAt,
          score: score,
          sessionId: session.id,
        ),
      );
    }

    final questionIds = allTurns
        .map((TurnRow turn) => turn.questionId)
        .whereType<String>()
        .toSet()
        .toList(growable: false);
    final questions = questionIds.isEmpty
        ? const <QuestionRow>[]
        : await (_db.select(
            _db.questions,
          )..where((Questions q) => q.id.isIn(questionIds))).get();
    final topicsById = <String, List<String>>{
      for (final row in questions) row.id: _decodeTopics(row.topics),
    };

    final counts = <String, List<int>>{};
    for (final turn in allTurns) {
      final score = TurnScoreCodec.decode(turn.scoreJson!);
      if (score == null) continue;
      final topics = topicsById[turn.questionId] ?? const <String>[];
      if (topics.isEmpty) continue;
      for (final point in score.points) {
        for (final topic in topics) {
          final bucket = counts.putIfAbsent(topic, () => <int>[0, 0, 0]);
          switch (point.verdict) {
            case 'hit':
              bucket[0]++;
            case 'partial':
              bucket[1]++;
            case 'miss':
              bucket[2]++;
            default:
              break;
          }
        }
      }
    }
    final topics =
        counts.entries
            .map(
              (MapEntry<String, List<int>> entry) => TopicMastery(
                topic: entry.key,
                hits: entry.value[0],
                partials: entry.value[1],
                misses: entry.value[2],
              ),
            )
            .where((TopicMastery topic) => topic.total > 0)
            .toList()
          ..sort((TopicMastery a, TopicMastery b) {
            final byTotal = b.total.compareTo(a.total);
            return byTotal != 0 ? byTotal : a.rate.compareTo(b.rate);
          });
    return ReviewStats(trend: trend, topics: topics);
  }

  List<String> _decodeTopics(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((Object? value) => '$value').toList(growable: false);
      }
    } on FormatException {
      return const <String>[];
    }
    return const <String>[];
  }
}
