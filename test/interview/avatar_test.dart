import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/features/interview/presentation/live/interviewer_avatar.dart';

void main() {
  testWidgets('renders all avatar states with semantics', (
    WidgetTester tester,
  ) async {
    for (final state in InterviewerAvatarState.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMockTheme(Brightness.light),
          home: Scaffold(
            body: Center(child: InterviewerAvatar(state: state, size: 72)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(InterviewerAvatar), findsOneWidget);
      expect(find.bySemanticsLabel('小深'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    }
  });
}
