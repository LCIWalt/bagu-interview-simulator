import 'package:mockmate/core/contracts/contracts.dart';

import '../bank_parser.dart';
import '../bank_repository_impl.dart';
import '../question_local_repository.dart';

enum ImportConflictPolicy { skip, overwrite, merge }

enum ImportAction { create, overwrite, merge, skip }

class ImportPreviewItem {
  const ImportPreviewItem({
    required this.index,
    required this.sourceLabel,
    this.question,
    this.issues = const <String>[],
    this.existingTitle,
  });

  final int index;
  final String sourceLabel;
  final Question? question;
  final List<String> issues;
  final String? existingTitle;

  bool get valid => question != null && issues.isEmpty;
  bool get conflict => existingTitle != null;
}

class ImportPreview {
  const ImportPreview({required this.items});

  final List<ImportPreviewItem> items;

  int get validCount =>
      items.where((ImportPreviewItem item) => item.valid).length;
  int get conflictCount => items
      .where((ImportPreviewItem item) => item.valid && item.conflict)
      .length;
  int get invalidCount =>
      items.where((ImportPreviewItem item) => !item.valid).length;
  bool get isEmpty => items.isEmpty;
}

class ImportOutcome {
  const ImportOutcome({
    this.created = 0,
    this.overwritten = 0,
    this.merged = 0,
    this.skipped = 0,
    this.failed = 0,
  });

  final int created;
  final int overwritten;
  final int merged;
  final int skipped;
  final int failed;

  int get total => created + overwritten + merged + skipped + failed;
}

/// 粘贴/单文件导入（T-018）。支持多文档 YAML（`---` 分隔）。
///
/// - 新题以 `status: user`、`bankVersion: user-import` 入库，并写 `question_local.origin=user`；
/// - 冲突按 [ImportConflictPolicy] 跳过/覆盖/合并；
/// - 任何情况下都不清空用户笔记/收藏/隐藏。
class BankImportService {
  BankImportService(this._repository, this._local);

  final BankRepositoryImpl _repository;
  final QuestionLocalRepository _local;

  static const String importBankVersion = 'user-import';

  Future<ImportPreview> preview(
    String content, {
    String sourceLabel = 'paste',
  }) async {
    final documents = _splitDocuments(content);
    final items = <ImportPreviewItem>[];
    for (var i = 0; i < documents.length; i++) {
      final document = documents[i];
      final label = documents.length == 1
          ? sourceLabel
          : '$sourceLabel#${i + 1}';
      final result = BankQuestionParser(
        bankVersion: importBankVersion,
        enforceFileId: false,
      ).parse(document, '$label.yaml');
      final question = result.question;
      final issues = result.issues
          .map((Object issue) => issue.toString())
          .toList(growable: false);
      String? existingTitle;
      if (question != null && issues.isEmpty) {
        existingTitle = (await _repository.byId(question.id))?.title;
      }
      items.add(
        ImportPreviewItem(
          index: i,
          sourceLabel: label,
          question: question == null || issues.isNotEmpty
              ? null
              : _asUserQuestion(question),
          issues: issues,
          existingTitle: existingTitle,
        ),
      );
    }
    return ImportPreview(items: items);
  }

  Future<ImportOutcome> commit(
    ImportPreview preview, {
    required ImportConflictPolicy policy,
  }) async {
    var created = 0;
    var overwritten = 0;
    var merged = 0;
    var skipped = 0;
    var failed = 0;

    for (final item in preview.items) {
      final question = item.question;
      if (question == null || !item.valid) {
        failed++;
        continue;
      }
      if (item.conflict) {
        switch (policy) {
          case ImportConflictPolicy.skip:
            skipped++;
            continue;
          case ImportConflictPolicy.merge:
            final summary = question.answer.summary.trim();
            if (summary.isNotEmpty) {
              await _local.appendNote(question.id, '[导入] $summary');
            }
            await _local.ensureUserOrigin(question.id);
            merged++;
            continue;
          case ImportConflictPolicy.overwrite:
            await _repository.upsertQuestions(<Question>[question]);
            await _local.ensureUserOrigin(question.id);
            overwritten++;
            continue;
        }
      }
      await _repository.upsertQuestions(<Question>[question]);
      await _local.ensureUserOrigin(question.id);
      created++;
    }
    return ImportOutcome(
      created: created,
      overwritten: overwritten,
      merged: merged,
      skipped: skipped,
      failed: failed,
    );
  }

  Question _asUserQuestion(Question question) {
    return Question(
      id: question.id,
      bankVersion: importBankVersion,
      title: question.title,
      bodyMarkdown: question.bodyMarkdown,
      topics: question.topics,
      role: question.role,
      level: question.level,
      difficulty: question.difficulty,
      type: question.type,
      answer: question.answer,
      followups: question.followups,
      source: question.source,
      status: QuestionStatus.user,
      updatedAt: question.updatedAt ?? DateTime.now(),
    );
  }

  List<String> _splitDocuments(String content) {
    final normalized = content.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) return const <String>[];
    final parts = normalized.split(RegExp(r'^---\s*$', multiLine: true));
    return parts
        .map((String part) => part.trim())
        .where((String part) => part.isNotEmpty)
        .toList();
  }
}
