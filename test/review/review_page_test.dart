import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/features/interview/data/drift_session_repository.dart';
import 'package:mockmate/features/review/presentation/review_page.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('lists drill sessions and opens per-question review', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = DriftSessionRepository(db);
    final session = await repo.create(
      const SessionConfig(
        mode: SessionMode.drill,
        role: 'mobile',
        level: 'mid',
      ),
    );
    final turn = await repo.appendAnswer(
      session.id,
      AnswerInput(
        id: 'review-turn-1',
        questionId: 'mo-flutter-101',
        questionText: '布局约束如何传递？',
        text: '父级约束向下传递，子级决定自己的大小。',
        tStartedAt: DateTime.utc(2026, 10, 23),
      ),
    );
    await repo.saveScore(
      turn.id,
      const TurnScore(correctness: 4, depth: 3, structure: 3, coverage: 0.5),
    );

    final router = GoRouter(
      initialLocation: '/review',
      routes: <RouteBase>[
        GoRoute(
          path: '/review',
          builder: (BuildContext context, GoRouterState state) =>
              const ReviewPage(),
        ),
        GoRoute(
          path: '/mock/report/:id',
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Text('REPORT')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(
          theme: buildMockTheme(Brightness.light),
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('练习 ·'), findsOneWidget);
    expect(find.textContaining('1 题'), findsOneWidget);
    await tester.tap(find.textContaining('练习 ·'));
    await tester.pumpAndSettle();

    expect(find.textContaining('布局约束如何传递'), findsOneWidget);
    expect(find.text('得分 3.5'), findsOneWidget);
  });
}
