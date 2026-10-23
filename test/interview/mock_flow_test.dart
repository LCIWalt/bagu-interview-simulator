import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/features/interview/data/drift_session_repository.dart';
import 'package:mockmate/features/interview/data/mock_config_store.dart';
import 'package:mockmate/features/interview/data/mock_resume_store.dart';
import 'package:mockmate/features/interview/domain/scoring/scoring_engine.dart';
import 'package:mockmate/features/interview/presentation/config/mock_setup_page.dart';
import 'package:mockmate/features/interview/presentation/live/mock_live_page.dart';
import 'package:mockmate/features/review/presentation/mock_report_page.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

import '../fakes/fakes.dart';

const String _prompt =
    '---\n'
    'id: scorer.rubric\n'
    'version: 1\n'
    'model: m\n'
    'temperature: 0.2\n'
    'variables: [questionTitle, keyPoints, pitfalls, answerText, followupDepth]\n'
    '---\n'
    '{{questionTitle}} {{keyPoints}} {{pitfalls}} {{answerText}} {{followupDepth}}\n';

final PromptRegistry _prompts = PromptRegistry(<String, PromptTemplate>{
  'scorer.rubric': PromptTemplate.parse(_prompt, assetPath: 'test.md'),
});

Question _q(String id) => Question(
  id: id,
  bankVersion: 'v1',
  title: '题目 $id',
  bodyMarkdown: '',
  topics: const <String>['go'],
  role: 'backend',
  level: 3,
  difficulty: 3,
  type: QuestionType.knowledge,
  answer: const QuestionAnswer(summary: 's', keyPoints: <String>['k1']),
  updatedAt: DateTime.utc(2026),
);

String _scoreJson() => jsonEncode(<String, Object?>{
  'points': <Object?>[
    <String, Object?>{'point': 'k1', 'verdict': 'hit', 'evidence': 'answer'},
  ],
  'factualErrors': <Object?>[],
  'correctness': 4,
  'depth': 4,
  'structure': 3,
  'comment': '',
});

