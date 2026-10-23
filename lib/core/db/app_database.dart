import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// 非敏感配置：[key] → JSON/纯文本。
@DataClassName('Setting')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

/// provider 配置；密钥本体在 secure storage，`key_ref` 只是别名。
@DataClassName('ProviderRow')
class Providers extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get baseUrl => text()();
  TextColumn get modelMap => text().withDefault(const Constant('{}'))();
  TextColumn get keyRef => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// 题库只读镜像。`answer_json` 为 v0.5 追加列（答案/评分点），只加不删。
@DataClassName('QuestionRow')
class Questions extends Table {
  TextColumn get id => text()();
  TextColumn get bankVersion => text()();
  TextColumn get title => text()();
  TextColumn get bodyMd => text()();
  TextColumn get topics => text().withDefault(const Constant('[]'))();
  TextColumn get role => text()();
  IntColumn get level => integer().withDefault(const Constant(3))();
  IntColumn get difficulty => integer().withDefault(const Constant(3))();
  TextColumn get type => text().withDefault(const Constant('knowledge'))();
  TextColumn get answerJson => text().withDefault(const Constant('{}'))();
  TextColumn get followupsJson => text().withDefault(const Constant('[]'))();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get license => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('community'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// 用户覆盖层：题库更新永不覆盖此表。
@DataClassName('QuestionLocalRow')
class QuestionLocal extends Table {
  TextColumn get questionId => text()();
  TextColumn get noteMd => text().withDefault(const Constant(''))();
  BoolColumn get starred => boolean().withDefault(const Constant(false))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();

  /// `bank`（覆盖上游）或 `user`（用户自建，指南 §7.1.1）。
  TextColumn get origin => text().withDefault(const Constant('bank'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{questionId};
}

@DataClassName('Experience')
class Experiences extends Table {
  TextColumn get id => text()();
  TextColumn get company => text().withDefault(const Constant(''))();
  TextColumn get role => text().withDefault(const Constant(''))();
  TextColumn get round => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get summaryMd => text().withDefault(const Constant(''))();
  TextColumn get questionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get credibility => text().withDefault(const Constant('unknown'))();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get mode => text()();
  TextColumn get configJson => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  RealColumn get totalScore => real().nullable()();
  RealColumn get cost => real().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('TurnRow')
class Turns extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get seq => integer()();
  TextColumn get questionId => text().nullable()();
  TextColumn get questionText => text().withDefault(const Constant(''))();
  TextColumn get answerText => text().withDefault(const Constant(''))();
  DateTimeColumn get tStartedAt => dateTime()();
  DateTimeColumn get tSubmittedAt => dateTime()();
  TextColumn get scoreJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('MessageRow')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get toolCalls => text().nullable()();
  IntColumn get tokens => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('SessionMemoryRow')
class SessionMemory extends Table {
  TextColumn get sessionId =>
      text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get memoryJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{sessionId};
}

@DataClassName('SessionScore')
class SessionScores extends Table {
  TextColumn get sessionId =>
      text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get aggregateJson => text()();
  TextColumn get rubricVersion => text()();
  TextColumn get model => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{sessionId};
}

@DataClassName('SearchCacheRow')
class SearchCache extends Table {
  TextColumn get urlHash => text()();
  TextColumn get url => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get textMd => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  IntColumn get ttlS => integer().withDefault(const Constant(86400))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{urlHash};
}

@DataClassName('FactCheck')
class FactChecks extends Table {
  TextColumn get claimHash => text()();
  TextColumn get claim => text()();
  TextColumn get verdict => text()();
  RealColumn get confidence => real().withDefault(const Constant(0))();
  TextColumn get sourcesJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get checkedAt => dateTime()();
  IntColumn get ttlS => integer().withDefault(const Constant(2592000))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{claimHash};
}

@DataClassName('DocSource')
class DocSources extends Table {
  TextColumn get domain => text()();
  TextColumn get authority => text().withDefault(const Constant('c'))();
  DateTimeColumn get lastOkAt => dateTime().nullable()();
  BoolColumn get blocked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{domain};
}

@DataClassName('QuestionEmbeddingRow')
class QuestionEmbeddings extends Table {
  TextColumn get questionId => text()();
  TextColumn get model => text()();
  IntColumn get dim => integer()();
  BlobColumn get vec => blob()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{questionId, model};
}

@DataClassName('QuestionEdgeRow')
class QuestionEdges extends Table {
  TextColumn get src => text()();
  TextColumn get dst => text()();

  /// similar | followup | prerequisite | variant | contrast | cluster
  TextColumn get kind => text()();
  RealColumn get weight => real().withDefault(const Constant(1))();
  TextColumn get source => text().withDefault(const Constant('auto'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{src, dst, kind};
}

@DataClassName('ClusterMember')
class ClusterMembers extends Table {
  TextColumn get clusterId => text()();
  TextColumn get questionId => text()();
  TextColumn get label => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{clusterId, questionId};
}

@DataClassName('BankSource')
class BankSources extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get url => text()();
  TextColumn get license => text().withDefault(const Constant('unknown'))();
  DateTimeColumn get lastSync => dateTime().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('LlmCall')
class LlmCalls extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get role => text()();
  TextColumn get provider => text()();
  TextColumn get model => text()();
  IntColumn get tokensIn => integer().withDefault(const Constant(0))();
  IntColumn get tokensOut => integer().withDefault(const Constant(0))();
  IntColumn get latencyMs => integer().withDefault(const Constant(0))();
  RealColumn get cost => real().withDefault(const Constant(0))();
  TextColumn get error => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('BankMetaRow')
class BankMeta extends Table {
  TextColumn get activeDir => text().withDefault(const Constant(''))();
  TextColumn get version => text().withDefault(const Constant(''))();
  TextColumn get commit => text().withDefault(const Constant(''))();
  DateTimeColumn get installedAt => dateTime().nullable()();
  BoolColumn get signatureOk => boolean().withDefault(const Constant(false))();
  IntColumn get id => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(
  tables: <Type>[
    Settings,
    Providers,
    Questions,
    QuestionLocal,
    Experiences,
    Sessions,
    Turns,
    Messages,
    SessionMemory,
    SessionScores,
    SearchCache,
    FactChecks,
    DocSources,
    QuestionEmbeddings,
    QuestionEdges,
    ClusterMembers,
    BankSources,
    LlmCalls,
    BankMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// 生产环境：应用支持目录下的 sqlite 文件。
  factory AppDatabase.open() => AppDatabase(_openDefault());

  /// 测试专用：内存库。
  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createFts();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // v1 是基线；后续迁移按 `from` 逐级升级（只加列）。
      await _createFts();
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) return;
      await _createFts();
    },
  );

  Future<void> _createFts() async {
    await customStatement(
      'CREATE VIRTUAL TABLE IF NOT EXISTS fts_questions USING fts5('
      "title, body, tags, tokenize='trigram')",
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS questions_ai AFTER INSERT ON questions BEGIN '
      'INSERT INTO fts_questions(rowid, title, body, tags) '
      'VALUES (new.rowid, new.title, new.body_md, new.topics); END',
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS questions_ad AFTER DELETE ON questions BEGIN '
      'DELETE FROM fts_questions WHERE rowid = old.rowid; END',
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS questions_au AFTER UPDATE ON questions BEGIN '
      'DELETE FROM fts_questions WHERE rowid = old.rowid; '
      'INSERT INTO fts_questions(rowid, title, body, tags) '
      'VALUES (new.rowid, new.title, new.body_md, new.topics); END',
    );
  }

  /// FTS5 trigram 关键词检索。中文必须用 trigram（`unicode61` 无效）。
  Future<List<QuestionRow>> searchFts(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return <QuestionRow>[];
    // 用双引号包成 phrase，避免用户输入被当成 FTS 语法。
    final phrase = '"${trimmed.replaceAll('"', '""')}"';
    final rows = await customSelect(
      'SELECT q.* FROM fts_questions f JOIN questions q ON q.rowid = f.rowid '
      'WHERE fts_questions MATCH ? ORDER BY bm25(fts_questions) LIMIT ? OFFSET ?',
      variables: <Variable<Object>>[
        Variable<String>(phrase),
        Variable<int>(limit),
        Variable<int>(offset),
      ],
      readsFrom: <ResultSetImplementation<dynamic, dynamic>>{questions},
    ).get();
    return rows
        .map((QueryRow row) => questions.map(row.data))
        .toList(growable: false);
  }

  /// 重建 FTS 索引（题库批量导入后调用）。
  Future<void> rebuildFts() async {
    await customStatement(
      "INSERT INTO fts_questions(fts_questions) VALUES ('rebuild')",
    );
  }
}

QueryExecutor _openDefault() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'mockmate.sqlite'));
    await file.parent.create(recursive: true);
    // NOTE: macOS 沙箱 + sqlite3 3.52 在 DartWorker 后台 isolate 中偶发 SIGSEGV
    // （题库详情/配置保存均复现）。先回退到主 isolate，稳定性优先；
    // 2000 题量级若出现卡顿，再评估 isolate + 独立 sqlite3 连接。
    return NativeDatabase(file);
  });
}
