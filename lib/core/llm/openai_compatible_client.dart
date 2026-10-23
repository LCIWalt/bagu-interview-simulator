import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../contracts/contracts.dart';
import '../util/app_logger.dart';
import '../util/redact.dart';
import 'transport.dart';

/// OpenAI 兼容的流式客户端：SSE、tool calls、取消、429/5xx 退避、用量。
///
/// 只依赖 [LlmHttpTransport]，因此可在纯 Dart 单测中注入假传输。
class OpenAiCompatibleClient implements LlmClient {
  OpenAiCompatibleClient({
    required this.id,
    required this.baseUrl,
    required this.apiKey,
    LlmHttpTransport? transport,
    this.logger,
    this.maxRetries = 3,
    this.retryBaseDelay = const Duration(milliseconds: 500),
    this.extraHeaders = const <String, String>{},
  }) : _transport = transport ?? DioLlmHttpTransport();

  @override
  final String id;

  final Uri baseUrl;
  final String apiKey;
  final LlmHttpTransport _transport;
  final AppLogger? logger;
  final int maxRetries;
  final Duration retryBaseDelay;
  final Map<String, String> extraHeaders;

  Map<String, String> get _headers => <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'text/event-stream',
    // 部分网关对 SSE 返回 gzip/br，Dio stream 模式不会自动解压。
    'Accept-Encoding': 'identity',
    if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
    ...extraHeaders,
  };

  @override
  Stream<LlmDelta> chat(ChatRequest req, {CancelToken? cancel}) async* {
    if (req.model.trim().isEmpty) {
      throw ArgumentError.value(req.model, 'req.model', '模型名不能为空（走配置注入）');
    }
    if (req.messages.isEmpty) {
      throw ArgumentError.value(req.messages, 'req.messages', '至少需要一条消息');
    }

    final candidates = <Uri>[chatCompletionsUri(baseUrl)];
    // 很多 OpenAI 兼容网关要求 /v1，而用户常只填域名。404 时自动试一次 /v1。
    if (baseUrl.path.isEmpty || baseUrl.path == '/') {
      final v1 = baseUrl.replace(path: '/v1');
      candidates.add(chatCompletionsUri(v1));
    }
    var candidateIndex = 0;
    var url = candidates.first;
    var body = buildRequestBody(req);
    var strippedTemperature = false;
    var strippedStreamOptions = false;
    var attempt = 0;
    var emitted = false;

    while (true) {
      cancel?.throwIfCancelled();
      final startedAt = DateTime.now();
      try {
        logger?.debug(
          'llm',
          'POST $url model=${req.model} attempt=${attempt + 1}',
        );
        final response = await _transport.postJson(
          LlmHttpRequest(
            url: url,
            headers: _headers,
            body: body,
            cancel: cancel,
          ),
        );
        if (response.statusCode >= 400) {
          final snippet = redact(
            await readBodySnippet(response.body),
            maxLength: 600,
          );
          // 部分模型（如 Bedrock 上的 Claude）已废弃 temperature。
          if (response.statusCode == 400 &&
              !strippedTemperature &&
              snippet.toLowerCase().contains('temperature')) {
            strippedTemperature = true;
            body = Map<String, Object?>.of(body)..remove('temperature');
            logger?.warn('llm', 'retrying without temperature: $snippet');
            continue;
          }
          if (response.statusCode == 400 &&
              !strippedStreamOptions &&
              snippet.toLowerCase().contains('stream_options')) {
            strippedStreamOptions = true;
            body = Map<String, Object?>.of(body)..remove('stream_options');
            logger?.warn('llm', 'retrying without stream_options: $snippet');
            continue;
          }
          throw _mapStatus(response.statusCode, snippet, response.headers);
        }

        LlmUsage? usage;
        String? finishReason;
        final toolCalls = <int, _ToolCallBuilder>{};
        final encoding = (response.headers['content-encoding'] ?? '')
            .toLowerCase();
        var streamBody = response.body;
        if (encoding.contains('gzip')) {
          streamBody = gzip.decoder.bind(streamBody);
        } else if (encoding.contains('deflate')) {
          streamBody = zlib.decoder.bind(streamBody);
        }

        await for (final data in sseData(streamBody)) {
          cancel?.throwIfCancelled();
          if (data == '[DONE]') {
            finishReason ??= 'stop';
            break;
          }
          final decoded = _decodeChunk(data);
          final usageJson = decoded['usage'];
          if (usageJson is Map<String, dynamic>) {
            usage = _parseUsage(usageJson);
          }
          final choices = decoded['choices'];
          if (choices is! List || choices.isEmpty) continue;
          final choice = choices.first;
          if (choice is! Map<String, dynamic>) continue;
          final reason = choice['finish_reason'];
          if (reason is String && reason.isNotEmpty) finishReason = reason;
          final delta = choice['delta'];
          if (delta is! Map<String, dynamic>) continue;

          final content = delta['content'];
          if (content is String && content.isNotEmpty) {
            emitted = true;
            yield LlmTextDelta(content);
          }
          final rawToolCalls = delta['tool_calls'];
          if (rawToolCalls is List) {
            for (final raw in rawToolCalls) {
              if (raw is! Map<String, dynamic>) continue;
              final index = raw['index'] is int ? raw['index'] as int : 0;
              toolCalls.putIfAbsent(index, _ToolCallBuilder.new).merge(raw);
            }
          }
        }

        for (final builder in toolCalls.values) {
          if (builder.name.isEmpty) continue;
          emitted = true;
          yield LlmToolCallDelta(builder.build());
        }
        if (usage != null) yield LlmUsageDelta(usage);
        yield LlmDoneDelta(finishReason: finishReason);

        logger?.debug(
          'llm',
          'done model=${req.model} latency=${DateTime.now().difference(startedAt).inMilliseconds}ms '
              'tokens=${usage?.totalTokens ?? 0}',
        );
        return;
      } on Failure catch (failure) {
        if (failure is NotFoundFailure &&
            candidateIndex + 1 < candidates.length) {
          candidateIndex++;
          url = candidates[candidateIndex];
          logger?.warn('llm', '404 at $url; trying fallback endpoint');
          continue;
        }
        final canRetry =
            !emitted &&
            attempt < maxRetries &&
            !(cancel?.isCancelled ?? false) &&
            _isRetryable(failure);
        logger?.warn(
          'llm',
          'request failed model=${req.model} attempt=${attempt + 1} retry=$canRetry: ${failure.message}',
        );
        if (!canRetry) {
          rethrow;
        }
        attempt++;
        await _backoff(attempt, failure, cancel);
      } on FormatException catch (error, stack) {
        throw ParseFailure(
          'invalid SSE chunk',
          cause: error,
          stackTrace: stack,
        );
      }
    }
  }

  Future<void> _backoff(
    int attempt,
    Failure failure,
    CancelToken? cancel,
  ) async {
    final base = retryBaseDelay * pow(2, attempt - 1);
    final retryAfter = failure is RateLimitFailure ? failure.retryAfter : null;
    final wait = retryAfter ?? base;
    final capped = wait > const Duration(seconds: 20)
        ? const Duration(seconds: 20)
        : wait;
    final end = DateTime.now().add(capped);
    while (DateTime.now().isBefore(end)) {
      cancel?.throwIfCancelled();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  bool _isRetryable(Failure failure) => switch (failure) {
    RateLimitFailure() => true,
    TimeoutFailure() => true,
    NetworkFailure(statusCode: final int code) => code >= 500,
    NetworkFailure(statusCode: null) => true,
    _ => false,
  };

  Failure _mapStatus(int status, String snippet, Map<String, String> headers) {
    final detail = snippet.isEmpty ? 'HTTP $status' : 'HTTP $status: $snippet';
    if (status == 401 || status == 403) {
      return AuthFailure(detail, statusCode: status);
    }
    if (status == 404) return NotFoundFailure(detail);
    if (status == 429) {
      return RateLimitFailure(
        detail,
        retryAfter: _parseRetryAfter(headers['retry-after']),
      );
    }
    if (status >= 500) return NetworkFailure(detail, statusCode: status);
    return NetworkFailure(detail, statusCode: status);
  }

  Duration? _parseRetryAfter(String? raw) {
    if (raw == null) return null;
    final seconds = int.tryParse(raw.trim());
    if (seconds != null) return Duration(seconds: seconds);
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      final delta = parsed.difference(DateTime.now());
      return delta.isNegative ? null : delta;
    }
    return null;
  }

  Map<String, dynamic> _decodeChunk(String data) {
    final decoded = jsonDecode(data);
    if (decoded is! Map<String, dynamic>) {
      throw const ParseFailure('SSE payload is not a JSON object');
    }
    final error = decoded['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message']?.toString() ?? 'provider error';
      throw NetworkFailure(redact(message));
    }
    return decoded;
  }

  LlmUsage _parseUsage(Map<String, dynamic> json) {
    int readInt(Object? value) =>
        value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
    final details = json['prompt_tokens_details'];
    final cached = details is Map<String, dynamic>
        ? readInt(details['cached_tokens'])
        : 0;
    return LlmUsage(
      promptTokens: readInt(json['prompt_tokens']),
      completionTokens: readInt(json['completion_tokens']),
      totalTokens: readInt(json['total_tokens']),
      cachedPromptTokens: cached,
    );
  }

  /// 请求体构造，公开以便测试与调试（不含密钥）。
  static Map<String, Object?> buildRequestBody(ChatRequest req) {
    return <String, Object?>{
      'model': req.model,
      'messages': req.messages.map(_messageJson).toList(growable: false),
      'temperature': req.temperature,
      'stream': true,
      'stream_options': <String, Object?>{'include_usage': true},
      if (req.maxTokens != null) 'max_tokens': req.maxTokens,
      if (req.tools.isNotEmpty)
        'tools': req.tools
            .map(
              (ToolDefinition tool) => <String, Object?>{
                'type': 'function',
                'function': <String, Object?>{
                  'name': tool.name,
                  'description': tool.description,
                  'parameters': tool.parameters,
                  if (tool.strict) 'strict': true,
                },
              },
            )
            .toList(growable: false),
      if (req.forceJson)
        'response_format': <String, Object?>{'type': 'json_object'},
      ...req.extraBody,
    };
  }

  static Map<String, Object?> _messageJson(ChatMessage message) {
    return <String, Object?>{
      'role': message.role.name,
      'content': message.content,
      if (message.toolCalls.isNotEmpty)
        'tool_calls': message.toolCalls
            .map(
              (ToolCall call) => <String, Object?>{
                'id': call.id,
                'type': 'function',
                'function': <String, Object?>{
                  'name': call.name,
                  'arguments': jsonEncode(call.arguments),
                },
              },
            )
            .toList(growable: false),
      if (message.toolCallId != null) 'tool_call_id': message.toolCallId,
      if (message.name != null) 'name': message.name,
    };
  }
}

class _ToolCallBuilder {
  String id = '';
  String name = '';
  final StringBuffer _arguments = StringBuffer();

  void merge(Map<String, dynamic> raw) {
    final rawId = raw['id'];
    if (rawId is String && rawId.isNotEmpty) id = rawId;
    final function = raw['function'];
    if (function is Map<String, dynamic>) {
      final rawName = function['name'];
      if (rawName is String && rawName.isNotEmpty) name = rawName;
      final args = function['arguments'];
      if (args is String) _arguments.write(args);
    }
  }

  ToolCall build() {
    final raw = _arguments.toString();
    Map<String, Object?> args = const <String, Object?>{};
    if (raw.trim().isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        args = decoded;
      } else {
        throw ParseFailure('tool call arguments must be a JSON object');
      }
    }
    return ToolCall(id: id, name: name, arguments: args);
  }
}
