import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/presentation/question_detail_page.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('opens question detail with related section', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = BankRepositoryImpl(db);
    await repo.upsertQuestions(<Question>[
      Question(
        id: 'q-detail-1',
        bankVersion: 'v1',
        title: 'MySQL 为什么用 B+ 树',
        bodyMarkdown: '正文',
        topics: const <String>['mysql'],
        role: 'backend',
        level: 3,
        difficulty: 3,
        type: QuestionType.knowledge,
        answer: const QuestionAnswer(summary: '答案', keyPoints: <String>['扇出大']),
        source: QuestionSource(
          url: 'https://example.com',
          title: 'src',
          license: 'MIT',
          retrievedAt: DateTime.utc(2026),
        ),
        status: QuestionStatus.verified,
        updatedAt: DateTime.utc(2026),
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          bankRepositoryProvider.overrideWithValue(repo),
          bankRepositoryImplProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: buildMockTheme(Brightness.light),
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const QuestionDetailPage(questionId: 'q-detail-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('MySQL 为什么用 B+ 树'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
