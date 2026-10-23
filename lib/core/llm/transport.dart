import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;

import '../contracts/contracts.dart';

/// 传输层请求。刻意不暴露 Dio 类型，便于纯 Dart 单测与替换实现。
class LlmHttpRequest {
  const LlmHttpRequest({
    required this.url,
    required this.headers,
    required this.body,
    this.cancel,
  });

  final Uri url;
  final Map<String, String> headers;
  final Map<String, Object?> body;
  final CancelToken? cancel;
}

class LlmHttpResponse {
  const LlmHttpResponse({
    required this.statusCode,
    required this.body,
    this.headers = const <String, String>{},
  });

  final int statusCode;
  final Stream<List<int>> body;
  final Map<String, String> headers;
}

abstract interface class LlmHttpTransport {
  Future<LlmHttpResponse> postJson(LlmHttpRequest request);

  void close();
}

/// 基于 Dio 的默认传输：超时、取消联动、错误映射。
class DioLlmHttpTransport implements LlmHttpTransport {
  DioLlmHttpTransport({
    dio.Dio? client,
    this.connectTimeout = const Duration(seconds: 20),
    this.receiveTimeout = const Duration(seconds: 90),
  }) : _dio = client ?? dio.Dio();

  final dio.Dio _dio;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  @override
  Future<LlmHttpResponse> postJson(LlmHttpRequest request) async {
    final cancel = request.cancel;
    cancel?.throwIfCancelled();
    final dioCancel = dio.CancelToken();
    void onCancel() => dioCancel.cancel('cancelled');
    cancel?.addListener(onCancel);
    try {
      final response = await _dio.postUri<dio.ResponseBody>(
        request.url,
        data: request.body,
        cancelToken: dioCancel,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
          contentType: dio.Headers.jsonContentType,
          headers: request.headers,
          sendTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          validateStatus: (int? _) => true,
          followRedirects: true,
          maxRedirects: 3,
        ),
      );
      final headers = <String, String>{};
      response.headers.forEach((String name, List<String> values) {
        headers[name.toLowerCase()] = values.join(',');
      });
      return LlmHttpResponse(
        statusCode: response.statusCode ?? 0,
        body: response.data?.stream ?? const Stream<List<int>>.empty(),
        headers: headers,
      );
    } on dio.DioException catch (error, stack) {
      if (dio.CancelToken.isCancel(error)) {
        throw const CancelledFailure();
      }
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
        case dio.DioExceptionType.transformTimeout:
          throw TimeoutFailure(cause: error, stackTrace: stack);
        case dio.DioExceptionType.connectionError:
        case dio.DioExceptionType.unknown:
          throw NetworkFailure(
            'network error: ${error.message}',
            cause: error,
            stackTrace: stack,
          );
        case dio.DioExceptionType.badCertificate:
          throw NetworkFailure(
            'bad certificate',
            cause: error,
            stackTrace: stack,
          );
        case dio.DioExceptionType.cancel:
          throw const CancelledFailure();
        case dio.DioExceptionType.badResponse:
          throw NetworkFailure(
            'unexpected response',
            statusCode: error.response?.statusCode,
            cause: error,
            stackTrace: stack,
          );
      }
    } finally {
      cancel?.removeListener(onCancel);
    }
  }

  @override
  void close() => _dio.close(force: true);
}

/// 解析 `text/event-stream` 中的 `data:` 负载；遇到空行即分发。
Stream<String> sseData(Stream<List<int>> bytes) async* {
  String? buffered;
  final lines = const LineSplitter().bind(
    const Utf8Decoder(allowMalformed: true).bind(bytes),
  );
  await for (final line in lines) {
    if (line.isEmpty) {
      if (buffered != null) {
        yield buffered;
        buffered = null;
      }
      continue;
    }
    if (line.startsWith(':')) continue;
    if (!line.startsWith('data:')) continue;
    final value = line.substring(5).trimLeft();
    buffered = buffered == null ? value : '$buffered\n$value';
  }
  if (buffered != null) yield buffered;
}

/// 把 `base_url` 归一化成 `/chat/completions` 端点。
///
/// 支持 `https://api.deepseek.com`、`.../v1`、`.../v1/`、完整端点。
Uri chatCompletionsUri(Uri baseUrl) {
  var path = baseUrl.path;
  while (path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  if (path.endsWith('/chat/completions')) {
    return baseUrl.replace(path: path);
  }
  if (path.isEmpty) {
    path = '/chat/completions';
  } else {
    path = '$path/chat/completions';
  }
  return baseUrl.replace(path: path);
}

/// 从响应体读取最多 [maxBytes] 的错误文本（调用方负责脱敏）。
Future<String> readBodySnippet(
  Stream<List<int>> body, {
  int maxBytes = 4096,
}) async {
  final buffer = <int>[];
  await for (final chunk in body) {
    final remaining = maxBytes - buffer.length;
    if (remaining <= 0) break;
    buffer.addAll(
      chunk.length <= remaining ? chunk : chunk.sublist(0, remaining),
    );
    if (buffer.length >= maxBytes) break;
  }
  try {
    return utf8.decode(buffer, allowMalformed: true);
  } on FormatException {
    return '<binary body>';
  }
}
