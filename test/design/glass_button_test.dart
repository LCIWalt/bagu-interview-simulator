import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/design/glass.dart';
import 'package:mockmate/core/design/theme.dart';

void main() {
  testWidgets('scales down while pressed and restores on release', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMockTheme(Brightness.light),
        home: Scaffold(
          body: Center(
            child: GlassButton(label: '保存', onPressed: () {}),
          ),
        ),
      ),
    );
    final scaleFinder = find.byType(AnimatedScale);
    expect(tester.widget<AnimatedScale>(scaleFinder).scale, 1);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('保存')),
    );
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.widget<AnimatedScale>(scaleFinder).scale, 0.94);

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 160));
    expect(tester.widget<AnimatedScale>(scaleFinder).scale, 1);
  });
}
