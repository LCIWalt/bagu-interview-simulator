import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:path/path.dart' as p;

class AppealCandidate {
  const AppealCandidate({
    required this.turnId,
    required this.point,
    required this.note,
    required this.submittedAt,
    this.question = '',
    this.answer = '',
  });

  final String turnId;
  final String point;
  final String note;
  final DateTime submittedAt;
  final String question;
  final String answer;

  Map<String, Object?> toJson() => <String, Object?>{
    'turnId': turnId,
    'point': point,
    'note': note,
    'submittedAt': submittedAt.toUtc().toIso8601String(),
    'question': question,
    'answer': answer,
  };
}

/// 申诉 → 校准候选（T-057）：只导出，不自动改分。
class AppealRepository {
  AppealRepository(this._db);

  final AppDatabase _db;

  Future<List<AppealCandidate>> loadAll() async {
    final rows = await (_db.select(
      _db.settings,
    )..where((Settings t) => t.key.like('appeal.%'))).get();
    final candidates = <AppealCandidate>[];
    for (final row in rows) {
      final turnId = row.key.substring('appeal.'.length);
      final turn = await (_db.select(
        _db.turns,
      )..where((Turns t) => t.id.equals(turnId))).getSingleOrNull();
      try {
        final decoded = jsonDecode(row.value);
        if (decoded is! List) continue;
        for (final entry in decoded) {
          if (entry is! Map<String, dynamic>) continue;
          candidates.add(
            AppealCandidate(
              turnId: turnId,
              point: entry['point']?.toString() ?? '',
              note: entry['note']?.toString() ?? '',
              submittedAt:
                  DateTime.tryParse(entry['at']?.toString() ?? '') ??
                  row.updatedAt,
              question: turn?.questionText ?? '',
              answer: turn?.answerText ?? '',
            ),
          );
        }
      } on FormatException {
        continue;
      }
    }
    candidates.sort(
      (AppealCandidate a, AppealCandidate b) =>
          b.submittedAt.compareTo(a.submittedAt),
    );
    return candidates;
  }

  /// 导出 JSON 到 `root/calibration/appeals-<timestamp>.json`。
  Future<String> export(Directory root) async {
    final candidates = await loadAll();
    final file = File(
      p.join(
        root.path,
        'calibration',
        'appeals-${DateTime.now().toUtc().toIso8601String().replaceAll(':', '-')}.json',
      ),
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(
        candidates
            .map((AppealCandidate c) => c.toJson())
            .toList(growable: false),
      ),
    );
    return file.path;
  }
}
