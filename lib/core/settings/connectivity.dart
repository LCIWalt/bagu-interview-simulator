import 'dart:async';

import '../contracts/contracts.dart';
import '../llm/openai_compatible_client.dart';
import '../llm/transport.dart';
import '../util/app_logger.dart';
import 'provider_config.dart';

Uri parseProviderBaseUrl(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    throw const FormatException('Base URL 必须是完整的 http(s) 地址');
  }
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    throw const FormatException('Base URL 仅支持 http/https');
  }
  return uri;
}

LlmClient createLlmClient(
  ProviderConfig config,
  String apiKey, {
  LlmHttpTransport? transport,
  AppLogger? logger,
}) {
  return OpenAiCompatibleClient(
    id: 'provider-${config.role.name}',
    baseUrl: parseProviderBaseUrl(config.baseUrl),
    apiKey: apiKey,
    transport: transport,
    logger: logger,
  );
}

class ConnectivityResult {
  const ConnectivityResult({required this.latency, required this.sample});

  final Duration latency;
  final String sample;
}

/// 设置页「测试连通」：发一条最小请求，区分 401 / 超时 / 模型不存在。
class ConnectivityService {
  ConnectivityService({
    this.logger,
    this.timeout = const Duration(seconds: 20),
  });

  final AppLogger? logger;
  final Duration timeout;

  Future<ConnectivityResult> test({
    required ProviderConfig config,
    required String apiKey,
    LlmClient? client,
  }) async {
    if (config.role == ProviderRole.embedding) {
      throw const UnknownFailure('embedding 为本地模型，无需网络连通测试');
    }
    if (apiKey.trim().isEmpty) {
      throw const AuthFailure('missing api key');
    }
    final effective = client ?? createLlmClient(config, apiKey, logger: logger);
    final startedAt = DateTime.now();
    final buffer = StringBuffer();
    try {
      final stream = effective.chat(
        ChatRequest(
          model: config.model,
          messages: const <ChatMessage>[ChatMessage.user('ping')],
          temperature: 0,
          maxTokens: 8,
        ),
      );
      await for (final delta in stream.timeout(timeout)) {
        if (delta is LlmTextDelta) {
          buffer.write(delta.text);
          if (buffer.length >= 8) break;
        }
        if (delta is LlmDoneDelta) break;
      }
      return ConnectivityResult(
        latency: DateTime.now().difference(startedAt),
        sample: buffer.toString(),
      );
    } on TimeoutException catch (error, stack) {
      throw TimeoutFailure(
        message: 'connectivity test timed out',
        cause: error,
        stackTrace: stack,
      );
    } finally {}
  }
}
