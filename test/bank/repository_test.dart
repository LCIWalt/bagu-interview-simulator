import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/question_local_repository.dart';

Question _question(
  int index, {
  String role = 'backend',
  int difficulty = 3,
  QuestionStatus status = QuestionStatus.verified,
  List<String> topics = const <String>['mysql', 'index'],
  String title = '',
}) {
  return Question(
    id: 'q-${index.toString().padLeft(3, '0')}',
    bankVersion: '2026.10.1',
    title: title.isEmpty ? '数据库索引优化 第 $index 题' : title,
    bodyMarkdown: '数据库索引与并发控制',
    topics: topics,
    role: role,
    level: 3,
    difficulty: difficulty,
    type: QuestionType.knowledge,
    answer: const QuestionAnswer(
      summary: 'summary',
      keyPoints: <String>['kp1', 'kp2'],
    ),
    source: const QuestionSource(
      url: 'https://example.com',
      title: 'source',
      license: 'MIT',
    ),
    status: status,
    updatedAt: DateTime.utc(2026),
  );
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

  test('searches with FTS and paginates', () async {
    await repo.upsertQuestions(List<Question>.generate(25, _question));

    final first = await repo.search(
      const QuestionQuery(text: '数据库索引', limit: 10),
    );
    expect(first, hasLength(10));
    final second = await repo.search(
      const QuestionQuery(text: '数据库索引', limit: 10, offset: 10),
    );
    expect(second, hasLength(10));
    expect(
      first
          .map((Question q) => q.id)
          .toSet()
          .intersection(second.map((Question q) => q.id).toSet()),
      isEmpty,
    );
  });

  test('applies role/difficulty/topic/status filters', () async {
    await repo.upsertQuestions(<Question>[
      _question(1, difficulty: 2),
      _question(
        2,
        role: 'frontend',
        difficulty: 5,
        topics: const <String>['react'],
      ),
      _question(3, status: QuestionStatus.orphaned),
    ]);

    expect(
      (await repo.search(const QuestionQuery(role: 'frontend'))).single.id,
      'q-002',
    );
    expect(
      (await repo.search(const QuestionQuery(difficulty: 2))).single.id,
      'q-001',
    );
    expect(
      (await repo.search(const QuestionQuery(topics: <String>['react'])))
          .single
          .id,
      'q-002',
    );
    expect(
      await repo.search(const QuestionQuery()),
      hasLength(2),
    ); // orphaned 默认隐藏
    expect(
      (await repo.search(
        const QuestionQuery(
          statuses: <QuestionStatus>[QuestionStatus.orphaned],
        ),
      )).single.id,
      'q-003',
    );
  });

  test('hidden questions disappear from search but byId still works', () async {
    await repo.upsertQuestions(<Question>[_question(1), _question(2)]);
    await local.setHidden('q-001', true);
    final results = await repo.search(const QuestionQuery());
    expect(results.map((Question q) => q.id), <String>['q-002']);
    expect((await repo.byId('q-001'))?.id, 'q-001');
  });

  test('upsert never overwrites user notes/starred/hidden', () async {
    await repo.upsertQuestions(<Question>[_question(1)]);
    await local.saveNote('q-001', '我的笔记');
    await local.setStarred('q-001', true);

    await repo.upsertQuestions(<Question>[_question(1, title: '更新后的标题')]);

    final row = await local.get('q-001');
    expect(row?.noteMd, '我的笔记');
    expect(row?.starred, isTrue);
    final question = await repo.byId('q-001');
    expect(question?.title, '更新后的标题');
    expect(await local.starredIds(), <String>['q-001']);
  });

  test('200 questions + FTS stays under the 50ms p95 budget', () async {
    await repo.upsertQuestions(List<Question>.generate(200, _question));
    final samples = <int>[];
    for (var i = 0; i < 20; i++) {
      final watch = Stopwatch()..start();
      final results = await repo.search(const QuestionQuery(text: '数据库索引'));
      watch.stop();
      expect(results, isNotEmpty);
      samples.add(watch.elapsedMicroseconds);
    }
    samples.sort();
    final p95 = samples[(samples.length * 0.95).ceil() - 1];
    expect(p95, lessThan(50 * 1000), reason: 'p95=${p95}us');
  });

  test(
    'manifest is recorded and read back; update reports unimplemented',
    () async {
      expect(await repo.installed(), isNull);
      final manifest = BankManifest(
        schemaVersion: 1,
        bankVersion: '2026.10.1',
        minAppVersion: '0.5.0',
        generatedAt: DateTime.utc(2026),
        gitCommit: 'seed',
        questionCount: 1,
        experienceCount: 0,
        files: const <BankFileEntry>[],
        assets: const <BankAsset>[],
        signature: 'ed25519:seed-dev',
      );
      await repo.recordInstalledManifest(
        manifest,
        activeDir: 'assets/bank_seed',
      );
      expect((await repo.installed())?.bankVersion, '2026.10.1');

      final events = await repo.update(channel: BankChannel.stable).toList();
      expect(events.single, isA<BankUpdateFailed>());
    },
  );
}
