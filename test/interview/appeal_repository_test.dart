import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/interview/data/appeal_repository.dart';
import 'package:mockmate/features/interview/data/drift_session_repository.dart';

void main() {
  test(
    'exports appeals with turn context and does not change scores',
    () async {
      final db = AppDatabase.memory();
      final root = Directory.systemTemp.createTempSync('appeals_');
      addTearDown(() async {
        await db.close();
        if (root.existsSync()) root.deleteSync(recursive: true);
      });
      final repo = DriftSessionRepository(db);
      final session = await repo.create(
        const SessionConfig(
          mode: SessionMode.drill,
          role: 'backend',
          level: 'mid',
        ),
      );
      final turn = await repo.appendAnswer(
        session.id,
        AnswerInput(
          id: 't1',
          questionId: 'q1',
          questionText: 'GMP 题目',
          text: '我的回答',
          tStartedAt: DateTime.now(),
        ),
      );
      await repo.saveScore(
        turn.id,
        const TurnScore(correctness: 3, depth: 3, structure: 3, coverage: 0.5),
      );
      await repo.saveAppeal(
        turn.id,
        point: 'syscall 时 P 移交',
        userNote: '我在第二段说过',
      );

      final appeals = AppealRepository(db);
      final candidates = await appeals.loadAll();
      expect(candidates, hasLength(1));
      expect(candidates.single.question, 'GMP 题目');
      expect(candidates.single.answer, '我的回答');
      expect(candidates.single.point, 'syscall 时 P 移交');

      final path = await appeals.export(root);
      final decoded =
          jsonDecode(File(path).readAsStringSync()) as List<dynamic>;
      expect(decoded, hasLength(1));
      expect((decoded.single as Map<String, dynamic>)['turnId'], 't1');

      // 申诉不改分。
      final stored = await repo.byId(session.id);
      expect(stored?.totalScore, isNull);
      final scored = await repo.turnsFor(session.id);
      expect(scored.single.scoreJson, contains('correctness'));
    },
  );
}
