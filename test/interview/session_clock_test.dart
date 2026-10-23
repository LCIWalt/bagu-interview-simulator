import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/features/interview/domain/session_clock.dart';

void main() {
  final start = DateTime.utc(2026, 10, 22, 10);
  late DateTime now;
  SessionClock clock() => SessionClock(
    startedAt: start,
    total: const Duration(minutes: 20),
    now: () => now,
  );

  setUp(() => now = start);

  test('advances phases with wall-clock progress', () {
    expect(clock().phase, MockPhase.warmup);
    now = start.add(const Duration(minutes: 1));
    expect(clock().phase, MockPhase.warmup);
    now = start.add(const Duration(minutes: 3));
    expect(clock().phase, MockPhase.selfIntro);
    now = start.add(const Duration(minutes: 6));
    expect(clock().phase, MockPhase.project);
    now = start.add(const Duration(minutes: 12));
    expect(clock().phase, MockPhase.knowledge);
    now = start.add(const Duration(minutes: 17));
    expect(clock().phase, MockPhase.systemDesign);
    now = start.add(const Duration(minutes: 19, seconds: 30));
    expect(clock().phase, MockPhase.closing);
  });

  test('wall clock survives background jumps and clamps remaining', () {
    now = start.add(const Duration(minutes: 25));
    final c = clock();
    expect(c.expired, isTrue);
    expect(c.phase, MockPhase.completed);
    expect(c.remaining, Duration.zero);
    expect(c.progress, 1);
    expect(c.softLimitReached, isTrue);
  });

  test('soft limit and remaining minutes', () {
    now = start.add(const Duration(minutes: 12));
    final c = clock();
    expect(c.softLimitReached, isFalse);
    expect(c.remainingMinutes, 8);
    now = start.add(const Duration(minutes: 18, seconds: 1));
    expect(clock().softLimitReached, isTrue);
  });
}
