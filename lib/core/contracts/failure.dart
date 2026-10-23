/// 跨层错误类型。UI 只按 [Failure] 的具体分支渲染文案。
///
/// 约定：任何 provider/仓库实现都不得把底层异常（DioException、SqliteException…）
/// 泄漏到上层，必须映射为下面的分支之一。
sealed class Failure implements Exception {
  const Failure(this.message, {this.cause, this.stackTrace});

  /// 面向开发者的英文短描述，不直接展示给用户（UI 走 i18n）。
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// 网络不可达、断流、5xx 等。
final class NetworkFailure extends Failure {
  const NetworkFailure(
    super.message, {
    this.statusCode,
    this.retryAfter,
    super.cause,
    super.stackTrace,
  });

  final int? statusCode;
  final Duration? retryAfter;
}

/// 401/403，或缺少 key。
final class AuthFailure extends Failure {
  const AuthFailure(
    super.message, {
    this.statusCode,
    super.cause,
    super.stackTrace,
  });

  final int? statusCode;
}

/// 响应结构不符合预期（SSE 分片坏、JSON schema 不匹配等）。
final class ParseFailure extends Failure {
  const ParseFailure(super.message, {super.cause, super.stackTrace});
}

/// 请求超时（连接/首包/整体）。
final class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'timeout',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// 429；[retryAfter] 来自 `Retry-After`。
final class RateLimitFailure extends Failure {
  const RateLimitFailure(
    super.message, {
    this.retryAfter,
    super.cause,
    super.stackTrace,
  });

  final Duration? retryAfter;
}

/// 模型/接口不存在（404）或 provider 返回了不支持的路径。
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.cause, super.stackTrace});
}

/// 会话 token 预算耗尽（指南 §5.2 / §9.5）。
final class BudgetExceededFailure extends Failure {
  const BudgetExceededFailure([super.message = 'token budget exceeded']);
}

/// 用户主动取消。
final class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'cancelled']);
}

/// 未分类错误，保留原始异常以便排障（日志需脱敏）。
final class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.cause, super.stackTrace});
}
