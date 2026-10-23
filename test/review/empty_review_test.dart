import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/features/interview/data/drift_session_repository.dart';
import 'package:mockmate/features/review/presentation/review_page.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('empty drill shows a snackbar instead of a modal sheet', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await DriftSessionRepository(db).create(
      const SessionConfig(
        mode: SessionMode.drill,
        role: 'mobile',
        level: 'mid',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildMockTheme(Brightness.light),
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const ReviewPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('练习 ·'));
    await tester.pump();

    expect(find.byType(BottomSheet), findsNothing);
    expect(find.textContaining('这场还没有作答记录'), findsOneWidget);
  });
}
