import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/platform/tts/tts_service.dart';

class _FakeTts implements TtsProvider {
  _FakeTts({this.fail = false});

  final bool fail;

  @override
  String get id => 'fake-tts';

  @override
  Future<TtsVoiceList> voices() async => const TtsVoiceList(<TtsVoice>[]);

  @override
  Stream<AudioChunk> synthesize(
    String text,
    TtsConfig cfg, {
    CancelToken? cancel,
  }) async* {
    if (fail) throw const NetworkFailure('tts down');
    yield AudioChunk(bytes: Uint8List.fromList(<int>[1, 2]));
    yield AudioChunk(bytes: Uint8List.fromList(<int>[3]));
    yield AudioChunk(bytes: Uint8List(0), isLast: true);
  }
}

class _FakeSink implements AudioSink {
  Uint8List? bytes;
  String? format;
  bool stopped = false;
  bool disposed = false;

  @override
  Future<void> play(Uint8List data, {String format = 'mp3'}) async {
    bytes = data;
    this.format = format;
  }

  @override
  Future<void> stop() async => stopped = true;

  @override
  Future<void> dispose() async => disposed = true;
}

void main() {
  test('synthesizes to complete audio and plays it', () async {
    final sink = _FakeSink();
    final service = TtsService(provider: _FakeTts(), sink: sink);
    await service.speak('hello');
    expect(sink.bytes, Uint8List.fromList(<int>[1, 2, 3]));
    expect(sink.format, 'mp3');
    await service.stop();
    expect(sink.stopped, isTrue);
  });

  test('provider failure propagates and leaves no playback', () async {
    final sink = _FakeSink();
    final service = TtsService(provider: _FakeTts(fail: true), sink: sink);
    await expectLater(service.speak('x'), throwsA(isA<NetworkFailure>()));
    expect(sink.bytes, isNull);
  });

  test('dispose delegates to sink', () async {
    final sink = _FakeSink();
    await TtsService(provider: _FakeTts(), sink: sink).dispose();
    expect(sink.disposed, isTrue);
  });
}
