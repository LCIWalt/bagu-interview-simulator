import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/question_local_repository.dart';

Question q(
  String id, {
  String role = 'backend',
  List<String> topics = const <String>['mysql'],
  QuestionStatus status = QuestionStatus.verified,
}) {
  return Question(
    id: id,
    bankVersion: 'v1',
    title: id,
    bodyMarkdown: '',
    topics: topics,
    role: role,
    level: 3,
    difficulty: 3,
    type: QuestionType.knowledge,
    answer: const QuestionAnswer(summary: 's', keyPoints: <String>['k']),
    status: status,
    updatedAt: DateTime.utc(2026),
  );
}

void main() {
  test('aggregates topics by role, excluding hidden and orphaned', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = BankRepositoryImpl(db);
    final local = QuestionLocalRepository(db);
    await repo.upsertQuestions(<Question>[
      q('q1', topics: const <String>['mysql', 'index']),
      q('q2', role: 'frontend'),
      q('q3', role: 'frontend', topics: const <String>['react']),
      q('q4', status: QuestionStatus.orphaned),
    ]);
    await local.setHidden('q1', true);
    final tree = await repo.topicsByRole();
    expect(tree['backend'], isNull);
    final frontend = tree['frontend']!.map((TopicCount t) => t.topic).toSet();
    expect(frontend, containsAll(<String>['mysql', 'react']));
    expect(
      tree.values
          .expand((List<TopicCount> list) => list)
          .any((TopicCount t) => t.topic == 'index'),
      isFalse,
    );
  });
}
