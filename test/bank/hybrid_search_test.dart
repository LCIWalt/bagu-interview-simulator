import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/search/hybrid_search.dart';

class _KeywordEmbedding implements EmbeddingProvider {
  @override
  String get id => 'fake';

  @override
  String get model => 'fake-4d';

  @override
  int get dimensions => 4;

  @override
  bool get isAvailable => true;

  List<double> _vector(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('闭包') || lower.contains('closure')) {
      return <double>[1, 0.1, 0, 0];
    }
    if (lower.contains('goroutine') || lower.contains('go ')) {
      return <double>[0, 1, 0.1, 0];
    }
    if (lower.contains('mysql') || lower.contains('b+')) {
      return <double>[0, 0, 1, 0.1];
    }
    return <double>[0, 0, 0, 1];
  }

  @override
  Future<List<double>> embed(String text) async => _vector(text);

  @override
  Future<List<List<double>>> embedBatch(List<String> texts) async =>
      texts.map(_vector).toList(growable: false);
}

Question q(String id, String title, String keyPoint) => Question(
  id: id,
  bankVersion: 'v1',
  title: title,
  bodyMarkdown: '',
  topics: const <String>['go'],
  role: 'backend',
  level: 3,
  difficulty: 3,
  type: QuestionType.knowledge,
  answer: QuestionAnswer(summary: '', keyPoints: <String>[keyPoint]),
  updatedAt: DateTime.utc(2026),
);

void main() {
  test(
    'hybrid search finds semantic matches FTS misses and fuses ranks',
    () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final repo = BankRepositoryImpl(db);
      await repo.upsertQuestions(<Question>[
        q('closure', 'JavaScript 闭包与作用域', '保存外层变量引用'),
        q('go', 'goroutine 调度与 GMP', 'P 提供执行上下文'),
        q('mysql', 'MySQL B+ 树索引', '叶子链表范围查询'),
      ]);
      final embedding = _KeywordEmbedding();
      final indexer = QuestionEmbeddingIndexer(
        repository: repo,
        embedding: embedding,
      );
      expect(await indexer.rebuild(), 3);

      final hybrid = HybridSearchEngine(repository: repo, embedding: embedding);
      final semantic = await hybrid.search(
        const QuestionQuery(text: 'closure'),
      );
      expect(semantic.first.id, 'closure');
      expect(semantic.map((Question q) => q.id), contains('closure'));

      final fused = await hybrid.search(const QuestionQuery(text: 'MySQL B+'));
      expect(fused.first.id, 'mysql');

      final filtered = await hybrid.search(
        const QuestionQuery(text: 'closure', topics: <String>['go']),
      );
      expect(filtered.every((Question q) => q.topics.contains('go')), isTrue);
    },
  );

  test('falls back to FTS when vectors are missing', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = BankRepositoryImpl(db);
    await repo.upsertQuestions(<Question>[
      q('closure', 'JavaScript 闭包与作用域', '保存外层变量引用'),
    ]);
    final embedding = _KeywordEmbedding();
    final hybrid = HybridSearchEngine(repository: repo, embedding: embedding);
    expect(await hybrid.search(const QuestionQuery(text: 'closure')), isEmpty);
    expect(
      (await hybrid.search(const QuestionQuery(text: '闭包与作用域'))).single.id,
      'closure',
    );
  });
}
