import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/db/app_database.dart';
import 'core/platform/secure_store.dart';
import 'core/util/app_logger.dart';

Future<void> main() async {
  AppLogger? logger;
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final supportDir = await getApplicationSupportDirectory();
      await _migrateFromSandbox(supportDir);
      final appLogger = AppLogger(
        minLevel: LogLevel.debug,
        sinks: <LogSink>[
          RollingFileLogSink(Directory(p.join(supportDir.path, 'logs'))),
        ],
      );
      logger = appLogger;

      FlutterError.onError = (FlutterErrorDetails details) {
        appLogger.error(
          'flutter',
          details.exceptionAsString(),
          error: details.exception,
          stackTrace: details.stack,
        );
        FlutterError.presentError(details);
      };
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        appLogger.error('platform', '$error', error: error, stackTrace: stack);
        return true;
      };
      ErrorWidget.builder = (FlutterErrorDetails details) =>
          StartupErrorWidget(message: details.exceptionAsString());

      final database = AppDatabase.open();
      final secureStore = PlatformSecureStore();

      runApp(
        ProviderScope(
          overrides: <Override>[
            databaseProvider.overrideWithValue(database),
            loggerProvider.overrideWithValue(appLogger),
            secureStoreProvider.overrideWithValue(secureStore),
          ],
          child: const MockMateApp(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      logger?.error('zone', '$error', error: error, stackTrace: stack);
    },
  );
}

/// ADR-0006：从旧 sandbox 容器迁移数据库与本地题库（仅首次、非覆盖）。
Future<void> _migrateFromSandbox(Directory supportDir) async {
  final newDb = File(p.join(supportDir.path, 'mockmate.sqlite'));
  if (newDb.existsSync()) return;
  final home = Platform.environment['HOME'];
  if (home == null) return;
  final oldRoot = Directory(
    p.join(
      home,
      'Library',
      'Containers',
      'com.mockmate.mockmate',
      'Data',
      'Library',
      'Application Support',
      'com.mockmate.mockmate',
    ),
  );
  final oldDb = File(p.join(oldRoot.path, 'mockmate.sqlite'));
  if (!oldDb.existsSync()) return;
  await newDb.parent.create(recursive: true);
  await oldDb.copy(newDb.path);
  final oldBank = Directory(p.join(oldRoot.path, 'bank'));
  if (oldBank.existsSync()) {
    await _copyDirectory(oldBank, Directory(p.join(supportDir.path, 'bank')));
  }
}

Future<void> _copyDirectory(Directory source, Directory target) async {
  await target.create(recursive: true);
  await for (final entity in source.list(recursive: true, followLinks: false)) {
    final relative = p.relative(entity.path, from: source.path);
    final destination = p.join(target.path, relative);
    if (entity is Directory) {
      await Directory(destination).create(recursive: true);
    } else if (entity is File) {
      await File(destination).parent.create(recursive: true);
      await entity.copy(destination);
    }
  }
}

/// 首帧前/构建期不可恢复错误的兜底 UI（不依赖 Localizations）。
class StartupErrorWidget extends StatelessWidget {
  const StartupErrorWidget({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF15181C),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFF87171),
                  size: 40,
                ),
                const SizedBox(height: 12),
                const Text(
                  'MockMate 启动失败 / Failed to start',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
