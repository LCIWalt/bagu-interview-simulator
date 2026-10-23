import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/presentation/edit/question_edit_page.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('creates a user question searchable immediately', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = BankRepositoryImpl(db);
    final router = GoRouter(
      initialLocation: '/bank',
      routes: <RouteBase>[
        GoRoute(
          path: '/bank',
          builder: (BuildContext context, GoRouterState state) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => context.push('/bank/new'),
                child: const Text('BANK LIST'),
              ),
            ),
          ),
          routes: <RouteBase>[
            GoRoute(
              path: 'new',
              builder: (BuildContext context, GoRouterState state) =>
                  const QuestionEditPage(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          bankRepositoryImplProvider.overrideWithValue(repo),
        ],
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
    await tester.tap(find.text('BANK LIST'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '我的新题目');
    await tester.enterText(fields.at(2), 'go, runtime');
    await tester.enterText(fields.at(3), '这是参考答案');
    await tester.enterText(fields.at(4), '评分点一\n评分点二');
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('保存到我的题库'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('保存到我的题库'));
    await tester.pumpAndSettle();

    final created = await repo.search(const QuestionQuery(text: '我的新题目'));
    expect(created, hasLength(1));
    expect(created.single.status, QuestionStatus.user);
    expect(created.single.answer.keyPoints, <String>['评分点一', '评分点二']);
    expect(find.text('BANK LIST'), findsOneWidget);
  });
}
