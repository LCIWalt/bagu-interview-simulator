import 'dart:io';

import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/db/app_database.dart';

/// schema 快照：任何建表/索引/触发器改动都必须更新
/// `test/db/schema_snapshot.txt` 并在 PR 里说明。
void main() {
  test('schema matches checked-in snapshot', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    final rows = await db.customSelect(
      '''SELECT type, name, sql FROM sqlite_master
          WHERE sql IS NOT NULL AND name NOT LIKE 'sqlite_%'
          ORDER BY type, name''',
    ).get();
    final actual = rows
        .map(
          (QueryRow row) =>
              '${row.data['type']};${row.data['name']};${row.data['sql']}',
        )
        .join('\n');

    final file = File('test/db/schema_snapshot.txt');
    if (!file.existsSync()) {
      await file.writeAsString('$actual\n');
      fail('schema snapshot 不存在，已生成 ${file.path}，请检查后重新运行');
    }
    expect(
      '$actual\n',
      file.readAsStringSync(),
      reason: 'schema 变更需迁移 + 快照更新（AGENTS.md §4）',
    );
  });
}
