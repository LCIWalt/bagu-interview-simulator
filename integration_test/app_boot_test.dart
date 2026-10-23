import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockmate/core/platform/secure_store.dart';
import 'package:mockmate/features/home/presentation/home_page.dart';
import 'package:mockmate/main.dart' as app;

/// 三端冒烟：真实插件 + 真实数据库启动，验证首帧与安全存储。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots and secure storage round-trips', (
    WidgetTester tester,
  ) async {
    unawaited(app.main());
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.byType(HomePage), findsOneWidget);

    final store = PlatformSecureStore();
    await store.write('mockmate.selftest', 'ok');
    expect(await store.read('mockmate.selftest'), 'ok');
    await store.delete('mockmate.selftest');
    expect(await store.read('mockmate.selftest'), isNull);
  });
}
