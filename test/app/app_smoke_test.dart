import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/app/app.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/platform/secure_store.dart';
import 'package:mockmate/core/util/app_logger.dart';
import 'package:mockmate/features/home/presentation/home_page.dart';

void main() {
  testWidgets('app boots to home with real providers and an empty DB', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          loggerProvider.overrideWithValue(AppLogger()),
          secureStoreProvider.overrideWithValue(InMemorySecureStore()),
        ],
        child: const BaguInterviewApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
