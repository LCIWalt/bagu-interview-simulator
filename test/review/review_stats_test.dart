import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/interview/data/drift_session_repository.dart';
import 'package:mockmate/features/review/domain/review_stats.dart';

Question q(String id, String topic) => Question(
  id: id,
  bankVersion: 'v1',
  title: id,
  bodyMarkdown: '',
  topics: <String>[topic],
  role: 'mobile',
  level: 3,
  difficulty: 3,
  type: QuestionType.knowledge,
  answer: const QuestionAnswer(summary: 's', keyPoints: <String>['k']),
  updatedAt: DateTime.utc(2026),
);

void main() {
  test('aggregates trend and topic mastery across sessions', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await BankRepositoryImpl(db).upsertQuestions(<Question>[
      q('q-flutter', 'flutter'),
      q('q-android', 'android'),
    ]);
    final sessions = DriftSessionRepository(db);

    Future<void> run(String id, String questionId, String verdict) async {
      final session = await sessions.create(
        const SessionConfig(
          mode: SessionMode.drill,
          role: 'mobile',
          level: 'mid',
        ),
      );
      final turn = await sessions.appendAnswer(
        session.id,
        AnswerInput(
          id: 'turn-$id',
          questionId: questionId,
          questionText: questionId,
          text: 'answer',
          tStartedAt: DateTime.utc(2026, 10, 20),
        ),
      );
      await sessions.saveScore(
        turn.id,
        TurnScore(
          correctness: verdict == 'hit' ? 4 : 2,
          depth: 3,
          structure: 3,
          coverage: 0.5,
          points: <TurnScorePoint>[
            TurnScorePoint(point: 'p', verdict: verdict),
          ],
        ),
      );
      await sessions.finish(session.id);
    }

    await run('a', 'q-flutter', 'hit');
    await run('b', 'q-android', 'miss');

    final stats = await ReviewStatsBuilder(db).build();
    expect(stats.trend, hasLength(2));
    expect(stats.trend.first.score, closeTo(3.5, 1e-9));
    final flutter = stats.topics.firstWhere(
      (TopicMastery t) => t.topic == 'flutter',
    );
    final android = stats.topics.firstWhere(
      (TopicMastery t) => t.topic == 'android',
    );
    expect(flutter.rate, 1);
    expect(android.rate, 0);
  });
}
