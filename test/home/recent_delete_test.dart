import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/features/home/presentation/home_page.dart';
import 'package:mockmate/features/interview/data/drift_session_repository.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('long-press selects recent sessions and deletes them', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = DriftSessionRepository(db);
    for (var i = 0; i < 2; i++) {
      await repo.create(
        const SessionConfig(
          mode: SessionMode.drill,
          role: 'mobile',
          level: 'mid',
        ),
      );
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildMockTheme(Brightness.light),
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cards = find.textContaining('drill ·');
    expect(cards, findsNWidgets(2));

    await tester.longPress(cards.first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(cards.last);
    await tester.pumpAndSettle();
    expect(find.textContaining('已选 2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(find.textContaining('还没有练习记录'), findsOneWidget);
    expect(await db.select(db.sessions).get(), isEmpty);
  });
}
