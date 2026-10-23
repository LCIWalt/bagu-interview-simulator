import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/interview/data/mock_config_store.dart';

void main() {
  test('remembers the last mock config', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final store = MockConfigStore(db);
    expect(await store.load(), isNull);

    const config = SessionConfig(
      mode: SessionMode.mock,
      role: 'frontend',
      level: 'senior',
      durationMinutes: 30,
      difficulty: 4,
      allowHints: true,
      style: InterviewerStyle.stress,
      topics: <String>['react', 'performance'],
    );
    await store.save(config);
    final loaded = await store.load();
    expect(loaded?.mode, SessionMode.mock);
    expect(loaded?.role, 'frontend');
    expect(loaded?.durationMinutes, 30);
    expect(loaded?.style, InterviewerStyle.stress);
    expect(loaded?.topics, <String>['react', 'performance']);
  });
}
