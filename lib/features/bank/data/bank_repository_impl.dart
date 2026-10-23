import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';

import 'package:mockmate/core/settings/repositories.dart'
    show decodeFloat32, encodeFloat32;

import 'bank_manifest_codec.dart';
import 'question_store.dart';
import 'update/bank_update_runner.dart';

class TopicCount {
  const TopicCount({required this.topic, required this.count});

  final String topic;
  final int count;
}

/// 题库读取与检索：FTS5 trigram + 结构化过滤 + 分页，用户覆盖层永不覆盖。
class BankRepositoryImpl implements BankRepository {
  BankRepositoryImpl(this._db);

  final AppDatabase _db;

  /// 由 T-016 的更新服务注入；未注入时 update() 明确失败。
  BankUpdateRunner? updateRunner;

  static const String installedManifestKey = 'bank.installedManifest';

  @override
  Future<BankManifest?> installed() async {
    final row =
        await (_db.select(_db.settings)
              ..where((Settings t) => t.key.equals(installedManifestKey)))
            .getSingleOrNull();
    if (row == null) return null;
    try {
      final decoded = jsonDecode(row.value);
      if (decoded is! Map<String, dynamic>) return null;
      return BankManifestCodec.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  @override
  Stream<BankUpdateProgress> update({
    required BankChannel channel,
    bool force = false,
  }) async* {
    final runner = updateRunner;
    if (runner == null) {
      yield const BankUpdateFailed(UnknownFailure('题库更新管线未配置'));
      return;
    }
    yield* runner.run(channel: channel, force: force);
  }

  @override
  Future<List<Question>> search(QuestionQuery q) async {
    final where = <String>['COALESCE(l.hidden, 0) = 0'];
    final variables = <Variable<Object>>[];
    final hasText = q.text.trim().isNotEmpty;
    if (hasText) {
      where.add('fts_questions MATCH ?');
      variables.add(
        Variable<String>('"${q.text.trim().replaceAll('"', '""')}"'),
      );
    }
    if (q.role != null && q.role!.isNotEmpty) {
      where.add('q.role = ?');
      variables.add(Variable<String>(q.role!));
    }
    if (q.level != null) {
      where.add('q.level = ?');
      variables.add(Variable<int>(q.level!));
    }
    if (q.difficulty != null) {
      where.add('q.difficulty = ?');
      variables.add(Variable<int>(q.difficulty!));
    }
    for (final topic in q.topics) {
      where.add('q.topics LIKE ?');
      variables.add(Variable<String>('%"$topic"%'));
    }
    if (q.statuses.isNotEmpty) {
      final placeholders = List<String>.filled(
        q.statuses.length,
        '?',
      ).join(', ');
      where.add('q.status IN ($placeholders)');
      for (final status in q.statuses) {
        variables.add(Variable<String>(QuestionStore.encodeStatus(status)));
      }
    } else {
      where.add("q.status != 'orphaned'");
    }
    variables
      ..add(Variable<int>(q.limit))
      ..add(Variable<int>(q.offset));

    final from = hasText
        ? 'FROM fts_questions f JOIN questions q ON q.rowid = f.rowid '
        : 'FROM questions q ';
    final order = hasText
        ? 'bm25(fts_questions), q.updated_at DESC'
        : 'q.updated_at DESC, q.id';
    final sql =
        'SELECT q.* $from'
        'LEFT JOIN question_local l ON l.question_id = q.id '
        'WHERE ${where.join(' AND ')} ORDER BY $order LIMIT ? OFFSET ?';

    final rows = await _db
        .customSelect(
          sql,
          variables: variables,
          readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
            _db.questions,
            _db.questionLocal,
          },
        )
        .get();
    return rows
        .map(
          (QueryRow row) => QuestionStore.toDomain(_db.questions.map(row.data)),
        )
        .toList(growable: false);
  }

  @override
  Future<Question?> byId(String id) async {
    final row = await (_db.select(
      _db.questions,
    )..where((Questions t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : QuestionStore.toDomain(row);
  }

  /// 批量 upsert（种子题库/导入/更新共用）。`question_local` 不动。
  Future<void> upsertQuestions(List<Question> questions) async {
    if (questions.isEmpty) return;
    await _db.transaction(() => _upsert(questions));
  }

  /// 更新管线专用：题库 upsert + orphan 标记 + manifest 记录同一事务。
  /// 任一步失败整体回滚，`question_local` 永不被触碰。
  Future<void> applyUpdate({
    required List<Question> questions,
    required BankManifest manifest,
    required String activeDir,
  }) async {
    await _db.transaction(() async {
      await _upsert(questions);
      await markOrphaned(
        questions.map((Question q) => q.id).toSet(),
        bankVersion: manifest.bankVersion,
      );
      await recordInstalledManifest(
        manifest,
        activeDir: activeDir,
        signatureOk: true,
      );
    });
  }

  Future<void> _upsert(List<Question> questions) async {
    for (final question in questions) {
      await _db
          .into(_db.questions)
          .insertOnConflictUpdate(QuestionStore.toCompanion(question));
    }
  }

  /// 题库更新/删除时标记 orphaned（不物理删除，保留用户笔记）。
  Future<void> markOrphaned(
    Set<String> keepIds, {
    required String bankVersion,
  }) async {
    final rows = await _db.select(_db.questions).get();
    for (final row in rows) {
      if (row.bankVersion == bankVersion || keepIds.contains(row.id)) continue;
      if (row.status == 'user') continue; // 用户题库永不因上游更新下线
      await (_db.update(_db.questions)
            ..where((Questions t) => t.id.equals(row.id)))
          .write(const QuestionsCompanion(status: Value('orphaned')));
    }
  }

  Future<int> countQuestions() async {
    final count = _db.questions.id.count();
    final query = _db.selectOnly(_db.questions)
      ..addColumns(<Expression<Object>>[count]);
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// 安装/升级内置种子题库时记录 manifest（设置表，非敏感）。
  Future<void> recordInstalledManifest(
    BankManifest manifest, {
    required String activeDir,
    bool signatureOk = false,
  }) async {
    await _db
        .into(_db.bankMeta)
        .insertOnConflictUpdate(
          BankMetaCompanion.insert(
            id: const Value(1),
            activeDir: Value(activeDir),
            version: Value(manifest.bankVersion),
            commit: Value(manifest.gitCommit),
            installedAt: Value(DateTime.now()),
            signatureOk: Value(signatureOk),
          ),
        );
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: installedManifestKey,
            value: jsonEncode(manifest.toJson()),
            updatedAt: DateTime.now(),
          ),
        );
  }
}

extension BankTopics on BankRepositoryImpl {
  /// 角色 → 主题计数（分类树），排除隐藏与 orphaned。
  Future<Map<String, List<TopicCount>>> topicsByRole() async {
    final rows = await _db
        .customSelect(
          'SELECT q.role AS role, j.value AS topic, COUNT(*) AS c '
          'FROM questions q, json_each(q.topics) j '
          'WHERE q.status != \'orphaned\' '
          'AND COALESCE((SELECT hidden FROM question_local l WHERE l.question_id = q.id), 0) = 0 '
          'GROUP BY q.role, j.value ORDER BY q.role, c DESC',
          readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
            _db.questions,
            _db.questionLocal,
          },
        )
        .get();
    final result = <String, List<TopicCount>>{};
    for (final row in rows) {
      final role = row.data['role']?.toString() ?? '';
      final topic = row.data['topic']?.toString() ?? '';
      final count = (row.data['c'] as int?) ?? 0;
      if (topic.isEmpty) continue;
      result
          .putIfAbsent(role, () => <TopicCount>[])
          .add(TopicCount(topic: topic, count: count));
    }
    return result;
  }
}

extension BankEmbeddings on BankRepositoryImpl {
  Future<void> upsertEmbedding({
    required String questionId,
    required String model,
    required int dim,
    required List<double> vector,
  }) async {
    await _db
        .into(_db.questionEmbeddings)
        .insertOnConflictUpdate(
          QuestionEmbeddingsCompanion.insert(
            questionId: questionId,
            model: model,
            dim: dim,
            vec: encodeFloat32(vector),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<Map<String, List<double>>> loadEmbeddings(String model) async {
    final rows = await (_db.select(
      _db.questionEmbeddings,
    )..where((QuestionEmbeddings t) => t.model.equals(model))).get();
    return <String, List<double>>{
      for (final row in rows) row.questionId: decodeFloat32(row.vec),
    };
  }

  Future<List<QuestionRow>> questionsForIndex({int limit = 5000}) async {
    return (_db.select(_db.questions)
          ..where((Questions t) => t.status.isNotValue('orphaned'))
          ..limit(limit))
        .get();
  }
}

extension BankBatchImport on BankRepositoryImpl {
  /// T-021：批量写入单事务；同时标记 question_local.origin=user。
  Future<void> importBatch(
    List<Question> questions, {
    String origin = 'user',
  }) async {
    if (questions.isEmpty) return;
    await _db.transaction(() async {
      for (final question in questions) {
        await _db
            .into(_db.questions)
            .insertOnConflictUpdate(QuestionStore.toCompanion(question));
        await _db
            .into(_db.questionLocal)
            .insertOnConflictUpdate(
              QuestionLocalCompanion.insert(
                questionId: question.id,
                origin: Value(origin),
                updatedAt: DateTime.now(),
              ),
            );
      }
    });
  }
}
