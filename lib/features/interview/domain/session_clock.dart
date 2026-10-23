import '../../../../core/contracts/contracts.dart';

enum MockPhase {
  warmup,
  selfIntro,
  project,
  knowledge,
  systemDesign,
  closing,
  completed,
}

/// 墙钟计时（T-042）：切后台不漂移；阶段按已用时间比例推进。
class SessionClock {
  SessionClock({
    required this.startedAt,
    required this.total,
    DateTime Function()? now,
    this.softLimitRatio = 0.9,
  }) : _now = now ?? DateTime.now;

  final DateTime startedAt;
  final Duration total;
  final double softLimitRatio;
  final DateTime Function() _now;

  static const Map<MockPhase, double> phaseEnds = <MockPhase, double>{
    MockPhase.warmup: 0.05,
    MockPhase.selfIntro: 0.15,
    MockPhase.project: 0.50,
    MockPhase.knowledge: 0.80,
    MockPhase.systemDesign: 0.95,
    MockPhase.closing: 1.0,
  };

  Duration get elapsed {
    final value = _now().difference(startedAt);
    return value.isNegative ? Duration.zero : value;
  }

  Duration get remaining {
    final value = total - elapsed;
    return value.isNegative ? Duration.zero : value;
  }

  double get progress {
    if (total.inSeconds <= 0) return 1;
    return (elapsed.inMilliseconds / total.inMilliseconds).clamp(0, 1);
  }

  bool get expired => elapsed >= total;
  bool get softLimitReached => progress >= softLimitRatio;
  int get remainingMinutes => (remaining.inSeconds / 60).ceil();

  MockPhase get phase {
    if (expired) return MockPhase.completed;
    final p = progress;
    for (final entry in phaseEnds.entries) {
      if (p <= entry.value) return entry.key;
    }
    return MockPhase.closing;
  }

  /// 根据配置模式取阶段；练习模式没有阶段。
  MockPhase phaseFor(SessionMode mode) =>
      mode == SessionMode.mock ? phase : MockPhase.completed;
}
