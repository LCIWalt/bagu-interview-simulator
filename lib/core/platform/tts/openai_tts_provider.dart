import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;

import '../../contracts/contracts.dart';

/// OpenAI 兼容 `/audio/speech` 流式 TTS（T-061）。
class OpenAiTtsProvider implements TtsProvider {
  OpenAiTtsProvider({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    this.defaultVoices = const <TtsVoice>[
      TtsVoice(id: 'alloy', name: 'Alloy'),
      TtsVoice(id: 'echo', name: 'Echo'),
      TtsVoice(id: 'fable', name: 'Fable'),
      TtsVoice(id: 'onyx', name: 'Onyx'),
      TtsVoice(id: 'nova', name: 'Nova'),
      TtsVoice(id: 'shimmer', name: 'Shimmer'),
    ],
    dio.Dio? client,
    this.timeout = const Duration(seconds: 30),
  }) : _dio = client ?? dio.Dio();

  final String apiKey;
  final String model;
  final List<TtsVoice> defaultVoices;
  final Uri baseUrl;
  final dio.Dio _dio;
  final Duration timeout;

  @override
  String get id => 'openai-tts';

  @override
  Future<TtsVoiceList> voices() async => TtsVoiceList(defaultVoices);

  Uri get _speechUri {
    var path = baseUrl.path;
    while (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    if (!path.endsWith('/audio/speech')) path = '$path/audio/speech';
    return baseUrl.replace(path: path);
  }

  @override
  Stream<AudioChunk> synthesize(
    String text,
    TtsConfig cfg, {
    CancelToken? cancel,
  }) async* {
    if (apiKey.trim().isEmpty) {
      throw const AuthFailure('tts api key is missing');
    }
    cancel?.throwIfCancelled();
    final dioCancel = dio.CancelToken();
    void onCancel() => dioCancel.cancel('cancelled');
    cancel?.addListener(onCancel);
    try {
      final response = await _dio.postUri<dio.ResponseBody>(
        _speechUri,
        data: <String, Object?>{
          'model': model,
          'voice': cfg.voiceId ?? defaultVoices.first.id,
          'input': text,
          'speed': cfg.speed,
          'response_format': cfg.format,
        },
        cancelToken: dioCancel,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
          contentType: dio.Headers.jsonContentType,
          headers: <String, String>{
            'Authorization': 'Bearer $apiKey',
            'Accept': 'audio/*',
          },
          sendTimeout: timeout,
          receiveTimeout: timeout,
          validateStatus: (int? _) => true,
        ),
      );
      final status = response.statusCode ?? 0;
      if (status == 401 || status == 403) {
        throw AuthFailure('tts http $status', statusCode: status);
      }
      if (status == 429) {
        throw const RateLimitFailure('tts rate limited');
      }
      if (status < 200 || status >= 300) {
        throw NetworkFailure('tts http $status', statusCode: status);
      }
      final body = response.data;
      if (body == null) throw const NetworkFailure('tts empty body');
      await for (final chunk in body.stream) {
        cancel?.throwIfCancelled();
        yield AudioChunk(bytes: Uint8List.fromList(chunk));
      }
      yield AudioChunk(bytes: Uint8List(0), isLast: true);
    } on dio.DioException catch (error, stack) {
      if (dio.CancelToken.isCancel(error)) throw const CancelledFailure();
      if (error.type == dio.DioExceptionType.receiveTimeout ||
          error.type == dio.DioExceptionType.sendTimeout ||
          error.type == dio.DioExceptionType.connectionTimeout) {
        throw TimeoutFailure(cause: error, stackTrace: stack);
      }
      throw NetworkFailure(
        'tts network: ${error.message}',
        cause: error,
        stackTrace: stack,
      );
    } finally {
      cancel?.removeListener(onCancel);
    }
  }
}
