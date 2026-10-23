import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../contracts/contracts.dart';

/// 播放抽象：测试注入 fake，不依赖平台音频。
abstract interface class AudioSink {
  /// 播放完整音频；返回时表示播放结束。
  Future<void> play(Uint8List bytes, {String format = 'mp3'});

  Future<void> stop();

  Future<void> dispose();
}

/// just_audio 实现：先缓冲完整音频到临时文件再播放。
///
/// 说明：TTS 接口本身是流式的，但 v0.5 为了三端稳定先整段播放；面试官单句通常
/// 1–2 秒，首包预算仍可满足。后续可换 StreamAudioSource 做边下边播。
class JustAudioSink implements AudioSink {
  JustAudioSink({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  File? _temp;

  @override
  Future<void> play(Uint8List bytes, {String format = 'mp3'}) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      p.join(
        dir.path,
        'mockmate-tts-${DateTime.now().microsecondsSinceEpoch}.$format',
      ),
    );
    await file.writeAsBytes(bytes, flush: true);
    _temp = file;
    await _player.setFilePath(file.path);
    await _player.play();
    await file.delete().catchError((Object _) => file);
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() async {
    await _player.dispose();
    final temp = _temp;
    if (temp != null && temp.existsSync()) {
      try {
        await temp.delete();
      } on FileSystemException {
        // ignore
      }
    }
  }
}

/// TTS 门面：合成 → 播放；取消/停止贯穿。
class TtsService {
  TtsService({required this.provider, required this.sink});

  final TtsProvider provider;
  final AudioSink sink;
  CancelToken? _active;

  Future<void> speak(
    String text, {
    TtsConfig config = const TtsConfig(),
    CancelToken? cancel,
  }) async {
    final token = cancel ?? CancelToken();
    _active?.cancel();
    _active = token;
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in provider.synthesize(
      text,
      config,
      cancel: token,
    )) {
      token.throwIfCancelled();
      if (chunk.bytes.isNotEmpty) bytes.add(chunk.bytes);
    }
    token.throwIfCancelled();
    await sink.play(bytes.takeBytes(), format: config.format);
  }

  Future<void> stop() async {
    _active?.cancel();
    _active = null;
    await sink.stop();
  }

  Future<void> dispose() => sink.dispose();
}
