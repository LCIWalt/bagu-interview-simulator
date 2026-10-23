import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/import/bank_import_service.dart'
    show ImportConflictPolicy;
import 'package:mockmate/features/bank/data/import_bulk/bulk_import_service.dart';
import 'package:mockmate/features/bank/data/question_local_repository.dart';

String yaml(String id, {String title = '批量题目', String keyPoint = '评分点'}) =>
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
    - "$keyPoint"
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
  late BulkImportService service;

  setUp(() {
    db = AppDatabase.memory();
    repo = BankRepositoryImpl(db);
    local = QuestionLocalRepository(db);
    service = BulkImportService(repo, local);
  });
  tearDown(() => db.close());

  test('imports multi-document YAML', () async {
    final preview = await service.preview(
      '${yaml('b-1')}\n---\n${yaml('b-2')}',
    );
    expect(preview.format, BulkFormat.yaml);
    expect(preview.validCount, 2);
    final outcome = await service.commit(
      preview,
      policy: ImportConflictPolicy.skip,
    );
    expect(outcome.created, 2);
    expect(await repo.countQuestions(), 2);
  });

  test('JSON array validates rows and reports invalid ones', () async {
    final content = '''
[
  {"id":"j-1","title":"JSON 题","topics":["go"],"role":"backend","level":"mid","difficulty":2,"type":"knowledge",
   "answer":{"summary":"s","keyPoints":["kp"]},"source":{"url":"https://example.com","title":"s","license":"MIT"},"status":"community","updatedAt":"2026-10-22"},
  {"id":"j-2","title":"坏题","topics":["go"],"role":"backend","level":"mid","difficulty":2,"type":"knowledge",
   "answer":{"summary":"s","keyPoints":[]},"source":{"url":"https://example.com","title":"s","license":"MIT"},"status":"community","updatedAt":"2026-10-22"}
]
''';
    final preview = await service.preview(content);
    expect(preview.format, BulkFormat.json);
    expect(
      preview.validCount,
      1,
      reason: preview.items.expand((BulkImportItem i) => i.issues).join('\n'),
    );
    expect(preview.invalidCount, 1);
    final outcome = await service.commit(
      preview,
      policy: ImportConflictPolicy.skip,
    );
    expect(outcome.failed, 2);
    expect(await repo.countQuestions(), 0);
  });

  test('CSV imports 100 rows under 5 seconds', () async {
    final header =
        'id,title,topics,role,level,difficulty,type,summary,keyPoints,sourceUrl,sourceTitle,license,status,updatedAt';
    final rows = <String>[
      for (var i = 0; i < 100; i++)
        'c-$i,"CSV 题目 $i",go|runtime,backend,mid,3,knowledge,答案 $i,kp1|kp2,https://example.com,src,MIT,community,2026-10-22',
    ];
    final preview = await service.preview('$header\n${rows.join('\n')}');
    expect(preview.format, BulkFormat.csv);
    expect(
      preview.validCount,
      100,
      reason: preview.items
          .expand((BulkImportItem i) => i.issues)
          .take(3)
          .join('\n'),
    );
    final watch = Stopwatch()..start();
    final outcome = await service.commit(
      preview,
      policy: ImportConflictPolicy.skip,
    );
    watch.stop();
    expect(outcome.created, 100);
    expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
    expect(await repo.countQuestions(), 100);
    final one = await repo.byId('c-42');
    expect(one?.topics, <String>['go', 'runtime']);
    expect(one?.answer.keyPoints, <String>['kp1', 'kp2']);
  });

  test('Markdown heading blocks import', () async {
    final content = '''
## 标题一
topics: go, runtime
role: backend
level: senior
difficulty: 4
type: knowledge
summary: 答案一
keyPoints:
- 评分点一
- 评分点二
sourceUrl: https://example.com
sourceTitle: src
license: MIT
status: community
''';
    final preview = await service.preview(content);
    expect(preview.format, BulkFormat.markdown);
    expect(preview.validCount, 1);
    final outcome = await service.commit(
      preview,
      policy: ImportConflictPolicy.skip,
    );
    expect(outcome.created, 1);
    final question = await repo.search(const QuestionQuery(text: '标题一'));
    expect(question.single.answer.keyPoints, hasLength(2));
  });

  test('honours skip and overwrite for id conflicts', () async {
    final preview = await service.preview(yaml('conf-1', title: '导入标题'));
    await service.commit(preview, policy: ImportConflictPolicy.skip);

    final second = await service.preview(
      yaml('conf-1', title: '覆盖标题', keyPoint: '新点'),
    );
    expect(second.items.single.existingTitle, '导入标题');
    final skipped = await service.commit(
      second,
      policy: ImportConflictPolicy.skip,
    );
    expect(skipped.skipped, 1);
    expect((await repo.byId('conf-1'))?.title, '导入标题');

    final overwritten = await service.commit(
      second,
      policy: ImportConflictPolicy.overwrite,
    );
    expect(overwritten.created, 1);
    expect((await repo.byId('conf-1'))?.title, '覆盖标题');
  });
}
