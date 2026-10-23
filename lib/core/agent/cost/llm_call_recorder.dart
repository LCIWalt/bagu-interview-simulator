import 'package:drift/drift.dart';

import '../../contracts/contracts.dart';
import '../../db/app_database.dart';
import '../../util/app_logger.dart';
import '../../util/redact.dart';
import 'llm_cost.dart';

/// LLM 调用记录装饰器（T-035）。
///
/// - 流结束后把 usage/latency 写入 `llm_calls`（只统计 token，不估算费用）；
/// - 失败也记录 error，日志脱敏。
class LlmCallRecorder implements LlmClient {
  LlmCallRecorder({
    required this.inner,
    required this.db,
    required this.role,
    required this.providerId,
    this.sessionId,
    this.logger,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final LlmClient inner;
  final AppDatabase db;
  final String role;
  final String providerId;
  final String? sessionId;
  final AppLogger? logger;
  final DateTime Function() _now;

  @override
  String get id => inner.id;

  @override
  Stream<LlmDelta> chat(ChatRequest req, {CancelToken? cancel}) async* {
    final sw = Stopwatch()..start();
    var usage = const LlmUsage();
    Object? error;
    try {
      await for (final delta in inner.chat(req, cancel: cancel)) {
        if (delta is LlmUsageDelta) usage += delta.usage;
        yield delta;
      }
    } on Object catch (caught) {
      error = caught;
      rethrow;
    } finally {
      sw.stop();
      try {
        await _persist(
          req: req,
          usage: usage,
          latencyMs: sw.elapsedMilliseconds,
          error: error,
        );
      } on Object catch (logError) {
        logger?.warn('cost', '写入 llm_calls 失败: $logError');
      }
    }
  }

  Future<UsageSnapshot> usageFor(String sessionId) async {
    final rows = await (db.select(
      db.llmCalls,
    )..where((LlmCalls t) => t.sessionId.equals(sessionId))).get();
    var prompt = 0;
    var completion = 0;
    for (final row in rows) {
      prompt += row.tokensIn;
      completion += row.tokensOut;
    }
    return UsageSnapshot(promptTokens: prompt, completionTokens: completion);
  }

  Future<void> _persist({
    required ChatRequest req,
    required LlmUsage usage,
    required int latencyMs,
    required Object? error,
  }) async {
    const cost = 0.0;
    final now = _now();
    await db
        .into(db.llmCalls)
        .insert(
          LlmCallsCompanion.insert(
            id: 'c_${now.microsecondsSinceEpoch}_${_nextId++}',
            sessionId: Value(sessionId),
            role: role,
            provider: providerId,
            model: req.model,
            tokensIn: Value(usage.promptTokens),
            tokensOut: Value(usage.completionTokens),
            latencyMs: Value(latencyMs),
            cost: Value(cost),
            error: Value(
              error == null ? null : redact('$error', maxLength: 500),
            ),
            createdAt: now,
          ),
        );
    logger?.debug(
      'cost',
      'role=$role model=${req.model} tokens=${usage.totalTokens} '
          'latency=${latencyMs}ms ${error == null ? '' : 'error'}',
    );
  }

  static int _nextId = 0;
}
