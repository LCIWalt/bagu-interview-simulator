import '../../../core/contracts/contracts.dart';

enum SessionPhase {
  drill,
  warmup,
  selfIntro,
  project,
  knowledge,
  systemDesign,
  closing,
  completed,
}

class SessionFlowException implements Exception {
  const SessionFlowException(this.message);

  final String message;

  @override
  String toString() => 'SessionFlowException: $message';
}

/// 双模式状态机（T-031）。mode 在创建后不可变；非法转移抛 [SessionFlowException]。
class SessionFlow {
  SessionFlow.create(this.config)
    : mode = config.mode,
      phase = config.mode == SessionMode.drill
          ? SessionPhase.drill
          : SessionPhase.warmup,
      status = SessionStatus.active;

  final SessionConfig config;
  final SessionMode mode;
  SessionPhase phase;
  SessionStatus status;

  int turnCount = 0;
  int followupCount = 0;

  bool get isActive => status == SessionStatus.active;
  bool get canFollowup => followupCount < config.followupDepth;

  void submitAnswer({bool followup = false}) {
    _ensureActive();
    if (mode == SessionMode.drill && phase == SessionPhase.completed) {
      throw const SessionFlowException('practice already completed');
    }
    if (followup) {
      if (!canFollowup) {
        throw const SessionFlowException('followup depth exhausted');
      }
      followupCount++;
    }
    turnCount++;
  }

  void skipQuestion() {
    _ensureActive();
    if (mode == SessionMode.mock) {
      throw const SessionFlowException('mock sessions cannot skip a question');
    }
    turnCount++;
    followupCount = 0;
  }

  void nextQuestion() {
    _ensureActive();
    if (mode == SessionMode.mock) {
      throw const SessionFlowException('mock sessions advance by phase');
    }
    followupCount = 0;
  }

  void nextPhase() {
    _ensureActive();
    if (mode == SessionMode.drill) {
      throw const SessionFlowException('practice sessions have no phases');
    }
    if (phase == SessionPhase.closing || phase == SessionPhase.completed) {
      finish();
      return;
    }
    phase = switch (phase) {
      SessionPhase.warmup => SessionPhase.selfIntro,
      SessionPhase.selfIntro => SessionPhase.project,
      SessionPhase.project => SessionPhase.knowledge,
      SessionPhase.knowledge => SessionPhase.systemDesign,
      SessionPhase.systemDesign => SessionPhase.closing,
      _ => SessionPhase.completed,
    };
  }

  void timeout() {
    _ensureActive();
    finish();
  }

  void finish() {
    _ensureActive();
    status = SessionStatus.completed;
    phase = SessionPhase.completed;
  }

  void abandon() {
    _ensureActive();
    status = SessionStatus.abandoned;
  }

  void _ensureActive() {
    if (!isActive) {
      throw const SessionFlowException('session is not active');
    }
  }
}
