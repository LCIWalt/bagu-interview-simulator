import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/search/search_transport.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/import/bank_import_service.dart'
    show ImportConflictPolicy;
import 'package:mockmate/features/bank/data/import_bulk/bulk_import_service.dart';
import 'package:mockmate/features/bank/data/question_local_repository.dart';
import 'package:mockmate/features/bank/data/remote/remote_source_importer.dart';

String yaml(String id) =>
    '''
id: $id
title: "远程题目 $id"
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

class _FakeGitHub implements SearchTransport {
  _FakeGitHub({
    this.license = 'MIT',
    this.status = 200,
    this.treeSize = 100,
    this.content = '',
    this.licenseStatus = 200,
  });

  final String license;
  final int status;
  final int treeSize;
  final String content;
  final int licenseStatus;
  int gets = 0;

  SearchResponse _json(Object body) => SearchResponse(
    statusCode: status,
    body: Stream<List<int>>.value(utf8.encode(jsonEncode(body))),
  );

  @override
  Future<SearchResponse> get(
    Uri url, {
    required Map<String, String> headers,
  }) async {
    gets++;
    if (url.host == 'api.github.com') {
      if (url.path.endsWith('/license')) {
        return SearchResponse(
          statusCode: licenseStatus,
          body: Stream<List<int>>.value(
            utf8.encode(
              jsonEncode(<String, Object?>{
                'license': <String, Object?>{'spdx_id': license},
              }),
            ),
          ),
        );
      }
      if (url.path.endsWith('/git/trees/main')) {
        return _json(<String, Object?>{
          'tree': <Object?>[
            <String, Object?>{
              'path': 'questions/go.yaml',
              'type': 'blob',
              'size': treeSize,
            },
            <String, Object?>{'path': 'README.md', 'type': 'blob', 'size': 10},
          ],
        });
      }
      return _json(<String, Object?>{'default_branch': 'main'});
    }
    return SearchResponse(
      statusCode: status,
      body: Stream<List<int>>.value(utf8.encode(content)),
    );
  }

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
  late AppDatabase db;
  late BankRepositoryImpl repo;
  late QuestionLocalRepository local;

  setUp(() {
    db = AppDatabase.memory();
    repo = BankRepositoryImpl(db);
    local = QuestionLocalRepository(db);
  });
  tearDown(() => db.close());

  GitHubRemoteImporter importer(
    _FakeGitHub transport, {
    int maxFileBytes = 2 * 1024 * 1024,
  }) {
    return GitHubRemoteImporter(
      transport: transport,
      bulk: BulkImportService(repo, local),
      maxFileBytes: maxFileBytes,
    );
  }

  test('previews a licensed repo and imports with origin', () async {
    final transport = _FakeGitHub(
      content: '${yaml('r-1')}\n---\n${yaml('r-2')}',
    );
    final remote = await importer(transport)
        .preview('https://github.com/acme/bank');
    expect(remote.license, 'MIT');
    expect(remote.repo.slug, 'acme/bank');
    expect(remote.valid, 2);
    expect(remote.canImport, isTrue);

    expect(
      await importer(transport)
          .commit(remote, policy: ImportConflictPolicy.skip),
      2,
    );
    expect(await repo.countQuestions(), 2);
    expect((await local.get('r-1'))?.origin, 'github:acme/bank');
  });

  test('rejects non-allowed license and non-GitHub URLs', () async {
    await expectLater(
      importer(_FakeGitHub(license: 'GPL-3.0'))
          .preview('https://github.com/acme/bank'),
      throwsA(isA<RemoteImportFailure>()),
    );
    await expectLater(
      importer(_FakeGitHub()).preview('https://example.com/acme/bank'),
      throwsA(isA<RemoteImportFailure>()),
    );
  });

  test('maps rate limit', () async {
    await expectLater(
      importer(_FakeGitHub(status: 403))
          .preview('https://github.com/acme/bank'),
      throwsA(isA<RemoteImportFailure>()),
    );
  });

  test('rejects missing license', () async {
    final noLicense = _FakeGitHub(licenseStatus: 404);
    await expectLater(
      importer(noLicense).preview('https://github.com/acme/bank'),
      throwsA(isA<RemoteImportFailure>()),
    );
  });

  test('rejects oversized files and invalid rows block import', () async {
    await expectLater(
      importer(
        _FakeGitHub(treeSize: 10),
        maxFileBytes: 5,
      ).preview('https://github.com/acme/bank'),
      throwsA(isA<RemoteImportFailure>()),
    );
    final bad = _FakeGitHub(
      content: yaml('bad-1').replaceAll('keyPoints:', 'keyPoints2:'),
    );
    final preview = await importer(bad)
        .preview('https://raw.githubusercontent.com/acme/bank/main/q.yaml');
    expect(preview.canImport, isFalse);
    await expectLater(
      importer(bad).commit(preview, policy: ImportConflictPolicy.skip),
      throwsA(isA<RemoteImportFailure>()),
    );
  });
}
