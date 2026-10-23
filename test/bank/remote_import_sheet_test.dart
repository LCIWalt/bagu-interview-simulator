import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/core/search/search_transport.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/import_bulk/bulk_import_service.dart';
import 'package:mockmate/features/bank/data/question_local_repository.dart';
import 'package:mockmate/features/bank/data/remote/remote_source_importer.dart';
import 'package:mockmate/features/bank/presentation/import/remote_import_sheet.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

const String _yaml = '''
id: remote-ui-1
title: "远程 UI 题"
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

class _Transport implements SearchTransport {
  @override
  Future<SearchResponse> get(
    Uri url, {
    required Map<String, String> headers,
  }) async {
    if (url.path.endsWith('/license')) {
      return _json(<String, Object?>{
        'license': <String, Object?>{'spdx_id': 'MIT'},
      });
    }
    if (url.path.endsWith('/git/trees/main')) {
      return _json(<String, Object?>{
        'tree': <Object?>[
          <String, Object?>{'path': 'q.yaml', 'type': 'blob', 'size': 100},
        ],
      });
    }
    if (url.host == 'api.github.com') {
      return _json(<String, Object?>{'default_branch': 'main'});
    }
    return SearchResponse(
      statusCode: 200,
      body: Stream<List<int>>.value(utf8.encode(_yaml)),
    );
  }

  SearchResponse _json(Object body) => SearchResponse(
    statusCode: 200,
    body: Stream<List<int>>.value(utf8.encode(jsonEncode(body))),
  );

  @override
  Future<SearchResponse> postJson(
    Uri url, {
    required Map<String, String> headers,
    required Map<String, Object?> body,
  }) async => _json(<String, Object?>{});

  @override
  void close() {}
}

void main() {
  testWidgets('remote sheet previews and imports a licensed repo', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = BankRepositoryImpl(db);
    final local = QuestionLocalRepository(db);
    final importer = GitHubRemoteImporter(
      transport: _Transport(),
      bulk: BulkImportService(repo, local),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          githubRemoteImporterProvider.overrideWithValue(importer),
        ],
        child: MaterialApp(
          theme: buildMockTheme(Brightness.light),
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(body: RemoteImportSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'https://github.com/acme/bank',
    );
    await tester.tap(find.text('获取预览'));
    await tester.pumpAndSettle();
    expect(find.text('acme/bank · 许可证：MIT'), findsOneWidget);

    await tester.tap(find.text('导入 1 道'));
    await tester.pumpAndSettle();
    expect(await repo.countQuestions(), 1);
    expect((await local.get('remote-ui-1'))?.origin, 'github:acme/bank');
  });
}
