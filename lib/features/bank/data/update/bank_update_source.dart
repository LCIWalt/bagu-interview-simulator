import 'package:dio/dio.dart' as dio;

import '../../../../core/contracts/contracts.dart';
import '../bank_manifest_codec.dart' as codec;

class RemoteManifest {
  const RemoteManifest({
    required this.manifest,
    required this.assetUrls,
    this.etag,
    this.rawJson = const <String, Object?>{},
  });

  final BankManifest manifest;

  /// 资产名 → 下载 URL。
  final Map<String, String> assetUrls;
  final String? etag;
  final Map<String, Object?> rawJson;
}

/// 题库更新源抽象；测试注入 fake，不依赖真实网络。
abstract interface class BankUpdateSource {
  /// 返回 null 表示 304 Not Modified。
  Future<RemoteManifest?> fetchManifest({String? etag, CancelToken? cancel});

  Stream<List<int>> download(String url, {CancelToken? cancel});
}

/// GitHub Release 资产：`releases/latest` → `manifest.json` → `bank-*.tar.zst`。
class GitHubReleaseSource implements BankUpdateSource {
  GitHubReleaseSource({
    required this.releaseApiUrl,
    dio.Dio? client,
    this.requestTimeout = const Duration(seconds: 30),
  }) : _dio = client ?? dio.Dio();

  final Uri releaseApiUrl;
  final dio.Dio _dio;
  final Duration requestTimeout;

  @override
  Future<RemoteManifest?> fetchManifest({
    String? etag,
    CancelToken? cancel,
  }) async {
    cancel?.throwIfCancelled();
    final dioCancel = dio.CancelToken();
    void onCancel() => dioCancel.cancel('cancelled');
    cancel?.addListener(onCancel);
    try {
      final response = await _dio.getUri<Map<String, dynamic>>(
        releaseApiUrl,
        cancelToken: dioCancel,
        options: dio.Options(
          validateStatus: (int? status) => status == 200 || status == 304,
          responseType: dio.ResponseType.json,
          headers: <String, String>{
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
            'If-None-Match': ?etag,
          },
          receiveTimeout: requestTimeout,
          sendTimeout: requestTimeout,
        ),
      );
      if (response.statusCode == 304) return null;
      final release = response.data;
      if (release == null) throw const ParseFailure('release payload 为空');
      final assets = release['assets'];
      if (assets is! List) {
        throw const ParseFailure('release 缺少 assets');
      }
      final urls = <String, String>{};
      for (final asset in assets) {
        if (asset is! Map<String, dynamic>) {
          continue;
        }
        final name = asset['name']?.toString();
        final url = asset['browser_download_url']?.toString();
        if (name != null && url != null) urls[name] = url;
      }
      final manifestUrl = urls['manifest.json'];
      if (manifestUrl == null) {
        throw const ParseFailure('release 中没有 manifest.json');
      }
      final manifestResponse = await _dio.getUri<Map<String, dynamic>>(
        Uri.parse(manifestUrl),
        cancelToken: dioCancel,
        options: dio.Options(
          validateStatus: (int? status) => status == 200,
          responseType: dio.ResponseType.json,
          receiveTimeout: requestTimeout,
        ),
      );
      final manifestJson = manifestResponse.data;
      if (manifestJson == null) throw const ParseFailure('manifest.json 为空');
      return RemoteManifest(
        manifest: codec.BankManifestCodec.fromJson(manifestJson),
        assetUrls: urls,
        etag: response.headers.value('etag'),
        rawJson: manifestJson,
      );
    } on dio.DioException catch (error, stack) {
      if (dio.CancelToken.isCancel(error)) throw const CancelledFailure();
      throw _mapDio(error, stack);
    } finally {
      cancel?.removeListener(onCancel);
    }
  }

  @override
  Stream<List<int>> download(String url, {CancelToken? cancel}) async* {
    cancel?.throwIfCancelled();
    final dioCancel = dio.CancelToken();
    void onCancel() => dioCancel.cancel('cancelled');
    cancel?.addListener(onCancel);
    try {
      final response = await _dio.getUri<dio.ResponseBody>(
        Uri.parse(url),
        cancelToken: dioCancel,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
          validateStatus: (int? status) => status == 200,
          receiveTimeout: const Duration(minutes: 5),
          headers: const <String, String>{'Accept': 'application/octet-stream'},
        ),
      );
      final body = response.data;
      if (body == null) throw const NetworkFailure('下载响应为空');
      yield* body.stream;
    } on dio.DioException catch (error, stack) {
      if (dio.CancelToken.isCancel(error)) throw const CancelledFailure();
      throw _mapDio(error, stack);
    } finally {
      cancel?.removeListener(onCancel);
    }
  }

  Failure _mapDio(dio.DioException error, StackTrace stack) {
    if (error.type == dio.DioExceptionType.connectionTimeout ||
        error.type == dio.DioExceptionType.receiveTimeout ||
        error.type == dio.DioExceptionType.sendTimeout) {
      return TimeoutFailure(cause: error, stackTrace: stack);
    }
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      return AuthFailure(
        'github auth failed',
        statusCode: status,
        cause: error,
        stackTrace: stack,
      );
    }
    if (status == 404) {
      return NotFoundFailure(
        'release not found',
        cause: error,
        stackTrace: stack,
      );
    }
    if (status == 429) {
      return RateLimitFailure(
        'github rate limited',
        cause: error,
        stackTrace: stack,
      );
    }
    return NetworkFailure(
      'github request failed: ${error.message}',
      statusCode: status,
      cause: error,
      stackTrace: stack,
    );
  }
}
