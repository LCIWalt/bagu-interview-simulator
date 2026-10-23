import 'dart:typed_data';

import 'cancel_token.dart';

/// 一个可用的 TTS 音色。
class TtsVoice {
  const TtsVoice({
    required this.id,
    required this.name,
    this.locale = 'zh-CN',
    this.gender,
  });

  final String id;
  final String name;
  final String locale;
  final String? gender;
}

class TtsVoiceList {
  const TtsVoiceList(this.voices);

  final List<TtsVoice> voices;
}

class TtsConfig {
  const TtsConfig({this.voiceId, this.speed = 1.0, this.format = 'mp3'});

  final String? voiceId;

  /// 0.9 – 1.1，指南 §7.3.1。
  final double speed;
  final String format;
}

/// 流式音频分片。`isLast` 标记合成结束。
class AudioChunk {
  const AudioChunk({required this.bytes, this.isLast = false});

  final Uint8List bytes;
  final bool isLast;
}

abstract interface class TtsProvider {
  String get id;

  Future<TtsVoiceList> voices();

  Stream<AudioChunk> synthesize(
    String text,
    TtsConfig cfg, {
    CancelToken? cancel,
  });
}
