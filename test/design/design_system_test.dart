import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/design/glass.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/core/design/tokens.dart';

void main() {
  test('glass quality resolves for accessibility and low-end devices', () {
    expect(
      GlassQuality.resolve(reduceTransparency: true, lowEndDevice: true),
      GlassQuality.flat,
    );
    expect(
      GlassQuality.resolve(reduceTransparency: false, lowEndDevice: true),
      GlassQuality.blurOnly,
    );
    expect(
      GlassQuality.resolve(reduceTransparency: false, lowEndDevice: false),
      GlassQuality.full,
    );
  });

  test('tokens follow brightness and keep semantic colors distinct', () {
    final light = MockTokens.light();
    final dark = MockTokens.dark();
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(light.blur, MockBlur.regular);
    expect(light.copyWith(glassQuality: GlassQuality.flat).blur, 0);
    expect(<Color>{
      light.success,
      light.warning,
      light.danger,
      light.info,
    }, hasLength(4));
  });

  for (final quality in GlassQuality.values) {
    testWidgets('GlassPanel renders with ${quality.name}', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMockTheme(Brightness.light, glassQuality: quality),
          home: Scaffold(
            body: Center(
              child: GlassPanel(
                quality: quality,
                child: const Text('glass-content'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('glass-content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('GlassButton disables interaction while busy', (
    WidgetTester tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMockTheme(Brightness.light),
        home: Scaffold(
          body: GlassButton(label: 'go', busy: true, onPressed: () => taps++),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(taps, 0);
  });
}
