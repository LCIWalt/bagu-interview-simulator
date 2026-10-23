import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/util/app_logger.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/seed_bank_installer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('installs the checked-in seed bank and is idempotent', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = BankRepositoryImpl(db);
    final installer = SeedBankInstaller(repo, logger: AppLogger());

    expect(await installer.installIfNeeded(), isTrue);
    final count = await repo.countQuestions();
    expect(count, greaterThanOrEqualTo(728));

    final results = await repo.search(const QuestionQuery(limit: 1000));
    expect(results, hasLength(count));
    expect(results.any((Question q) => q.id == 'be-go-001'), isTrue);
    expect((await repo.installed())?.bankVersion, '2026.10.6');

    expect(await installer.installIfNeeded(), isFalse);
    expect(await repo.countQuestions(), count);
  });
}
