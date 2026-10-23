import 'dart:async';

import 'failure.dart';

/// 可贯穿 LLM / HTTP / TTS 的取消信号。
///
/// 与 Dio 的 CancelToken 不同，这里是领域层契约，不依赖任何 HTTP 库；
/// 传输层在发起请求时通过 [addListener] 把取消联动到自己的取消机制。
class CancelToken {
  CancelToken();

  final Set<void Function()> _listeners = <void Function()>{};
  bool _cancelled = false;
  Object? reason;

  bool get isCancelled => _cancelled;

  /// 注册取消回调；若已取消则立即执行。
  void addListener(void Function() listener) {
    if (_cancelled) {
      listener();
      return;
    }
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) => _listeners.remove(listener);

  void cancel([Object? why]) {
    if (_cancelled) return;
    _cancelled = true;
    reason = why;
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
    _listeners.clear();
  }

  /// 在 await 之间调用，取消则抛出 [CancelledFailure]。
  void throwIfCancelled() {
    if (_cancelled) throw const CancelledFailure();
  }

  Future<T> guard<T>(Future<T> future) async {
    throwIfCancelled();
    final result = await future;
    throwIfCancelled();
    return result;
  }
}
