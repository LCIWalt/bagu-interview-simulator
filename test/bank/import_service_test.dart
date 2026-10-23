import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/import/bank_import_service.dart';
import 'package:mockmate/features/bank/data/question_local_repository.dart';

String _yaml(String id, {String title = '导入的题目'}) =>
    '''
id: $id
title: "$title"
topics: [go, concurrency]
role: backend
level: mid
difficulty: 2
type: knowledge
answer:
  summary: "导入答案"
  keyPoints:
    - "导入评分点"
source:
  url: https://example.com
  title: "src"
  license: MIT
status: community
updatedAt: 2026-10-22
''';

void main() {
  late AppDatabase db;
  late BankRepositoryImpl repo;
  late QuestionLocalRepository local;
  late BankImportService service;

  setUp(() {
    db = AppDatabase.memory();
    repo = BankRepositoryImpl(db);
    local = QuestionLocalRepository(db);
    service = BankImportService(repo, local);
  });
  tearDown(() => db.close());

  test('imports a new YAML question as user content and searchable', () async {
    final preview = await service.preview(_yaml('user-imp-001'));
    expect(preview.validCount, 1);
    expect(preview.conflictCount, 0);
    final outcome = await service.commit(
      preview,
      policy: ImportConflictPolicy.skip,
    );
    expect(outcome.created, 1);

    final question = await repo.byId('user-imp-001');
    expect(question?.status, QuestionStatus.user);
    expect(question?.bankVersion, BankImportService.importBankVersion);
    expect((await local.get('user-imp-001'))?.origin, 'user');
    expect(await repo.search(const QuestionQuery(text: '导入的题目')), hasLength(1));
  });

  test('reports invalid documents and imports the valid ones', () async {
    final preview = await service.preview(
      '${_yaml('user-imp-001')}\n---\nid: broken\n',
    );
    expect(preview.items, hasLength(2));
    expect(preview.validCount, 1);
    expect(preview.invalidCount, 1);
    final outcome = await service.commit(
      preview,
      policy: ImportConflictPolicy.skip,
    );
    expect(outcome.created, 1);
    expect(outcome.failed, 1);
  });

  test('previews conflicts and honours skip/merge/overwrite', () async {
    await repo.upsertQuestions(<Question>[
      Question(
        id: 'user-imp-001',
        bankVersion: '2026.10.1',
        title: '原题',
        bodyMarkdown: '原题干',
        topics: const <String>['go'],
        role: 'backend',
        level: 3,
        difficulty: 3,
        type: QuestionType.knowledge,
        answer: const QuestionAnswer(
          summary: '原有答案',
          keyPoints: <String>['kp'],
        ),
        status: QuestionStatus.verified,
        updatedAt: DateTime.utc(2026),
      ),
    ]);
    await local.saveNote('user-imp-001', '我的笔记');

    final preview = await service.preview(_yaml('user-imp-001', title: '导入覆盖'));
    expect(preview.conflictCount, 1);
    expect(preview.items.single.existingTitle, '原题');

    var outcome = await service.commit(
      preview,
      policy: ImportConflictPolicy.skip,
    );
    expect(outcome.skipped, 1);
    expect((await repo.byId('user-imp-001'))?.title, '原题');

    outcome = await service.commit(preview, policy: ImportConflictPolicy.merge);
    expect(outcome.merged, 1);
    expect((await repo.byId('user-imp-001'))?.title, '原题');
    expect((await local.get('user-imp-001'))?.noteMd, contains('我的笔记'));
    expect((await local.get('user-imp-001'))?.noteMd, contains('[导入] 导入答案'));

    outcome = await service.commit(
      preview,
      policy: ImportConflictPolicy.overwrite,
    );
    expect(outcome.overwritten, 1);
    final overwritten = await repo.byId('user-imp-001');
    expect(overwritten?.title, '导入覆盖');
    expect(overwritten?.status, QuestionStatus.user);
    expect((await local.get('user-imp-001'))?.noteMd, contains('我的笔记'));
  });

  test('empty paste produces an empty preview', () async {
    expect((await service.preview('   \n')).isEmpty, isTrue);
  });
}