Future<ScoringEngine> _engine() async => ScoringEngine(
  client: FakeLlmClient(
    script: <FakeLlmTurn>[
      FakeLlmTurn(textChunks: <String>[_scoreJson()]),
    ],
  ),
  prompts: _prompts,
  model: 'm',
);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Widget _app(Widget home, List<Override> overrides, {GoRouter? router}) {
  return ProviderScope(
    overrides: overrides,
    child: router == null
        ? MaterialApp(
            theme: buildMockTheme(Brightness.light),
            locale: const Locale('zh'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: home,
          )
        : MaterialApp.router(
            theme: buildMockTheme(Brightness.light),
            locale: const Locale('zh'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: router,
          ),
  );
}

void main() {
  testWidgets('setup starts a mock session and remembers config', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final sessionRepo = DriftSessionRepository(db);
    final router = GoRouter(
      initialLocation: '/mock/setup',
      routes: <RouteBase>[
        GoRoute(
          path: '/mock/setup',
          builder: (BuildContext context, GoRouterState state) =>
              const MockSetupPage(),
        ),
        GoRoute(
          path: '/mock/live/:id',
          builder: (BuildContext context, GoRouterState state) =>
              Text('LIVE ${state.pathParameters['id']}'),
        ),
      ],
    );
    await tester.pumpWidget(
      _app(const SizedBox(), <Override>[
        databaseProvider.overrideWithValue(db),
        sessionRepositoryProvider.overrideWithValue(sessionRepo),
        sessionRepositoryImplProvider.overrideWithValue(sessionRepo),
      ], router: router),
    );
    await _settle(tester);
    expect(find.text('实战配置'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('开始面试'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('开始面试'));
    await _settle(tester);
    expect(find.textContaining('LIVE'), findsOneWidget);

    final saved = await MockConfigStore(db).load();
    expect(saved?.mode, SessionMode.mock);
    expect((await sessionRepo.activeSession())?.mode, SessionMode.mock);
  });

  testWidgets('live page shows questions and appends the answer', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final sessionRepo = DriftSessionRepository(db);
    final session = await sessionRepo.create(
      const SessionConfig(
        mode: SessionMode.mock,
        role: 'backend',
        level: 'mid',
      ),
    );
    final engine = await _engine();
    await tester.pumpWidget(
      _app(MockLivePage(sessionId: session.id), <Override>[
        databaseProvider.overrideWithValue(db),
        bankRepositoryProvider.overrideWithValue(
          FakeBankRepository(questions: <Question>[_q('a'), _q('b')]),
        ),
        sessionRepositoryProvider.overrideWithValue(sessionRepo),
        sessionRepositoryImplProvider.overrideWithValue(sessionRepo),
        scoringEngineFactoryProvider.overrideWithValue(
          (String id) async => engine,
        ),
      ]),
    );
    await _settle(tester);
    expect(find.textContaining('题目'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, 'answer');
    await tester.tap(find.text('提交回答'));
    await _settle(tester);
    expect(find.text('answer'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('resumes a draft question and keeps prior turns', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final sessionRepo = DriftSessionRepository(db);
    final session = await sessionRepo.create(
      const SessionConfig(
        mode: SessionMode.mock,
        role: 'backend',
        level: 'mid',
      ),
    );
    await sessionRepo.appendAnswer(
      session.id,
      AnswerInput(
        questionId: 'a',
        questionText: '题目 a',
        text: '第一题回答',
        tStartedAt: DateTime.now(),
      ),
    );
    await MockResumeStore(db).save(
      session.id,
      const MockResumeState(
        questionId: 'b',
        questionIndex: 2,
        turnId: 't_resume_1',
        answer: '未提交的草稿',
      ),
    );
    final engine = await _engine();
    await tester.pumpWidget(
      _app(MockLivePage(sessionId: session.id), <Override>[
        databaseProvider.overrideWithValue(db),
        bankRepositoryProvider.overrideWithValue(
          FakeBankRepository(questions: <Question>[_q('a'), _q('b')]),
        ),
        sessionRepositoryProvider.overrideWithValue(sessionRepo),
        sessionRepositoryImplProvider.overrideWithValue(sessionRepo),
        scoringEngineFactoryProvider.overrideWithValue(
          (String id) async => engine,
        ),
      ]),
    );
    await _settle(tester);

    expect(find.textContaining('题目 b'), findsWidgets);
    expect(find.text('未提交的草稿'), findsOneWidget);
    expect(find.text('第一题回答'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('report renders dimensions and per-turn scores', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = DriftSessionRepository(db);

    await db
        .into(db.questions)
        .insert(
          QuestionsCompanion.insert(
            id: 'q1',
            bankVersion: 'v1',
            title: '题目一',
            bodyMd: '',
            topics: const Value('["mysql"]'),
            role: 'backend',
            updatedAt: DateTime.utc(2026),
          ),
        );
    final session = await repo.create(
      const SessionConfig(
        mode: SessionMode.mock,
        role: 'backend',
        level: 'mid',
      ),
    );
    final turn = await repo.appendAnswer(
      session.id,
      AnswerInput(
        questionId: 'q1',
        questionText: '题目一',
        text: 'answer',
        tStartedAt: DateTime.now(),
      ),
    );
    await repo.saveScore(
      turn.id,
      const TurnScore(
        correctness: 4,
        depth: 3,
        structure: 3,
        coverage: 0,
        points: <TurnScorePoint>[TurnScorePoint(point: 'k1', verdict: 'miss')],
      ),
    );
    final report = await repo.finish(session.id);
    expect(report.weakestTopics, <String>['mysql']);
    expect(report.markdown, contains('题目一'));

    await tester.pumpWidget(
      _app(MockReportPage(sessionId: session.id), <Override>[
        sessionRepositoryProvider.overrideWithValue(repo),
        sessionRepositoryImplProvider.overrideWithValue(repo),
      ]),
    );
    await _settle(tester);
    expect(find.text('面试报告'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('题目一'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('题目一'), findsOneWidget);
    expect(find.text('4.0 / 5'), findsWidgets);
    expect(find.text('mysql'), findsOneWidget);
    expect(find.text('7 天计划'), findsOneWidget);
    expect(find.byTooltip('导出 Markdown'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
