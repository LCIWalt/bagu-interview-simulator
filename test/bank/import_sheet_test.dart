import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/import/bank_import_service.dart';
import 'package:mockmate/features/bank/data/question_local_repository.dart';
import 'package:mockmate/features/bank/presentation/import/bank_import_sheet.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

const String _yaml = '''
id: ui-imp-001
title: "粘贴导入的题目"
topics: [go]
role: backend
level: mid
difficulty: 2
type: knowledge
answer:
  summary: "示例答案"
  keyPoints:
    - "示例评分点"
source:
  url: https://example.com
  title: "src"
  license: MIT
status: community
updatedAt: 2026-10-22
''';

void main() {
  testWidgets('paste -> preview -> import creates a user question', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = BankRepositoryImpl(db);
    final local = QuestionLocalRepository(db);
    final service = BankImportService(repo, local);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          bankRepositoryProvider.overrideWithValue(repo),
          bankImportServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          theme: buildMockTheme(Brightness.light),
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(body: BankImportSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, _yaml);
    await tester.tap(find.text('预览'));
    await tester.pumpAndSettle();
    expect(find.text('粘贴导入的题目'), findsOneWidget);
    expect(find.textContaining('解析到 1 道'), findsOneWidget);

    await tester.tap(find.text('导入 1 道'));
    await tester.pumpAndSettle();
    expect(find.textContaining('导入完成'), findsOneWidget);
    expect((await repo.byId('ui-imp-001'))?.title, '粘贴导入的题目');
    expect((await local.get('ui-imp-001'))?.origin, 'user');
  });
}
