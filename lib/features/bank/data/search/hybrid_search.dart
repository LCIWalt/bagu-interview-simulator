import 'dart:math';

import 'package:mockmate/core/contracts/contracts.dart';

import '../bank_repository_impl.dart';
import '../question_store.dart';

/// FTS + 向量 RRF 混合检索（T-025）。
///
/// 向量不可用/未建索引时自动退化为 FTS，不抛错。
class HybridSearchEngine {
  HybridSearchEngine({
    required this.repository,
    required this.embedding,
    this.rrfK = 60,
    this.vectorCandidates = 100,
  });

  final BankRepositoryImpl repository;
  final EmbeddingProvider embedding;
  final int rrfK;
  final int vectorCandidates;

  Future<List<Question>> search(QuestionQuery query) async {
    if (query.text.trim().isEmpty || !embedding.isAvailable) {
      return repository.search(query);
    }
    final ftsQuery = QuestionQuery(
      text: query.text,
      role: query.role,
      level: query.level,
      difficulty: query.difficulty,
      topics: query.topics,
      statuses: query.statuses,
      limit: 100,
    );
    final fts = await repository.search(ftsQuery);
    final pool = await repository.search(
      QuestionQuery(
        role: query.role,
        level: query.level,
        difficulty: query.difficulty,
        topics: query.topics,
        statuses: query.statuses,
        limit: 5000,
      ),
    );
    final vectors = await repository.loadEmbeddings(embedding.model);
    if (vectors.isEmpty) return repository.search(query);

    final queryVector = await embedding.embed(query.text);
    final scored = <String, double>{};
    var rank = 0;
    for (final question in fts) {
      scored[question.id] = (scored[question.id] ?? 0) + 1 / (rrfK + rank + 1);
      rank++;
    }

    final vectorRanked = <({Question question, double similarity})>[];
    for (final question in pool) {
      final vector = vectors[question.id];
      if (vector == null) continue;
      vectorRanked.add((
        question: question,
        similarity: _cosine(queryVector, vector),
      ));
    }
    vectorRanked.sort((a, b) => b.similarity.compareTo(a.similarity));
    rank = 0;
    for (final entry in vectorRanked.take(vectorCandidates)) {
      scored[entry.question.id] =
          (scored[entry.question.id] ?? 0) + 1 / (rrfK + rank + 1);
      rank++;
    }

    final byId = <String, Question>{
      for (final question in fts) question.id: question,
      for (final entry in vectorRanked) entry.question.id: entry.question,
    };
    final ordered = scored.entries.toList()
      ..sort(
        (MapEntry<String, double> a, MapEntry<String, double> b) =>
            b.value.compareTo(a.value),
      );
    return ordered
        .skip(query.offset)
        .take(query.limit)
        .map((MapEntry<String, double> entry) => byId[entry.key])
        .whereType<Question>()
        .toList(growable: false);
  }

  double _cosine(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) return 0;
    var dot = 0.0;
    var na = 0.0;
    var nb = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    if (na == 0 || nb == 0) return 0;
    return dot / (sqrt(na) * sqrt(nb));
  }
}

/// 全量重建题库向量（T-024 的纯 Dart 部分）。模型不可用时直接跳过。
class QuestionEmbeddingIndexer {
  QuestionEmbeddingIndexer({
    required this.repository,
    required this.embedding,
    this.batchSize = 16,
  });

  final BankRepositoryImpl repository;
  final EmbeddingProvider embedding;
  final int batchSize;

  Future<int> rebuild({void Function(int done, int total)? onProgress}) async {
    if (!embedding.isAvailable) return 0;
    final rows = await repository.questionsForIndex();
    var done = 0;
    for (var start = 0; start < rows.length; start += batchSize) {
      final batch = rows.skip(start).take(batchSize).toList();
      final texts = batch
          .map((row) {
            final question = QuestionStore.toDomain(row);
            return '${question.title}\n${question.topics.join(' ')}\n'
                '${question.answer.keyPoints.join(' ')}';
          })
          .toList(growable: false);
      final vectors = await embedding.embedBatch(texts);
      for (var i = 0; i < batch.length; i++) {
        await repository.upsertEmbedding(
          questionId: batch[i].id,
          model: embedding.model,
          dim: embedding.dimensions,
          vector: vectors[i],
        );
      }
      done += batch.length;
      onProgress?.call(done, rows.length);
    }
    return done;
  }
}
