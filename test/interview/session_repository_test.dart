import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/interview/data/drift_session_repository.dart';
import 'package:mockmate/features/interview/domain/session_flow.dart';

void main() {
  late AppDatabase db;
  late DriftSessionRepository repo;
  final fixedStart = DateTime.utc(2026, 10, 22, 10);

  setUp(() {
    db = AppDatabase.memory();
    var tick = 0;
    repo = DriftSessionRepository(
      db,
      now: () => fixedStart.add(Duration(seconds: tick++)),
    );
  });
  tearDown(() => db.close());

  const config = SessionConfig(
    mode: SessionMode.drill,
    role: 'backend',
    level: 'mid',
  );

  test(
    'creates a session, appends answers in order and persists scores',
    () async {
      final session = await repo.create(config);
      expect(session.status, SessionStatus.active);
      expect(await repo.activeSession(), isNotNull);

      final turn1 = await repo.appendAnswer(
        session.id,
        AnswerInput(
          questionId: 'q1',
          questionText: '题目一',
          text: '回答一',
          tStartedAt: fixedStart,
        ),
      );
      final turn2 = await repo.appendAnswer(
        session.id,
        AnswerInput(
          questionId: 'q2',
          questionText: '题目二',
          text: '回答二',
          tStartedAt: fixedStart,
        ),
      );
      expect(<int>[turn1.seq, turn2.seq], <int>[1, 2]);

      await repo.saveScore(
        turn1.id,
        const TurnScore(
          correctness: 4,
          depth: 3,
          structure: 2,
          coverage: 0.75,
          points: <TurnScorePoint>[
            TurnScorePoint(point: 'kp', verdict: 'hit', evidence: '回答一'),
          ],
        ),
      );
      final report = await repo.finish(session.id);
      expect(report.turns, hasLength(2));
      expect(report.turns.first.score?.coverage, 0.75);
      expect(report.dimensions['correctness'], closeTo(4, 1e-9)); // 仅统计已评分题
      expect(report.sampleShortfall, isTrue);

      final stored = await repo.byId(session.id);
      expect(stored?.status, SessionStatus.completed);
      expect(stored?.totalScore, closeTo(0.5 * 4 + 0.35 * 3 + 0.15 * 2, 1e-9));
      expect(await repo.activeSession(), isNull);
    },
  );

  test('rejects appending to a completed session', () async {
    final session = await repo.create(config);
    await repo.finish(session.id);
    await expectLater(
      repo.appendAnswer(
        session.id,
        AnswerInput(
          questionId: 'q1',
          questionText: 't',
          text: 'a',
          tStartedAt: fixedStart,
        ),
      ),
      throwsA(isA<UnknownFailure>()),
    );
  });

  test(
    'appendAnswer is idempotent when the client supplies a turn id',
    () async {
      final session = await repo.create(config);
      final input = AnswerInput(
        id: 't_fixed_1',
        questionId: 'q1',
        questionText: 't',
        text: 'a',
        tStartedAt: fixedStart,
      );
      final first = await repo.appendAnswer(session.id, input);
      final second = await repo.appendAnswer(session.id, input);
      expect(first.id, 't_fixed_1');
      expect(second.id, first.id);
      expect(await repo.turnsFor(session.id), hasLength(1));
    },
  );

  test('missing session is a NotFoundFailure', () async {
    await expectLater(
      repo.appendAnswer(
        'nope',
        AnswerInput(
          questionId: 'q',
          questionText: 't',
          text: 'a',
          tStartedAt: fixedStart,
        ),
      ),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('finish is idempotent and writes one aggregate row', () async {
    final session = await repo.create(config);
    await repo.finish(session.id);
    await repo.finish(session.id);
    final rows = await db.select(db.sessionScores).get();
    expect(rows, hasLength(1));
    expect(rows.single.aggregateJson, contains('dimensions'));
  });

  group('SessionFlow', () {
    test('mode cannot change and practice has no phases', () {
      final flow = SessionFlow.create(config);
      expect(flow.mode, SessionMode.drill);
      flow.submitAnswer();
      flow.nextQuestion();
      expect(flow.turnCount, 1);
      expect(flow.nextPhase, throwsA(isA<SessionFlowException>()));
      expect(flow.skipQuestion, returnsNormally);
    });

    test('mock advances phases and finishes at closing', () {
      final flow = SessionFlow.create(
        const SessionConfig(
          mode: SessionMode.mock,
          role: 'backend',
          level: 'senior',
        ),
      );
      expect(flow.phase, SessionPhase.warmup);
      flow.submitAnswer();
      flow.nextPhase();
      expect(flow.phase, SessionPhase.selfIntro);
      for (var i = 0; i < 5; i++) {
        flow.nextPhase();
      }
      expect(flow.status, SessionStatus.completed);
      expect(flow.submitAnswer, throwsA(isA<SessionFlowException>()));
    });

    test('followup depth and skip rules', () {
      final flow = SessionFlow.create(
        const SessionConfig(
          mode: SessionMode.drill,
          role: 'backend',
          level: 'mid',
          followupDepth: 1,
        ),
      );
      flow.submitAnswer(followup: true);
      expect(
        () => flow.submitAnswer(followup: true),
        throwsA(isA<SessionFlowException>()),
      );
      expect(flow.canFollowup, isFalse);

      final mock = SessionFlow.create(
        const SessionConfig(
          mode: SessionMode.mock,
          role: 'backend',
          level: 'mid',
        ),
      );
      expect(mock.skipQuestion, throwsA(isA<SessionFlowException>()));
    });

    test('timeout completes and blocks further transitions', () {
      final flow = SessionFlow.create(config);
      flow.timeout();
      expect(flow.status, SessionStatus.completed);
      expect(flow.abandon, throwsA(isA<SessionFlowException>()));
    });
  });
}
