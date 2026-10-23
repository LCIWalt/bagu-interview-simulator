import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/graph/question_graph_repository.dart';

Question q(
  String id,
  String title, {
  List<String> topics = const <String>['mysql'],
  List<String> keyPoints = const <String>['B+ 树扇出大', '叶子链表范围查询'],
  List<String> followups = const <String>[],
}) {
  return Question(
    id: id,
    bankVersion: 'v1',
    title: title,
    bodyMarkdown: '',
    topics: topics,
    role: 'backend',
    level: 3,
    difficulty: 3,
    type: QuestionType.knowledge,
    answer: QuestionAnswer(summary: 's', keyPoints: keyPoints),
    followups: followups,
    updatedAt: DateTime.utc(2026),
  );
}

void main() {
  test(
    'builds similar/followup/cluster edges and returns related questions',
    () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final repo = BankRepositoryImpl(db);
      await repo.upsertQuestions(<Question>[
        q('a', 'MySQL 为什么用 B+ 树索引', followups: <String>['MySQL 事务隔离级别']),
        q('b', '为什么 MySQL 使用 B+ 树索引'),
        q('c', 'MySQL 事务隔离级别', topics: const <String>['mysql', 'transaction']),
        q(
          'd',
          'TCP 三次握手',
          topics: const <String>['network'],
          keyPoints: <String>['序列号'],
        ),
      ]);
      final graph = QuestionGraphRepository(db, repo);
      await graph.rebuild();

      final related = await graph.related('a');
      expect(
        related.map((Question q) => q.id),
        containsAll(<String>['b', 'c']),
      );

      final edges = await db.select(db.questionEdges).get();
      expect(edges.any((QuestionEdgeRow e) => e.kind == 'similar'), isTrue);
      expect(edges.any((QuestionEdgeRow e) => e.kind == 'followup'), isTrue);
      final ids = <String>{'a', 'b', 'c', 'd'};
      expect(
        edges.every(
          (QuestionEdgeRow e) => ids.contains(e.src) && ids.contains(e.dst),
        ),
        isTrue,
      );

      final clusters = await db.select(db.clusterMembers).get();
      expect(clusters.any((ClusterMember c) => c.clusterId == 'mysql'), isTrue);
    },
  );

  test('ensureBuilt is idempotent and related survives empty graph', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = BankRepositoryImpl(db);
    await repo.upsertQuestions(<Question>[
      q('a', '唯一题目', topics: const <String>['x']),
    ]);
    final graph = QuestionGraphRepository(db, repo);
    await graph.ensureBuilt();
    final first = await graph.edgeCount();
    await graph.ensureBuilt();
    expect(await graph.edgeCount(), first);
    expect(await graph.related('a'), isEmpty);
  });
}
