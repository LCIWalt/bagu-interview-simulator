import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/import_bulk/bulk_import_service.dart';
import 'package:mockmate/features/bank/data/question_local_repository.dart';
import 'package:mockmate/features/bank/presentation/import/bulk_import_sheet.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

String yaml(String id, String title) =>
    '''
id: $id
title: "$title"
topics: [go]
role: backend
level: mid
difficulty: 3
type: knowledge
answer:
  summary: "答案"
  keyPoints:
    - "评分点"
source:
  url: https://example.com
  title: "src"
  license: MIT
status: community
updatedAt: 2026-10-22
''';

void main() {
  testWidgets('bulk sheet previews and imports multiple rows', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = BankRepositoryImpl(db);
    final service = BulkImportService(repo, QuestionLocalRepository(db));

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          bulkImportServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          theme: buildMockTheme(Brightness.light),
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(body: BulkImportSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      '${yaml('ui-b-1', '批量一')}\n---\n${yaml('ui-b-2', '批量二')}',
    );
    await tester.tap(find.text('预览'));
    await tester.pumpAndSettle();
    expect(find.text('批量一'), findsOneWidget);
    expect(find.text('批量二'), findsOneWidget);
    expect(find.textContaining('有效 2'), findsOneWidget);

    await tester.tap(find.text('导入 2 道'));
    await tester.pumpAndSettle();
    expect(find.textContaining('导入完成'), findsOneWidget);
    expect(await repo.countQuestions(), 2);
  });
}
