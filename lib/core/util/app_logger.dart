import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'redact.dart';

enum LogLevel { debug, info, warn, error }

class LogRecord {
  const LogRecord({
    required this.at,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final DateTime at;
  final LogLevel level;
  final String tag;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  String format() {
    final buffer = StringBuffer()
      ..write(at.toUtc().toIso8601String())
      ..write(' ')
      ..write(level.name.toUpperCase().padRight(5))
      ..write(' [')
      ..write(tag)
      ..write('] ')
      ..write(redact(message));
    if (error != null) {
      buffer
        ..write(' | ')
        ..write(redact(error.toString()));
    }
    if (stackTrace != null) {
      buffer
        ..write('\n')
        ..write(redact(stackTrace.toString(), maxLength: 8000));
    }
    return buffer.toString();
  }
}

abstract interface class LogSink {
  void write(LogRecord record);
  Future<void> close();
}

/// 按天滚动的文件 sink，保留 7 天（指南 §9.6）。
class RollingFileLogSink implements LogSink {
  RollingFileLogSink(
    this.directory, {
    this.retention = const Duration(days: 7),
  });

  final Directory directory;
  final Duration retention;

  Future<void> _pending = Future<void>.value();
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    _initialized = true;
    await directory.create(recursive: true);
    final cutoff = DateTime.now().subtract(retention);
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      final stat = await entity.stat();
      if (stat.modified.isBefore(cutoff)) {
        await entity.delete();
      }
    }
  }

  File _fileFor(DateTime at) {
    final local = at.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return File(p.join(directory.path, 'mockmate-$y-$m-$d.log'));
  }

  @override
  void write(LogRecord record) {
    _pending = _pending.then((_) async {
      try {
        await _ensureInit();
        await _fileFor(record.at)
            .writeAsString('${record.format()}\n', mode: FileMode.append);
      } on FileSystemException {
        // 日志失败不能影响业务。
      }
    });
  }

  Future<void> flush() => _pending;

  @override
  Future<void> close() => _pending;
}

/// 内存环形缓冲 + 可选文件 sink；所有文本写入前脱敏。
class AppLogger {
  AppLogger({
    this.minLevel = LogLevel.info,
    List<LogSink> sinks = const <LogSink>[],
    this.capacity = 500,
  }) : _sinks = List<LogSink>.of(sinks);

  final LogLevel minLevel;
  final int capacity;
  final List<LogSink> _sinks;
  final List<LogRecord> _buffer = <LogRecord>[];

  List<LogRecord> get recent => List<LogRecord>.unmodifiable(_buffer);

  void debug(String tag, String message) => _log(LogLevel.debug, tag, message);
  void info(String tag, String message) => _log(LogLevel.info, tag, message);
  void warn(String tag, String message, {Object? error}) =>
      _log(LogLevel.warn, tag, message, error: error);
  void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(LogLevel.error, tag, message, error: error, stackTrace: stackTrace);

  void _log(
    LogLevel level,
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < minLevel.index) return;
    final record = LogRecord(
      at: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
    _buffer.add(record);
    if (_buffer.length > capacity) {
      _buffer.removeRange(0, _buffer.length - capacity);
    }
    for (final sink in _sinks) {
      sink.write(record);
    }
  }

  /// 导出最近日志到目标文件，返回目标路径。
  Future<String> export(File target) async {
    final content = _buffer.map((LogRecord r) => r.format()).join('\n');
    await target.parent.create(recursive: true);
    await target.writeAsString(content);
    return target.path;
  }

  Future<void> close() async {
    for (final sink in _sinks) {
      await sink.close();
    }
  }
}
