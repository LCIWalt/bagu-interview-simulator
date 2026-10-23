import 'dart:convert';

import 'package:mockmate/core/db/app_database.dart';

/// 实战草稿/当前题（T-045）：杀进程后恢复同一轮。
class MockResumeState {
  const MockResumeState({
    required this.questionId,
    required this.questionIndex,
    required this.turnId,
    this.answer = '',
  });

  final String questionId;
  final int questionIndex;
  final String turnId;
  final String answer;

  Map<String, Object?> toJson() => <String, Object?>{
    'questionId': questionId,
    'questionIndex': questionIndex,
    'turnId': turnId,
    'answer': answer,
  };

  static MockResumeState? fromJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final questionId = decoded['questionId']?.toString();
      final turnId = decoded['turnId']?.toString();
      if (questionId == null || turnId == null) return null;
      return MockResumeState(
        questionId: questionId,
        questionIndex: (decoded['questionIndex'] as num?)?.toInt() ?? 1,
        turnId: turnId,
        answer: decoded['answer']?.toString() ?? '',
      );
    } on FormatException {
      return null;
    }
  }
}

class MockResumeStore {
  MockResumeStore(this._db);

  final AppDatabase _db;

  String _key(String sessionId) => 'mock.resume.$sessionId';

  Future<MockResumeState?> load(String sessionId) async {
    final row = await (_db.select(
      _db.settings,
    )..where((Settings t) => t.key.equals(_key(sessionId)))).getSingleOrNull();
    return row == null ? null : MockResumeState.fromJson(row.value);
  }

  Future<void> save(String sessionId, MockResumeState state) async {
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: _key(sessionId),
            value: jsonEncode(state.toJson()),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> clear(String sessionId) async {
    await (_db.delete(
      _db.settings,
    )..where((Settings t) => t.key.equals(_key(sessionId)))).go();
  }
}
