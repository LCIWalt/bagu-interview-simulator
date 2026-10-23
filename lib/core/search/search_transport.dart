import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;

import '../contracts/contracts.dart';

class SearchResponse {
  const SearchResponse({
    required this.statusCode,
    required this.body,
    this.headers = const <String, String>{},
  });

  final int statusCode;
  final Stream<List<int>> body;
  final Map<String, String> headers;
}

abstract interface class SearchTransport {
  Future<SearchResponse> postJson(
    Uri url, {
    required Map<String, String> headers,
    required Map<String, Object?> body,
  });

  Future<SearchResponse> get(Uri url, {required Map<String, String> headers});

  void close();
}

/// Dio 实现：统一超时/取消/错误映射；响应体按流读取以便限体积。
class DioSearchTransport implements SearchTransport {
  DioSearchTransport({
    dio.Dio? client,
    this.timeout = const Duration(seconds: 15),
  }) : _dio = client ?? dio.Dio();

  final dio.Dio _dio;
  final Duration timeout;

  @override
  Future<SearchResponse> postJson(
    Uri url, {
    required Map<String, String> headers,
    required Map<String, Object?> body,
  }) async {
    try {
      final response = await _dio.postUri<dio.ResponseBody>(
        url,
        data: body,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
          contentType: dio.Headers.jsonContentType,
          headers: headers,
          sendTimeout: timeout,
          receiveTimeout: timeout,
          validateStatus: (int? _) => true,
          followRedirects: true,
          maxRedirects: 3,
        ),
      );
      return _response(response);
    } on dio.DioException catch (error, stack) {
      throw _map(error, stack);
    }
  }

  @override
  Future<SearchResponse> get(
    Uri url, {
    required Map<String, String> headers,
  }) async {
    try {
      final response = await _dio.getUri<dio.ResponseBody>(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
          headers: headers,
          sendTimeout: timeout,
          receiveTimeout: timeout,
          validateStatus: (int? _) => true,
          followRedirects: true,
          maxRedirects: 3,
        ),
      );
      return _response(response);
    } on dio.DioException catch (error, stack) {
      throw _map(error, stack);
    }
  }

  SearchResponse _response(dio.Response<dio.ResponseBody> response) {
    final headers = <String, String>{};
    response.headers.forEach((String name, List<String> values) {
      headers[name.toLowerCase()] = values.join(',');
    });
    return SearchResponse(
      statusCode: response.statusCode ?? 0,
      body: response.data?.stream ?? const Stream<List<int>>.empty(),
      headers: headers,
    );
  }

  Failure _map(dio.DioException error, StackTrace stack) {
    if (dio.CancelToken.isCancel(error)) return const CancelledFailure();
    switch (error.type) {
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.sendTimeout:
      case dio.DioExceptionType.receiveTimeout:
      case dio.DioExceptionType.transformTimeout:
        return TimeoutFailure(cause: error, stackTrace: stack);
      case dio.DioExceptionType.connectionError:
      case dio.DioExceptionType.unknown:
      case dio.DioExceptionType.badCertificate:
        return NetworkFailure(
          'network: ${error.message}',
          cause: error,
          stackTrace: stack,
        );
      case dio.DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        if (status == 401 || status == 403) {
          return AuthFailure(
            'http $status',
            statusCode: status,
            cause: error,
            stackTrace: stack,
          );
        }
        if (status == 429) {
          return RateLimitFailure('http 429', cause: error, stackTrace: stack);
        }
        return NetworkFailure(
          'http $status',
          statusCode: status,
          cause: error,
          stackTrace: stack,
        );
      case dio.DioExceptionType.cancel:
        return const CancelledFailure();
    }
  }

  @override
  void close() => _dio.close(force: true);
}

Map<String, dynamic> decodeJsonObject(String text) {
  final decoded = jsonDecode(text);
  if (decoded is! Map<String, dynamic>) {
    throw const ParseFailure('response is not a JSON object');
  }
  return decoded;
}
