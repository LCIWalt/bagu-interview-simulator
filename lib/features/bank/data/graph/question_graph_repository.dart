import 'package:drift/drift.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';

import '../bank_repository_impl.dart';
import '../dedup/similar_question_detector.dart';

/// 题库关系图（T-026）：similar / followup / cluster 建边与「相关题」。
class QuestionGraphRepository {
  QuestionGraphRepository(
    this._db,
    this._repository, {
    this.detector = const SimilarQuestionDetector(threshold: 0.85),
  });

  final AppDatabase _db;
  final BankRepositoryImpl _repository;
  final SimilarQuestionDetector detector;

  Future<int> edgeCount() async {
    final count = _db.questionEdges.src.count();
    final row = await (_db.selectOnly(
      _db.questionEdges,
    )..addColumns(<Expression<Object>>[count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> ensureBuilt() async {
    if (await edgeCount() > 0) return;
    await rebuild();
  }

  Future<void> rebuild() async {
    final questions = await _repository.search(
      const QuestionQuery(limit: 5000),
    );
    await _db.transaction(() async {
      await _db.delete(_db.questionEdges).go();
      await _db.delete(_db.clusterMembers).go();

      for (var i = 0; i < questions.length; i++) {
        for (var j = i + 1; j < questions.length; j++) {
          final similarity = detector.similarityBetween(
            questions[i],
            questions[j],
          );
          if (similarity >= detector.threshold) {
            await _edge(
              questions[i].id,
              questions[j].id,
              'similar',
              similarity,
            );
            await _edge(
              questions[j].id,
              questions[i].id,
              'similar',
              similarity,
            );
          }
        }
      }

      for (final question in questions) {
        for (final followup in question.followups) {
          final probe = Question(
            id: 'probe',
            bankVersion: question.bankVersion,
            title: followup,
            bodyMarkdown: '',
            topics: const <String>[],
            role: question.role,
            level: question.level,
            difficulty: question.difficulty,
            type: question.type,
            answer: const QuestionAnswer(summary: '', keyPoints: <String>[]),
          );
          var best = 0.0;
          Question? target;
          for (final candidate in questions) {
            if (candidate.id == question.id) continue;
            final similarity =
                detector.similarityBetween(probe, candidate) / 0.6;
            if (similarity > best) {
              best = similarity;
              target = candidate;
            }
          }
          if (target != null && best >= 0.5) {
            await _edge(question.id, target.id, 'followup', best);
            await _edge(target.id, question.id, 'followup', best);
          }
        }
      }

      final clusters = <String, List<String>>{};
      for (final question in questions) {
        if (question.topics.isEmpty) continue;
        clusters
            .putIfAbsent(question.topics.first, () => <String>[])
            .add(question.id);
      }
      for (final entry in clusters.entries) {
        for (final id in entry.value) {
          await _db
              .into(_db.clusterMembers)
              .insertOnConflictUpdate(
                ClusterMembersCompanion.insert(
                  clusterId: entry.key,
                  questionId: id,
                  label: Value(entry.key),
                ),
              );
        }
      }
    });
  }

  Future<List<Question>> _relatedFromEdges(
    String questionId, {
    required int limit,
  }) async {
    final edges =
        await (_db.select(_db.questionEdges)
              ..where((QuestionEdges t) => t.src.equals(questionId))
              ..orderBy(<OrderClauseGenerator<$QuestionEdgesTable>>[
                ($QuestionEdgesTable t) => OrderingTerm.desc(t.weight),
              ])
              ..limit(limit))
            .get();
    final questions = <Question>[];
    for (final edge in edges) {
      final question = await _repository.byId(edge.dst);
      if (question != null) questions.add(question);
    }
    return questions;
  }

  Future<void> _edge(String src, String dst, String kind, double weight) async {
    await _db
        .into(_db.questionEdges)
        .insertOnConflictUpdate(
          QuestionEdgesCompanion.insert(
            src: src,
            dst: dst,
            kind: kind,
            weight: Value(weight),
            source: const Value('auto'),
          ),
        );
  }

  /// 只读已建好的边，不在 UI 线程触发重建。
  Future<List<Question>> relatedCached(
    String questionId, {
    int limit = 7,
  }) async {
    return _relatedFromEdges(questionId, limit: limit);
  }

  Future<List<Question>> related(String questionId, {int limit = 7}) async {
    Future<List<QuestionEdgeRow>> query() {
      return (_db.select(_db.questionEdges)
            ..where((QuestionEdges t) => t.src.equals(questionId))
            ..orderBy(<OrderClauseGenerator<$QuestionEdgesTable>>[
              ($QuestionEdgesTable t) => OrderingTerm.desc(t.weight),
            ])
            ..limit(limit))
          .get();
    }

    var edges = await query();
    if (edges.isEmpty) {
      await ensureBuilt();
      edges = await query();
    }
    final questions = <Question>[];
    for (final edge in edges) {
      final question = await _repository.byId(edge.dst);
      if (question != null) questions.add(question);
    }
    return questions;
  }
}
