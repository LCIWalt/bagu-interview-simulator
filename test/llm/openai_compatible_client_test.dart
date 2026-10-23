import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/llm/openai_compatible_client.dart';
import 'package:mockmate/core/llm/transport.dart';

class _FakeTransport implements LlmHttpTransport {
  _FakeTransport(this._responses);

  final List<LlmHttpResponse Function()> _responses;
  final List<LlmHttpRequest> requests = <LlmHttpRequest>[];
  bool closed = false;

  @override
  Future<LlmHttpResponse> postJson(LlmHttpRequest request) async {
    requests.add(request);
    if (_responses.isEmpty) {
      throw StateError('no fake response');
    }
    return _responses.removeAt(0)();
  }

  @override
  void close() => closed = true;
}

LlmHttpResponse _sse(
  String raw, {
  int status = 200,
  Map<String, String> headers = const {},
}) {
  return LlmHttpResponse(
    statusCode: status,
    headers: headers,
    body: Stream<List<int>>.value(utf8.encode(raw)),
  );
}

OpenAiCompatibleClient _client(LlmHttpTransport transport) =>
    OpenAiCompatibleClient(
      id: 'test',
      baseUrl: Uri.parse('https://api.example.com/v1'),
      apiKey: 'sk-secret-key-value',
      transport: transport,
      maxRetries: 2,
      retryBaseDelay: const Duration(milliseconds: 1),
    );

const ChatRequest _request = ChatRequest(
  model: 'm1',
  messages: <ChatMessage>[ChatMessage.user('hi')],
);

void main() {
  group('chatCompletionsUri', () {
    test('appends endpoint to bare and versioned base URLs', () {
      expect(
        chatCompletionsUri(Uri.parse('https://api.deepseek.com')).toString(),
        'https://api.deepseek.com/chat/completions',
      );
      expect(
        chatCompletionsUri(Uri.parse('https://api.deepseek.com/v1/'))
            .toString(),
        'https://api.deepseek.com/v1/chat/completions',
      );
      expect(
        chatCompletionsUri(Uri.parse('https://x.dev/v1/chat/completions'))
            .toString(),
        'https://x.dev/v1/chat/completions',
      );
    });
  });

  group('sseData', () {
    test('handles CRLF, comments and multi-line data', () async {
      final stream = Stream<List<int>>.fromIterable(<List<int>>[
        utf8.encode(': ping\r\ndata: a\r\n\r\ndata: b\r\ndata: c\r\n\r\n'),
      ]);
      expect(await sseData(stream).toList(), <String>['a', 'b\nc']);
    });

    test('ignores non-data fields', () async {
      final stream = Stream<List<int>>.value(
        utf8.encode('event: message\nid: 1\ndata: {"ok":true}\n\n'),
      );
      expect(await sseData(stream).toList(), <String>['{"ok":true}']);
    });
  });

  group('OpenAiCompatibleClient', () {
    test('streams text, tool calls, usage and done', () async {
      const raw =
          'data: {"choices":[{"delta":{"content":"你好"},"finish_reason":null}]}\n\n'
          'data: {"choices":[{"delta":{"tool_calls":[{"index":0,"id":"call_1",'
          '"function":{"name":"get_question","arguments":"{\\"id\\":"}}]}}]}\n\n'
          'data: {"choices":[{"delta":{"tool_calls":[{"index":0,'
          '"function":{"arguments":"\\"q1\\"}"}}]}}]}\n\n'
          'data: {"choices":[{"delta":{},"finish_reason":"tool_calls"}],'
          '"usage":{"prompt_tokens":10,"completion_tokens":5,"total_tokens":15,'
          '"prompt_tokens_details":{"cached_tokens":4}}}\n\n'
          'data: [DONE]\n\n';
      final transport = _FakeTransport(<LlmHttpResponse Function()>[
        () => _sse(raw),
      ]);
      final deltas = await _client(transport).chat(_request).toList();

      expect(deltas.whereType<LlmTextDelta>().single.text, '你好');
      final call = deltas.whereType<LlmToolCallDelta>().single.call;
      expect(call.id, 'call_1');
      expect(call.name, 'get_question');
      expect(call.arguments, <String, Object?>{'id': 'q1'});
      final usage = deltas.whereType<LlmUsageDelta>().single.usage;
      expect(usage.totalTokens, 15);
      expect(usage.cachedPromptTokens, 4);
      expect(
        deltas.whereType<LlmDoneDelta>().single.finishReason,
        'tool_calls',
      );
      expect(transport.requests.single.url.path, '/v1/chat/completions');
      expect(
        transport.requests.single.headers['Authorization'],
        'Bearer sk-secret-key-value',
      );
      expect(transport.requests.single.headers['Accept-Encoding'], 'identity');
    });

    test('decompresses gzip SSE responses', () async {
      const raw =
          'data: {"choices":[{"delta":{"content":"gz"},"finish_reason":"stop"}]}\n\n'
          'data: [DONE]\n\n';
      final transport = _FakeTransport(<LlmHttpResponse Function()>[
        () => LlmHttpResponse(
          statusCode: 200,
          headers: const <String, String>{'content-encoding': 'gzip'},
          body: Stream<List<int>>.value(gzip.encode(utf8.encode(raw))),
        ),
      ]);
      final deltas = await _client(transport).chat(_request).toList();
      expect(deltas.whereType<LlmTextDelta>().single.text, 'gz');
    });

    test('retries 400 without temperature when model rejects it', () async {
      final transport = _FakeTransport(<LlmHttpResponse Function()>[
        () => _sse(
          '{"error":{"message":"temperature is deprecated for this model"}}',
          status: 400,
        ),
        () => _sse(
          'data: {"choices":[{"delta":{"content":"ok"},"finish_reason":"stop"}]}\n\n'
          'data: [DONE]\n\n',
        ),
      ]);
      final deltas = await _client(transport).chat(_request).toList();
      expect(deltas.whereType<LlmTextDelta>().single.text, 'ok');
      expect(transport.requests.length, 2);
      expect(transport.requests.last.body.containsKey('temperature'), isFalse);
    });

    test('retries 429 then succeeds without duplicating output', () async {
      final transport = _FakeTransport(<LlmHttpResponse Function()>[
        () => _sse(
          '{"error":{"message":"rate limited"}}',
          status: 429,
          headers: {'retry-after': '0'},
        ),
        () => _sse(
          'data: {"choices":[{"delta":{"content":"ok"},"finish_reason":"stop"}]}\n\n'
          'data: [DONE]\n\n',
        ),
      ]);
      final deltas = await _client(transport).chat(_request).toList();
      expect(transport.requests.length, 2);
      expect(deltas.whereType<LlmTextDelta>().single.text, 'ok');
    });

    test('maps 401 to AuthFailure without retry', () async {
      final transport = _FakeTransport(<LlmHttpResponse Function()>[
        () => _sse('{"error":{"message":"bad key"}}', status: 401),
      ]);
      await expectLater(
        _client(transport).chat(_request),
        emitsError(isA<AuthFailure>()),
      );
      expect(transport.requests.length, 1);
    });

    test('falls back to /v1 when bare base URL returns 404', () async {
      final transport = _FakeTransport(<LlmHttpResponse Function()>[
        () => _sse('page not found', status: 404),
        () => _sse(
          'data: {"choices":[{"delta":{"content":"ok"},"finish_reason":"stop"}]}\n\n'
          'data: [DONE]\n\n',
        ),
      ]);
      final client = OpenAiCompatibleClient(
        id: 'test',
        baseUrl: Uri.parse('https://api.uniapi.io'),
        apiKey: 'k',
        transport: transport,
      );
      final deltas = await client.chat(_request).toList();
      expect(deltas.whereType<LlmTextDelta>().single.text, 'ok');
      expect(transport.requests.last.url.path, '/v1/chat/completions');
    });

    test('maps 404 to NotFoundFailure', () async {
      final transport = _FakeTransport(<LlmHttpResponse Function()>[
        () => _sse('model not found', status: 404),
      ]);
      await expectLater(
        _client(transport).chat(_request),
        emitsError(isA<NotFoundFailure>()),
      );
    });

    test('honours pre-cancelled token', () async {
      final transport = _FakeTransport(<LlmHttpResponse Function()>[]);
      final cancel = CancelToken()..cancel();
      await expectLater(
        _client(transport).chat(_request, cancel: cancel),
        emitsError(isA<CancelledFailure>()),
      );
      expect(transport.requests, isEmpty);
    });

    test('builds tools and json response_format', () {
      final body = OpenAiCompatibleClient.buildRequestBody(
        const ChatRequest(
          model: 'm2',
          messages: <ChatMessage>[
            ChatMessage.system('sys'),
            ChatMessage.assistant(
              '',
              toolCalls: <ToolCall>[
                ToolCall(
                  id: 'c',
                  name: 'get_question',
                  arguments: <String, Object?>{'id': 'q'},
                ),
              ],
            ),
            ChatMessage.tool(content: '{}', toolCallId: 'c'),
          ],
          tools: <ToolDefinition>[
            ToolDefinition(
              name: 'get_question',
              description: 'read question',
              parameters: <String, Object?>{'type': 'object'},
            ),
          ],
          forceJson: true,
          maxTokens: 100,
        ),
      );
      expect(body['stream'], true);
      expect(body['response_format'], <String, Object?>{'type': 'json_object'});
      expect(body['max_tokens'], 100);
      final tools = body['tools']! as List<Object?>;
      expect((tools.single! as Map<String, Object?>)['type'], 'function');
      final messages = body['messages']! as List<Object?>;
      expect(
        (messages[1]! as Map<String, Object?>)['tool_calls'],
        isA<List<Object?>>(),
      );
      expect((messages[2]! as Map<String, Object?>)['tool_call_id'], 'c');
    });

    test('rejects empty model', () async {
      final transport = _FakeTransport(<LlmHttpResponse Function()>[]);
      await expectLater(
        _client(transport).chat(
          const ChatRequest(
            model: ' ',
            messages: <ChatMessage>[ChatMessage.user('x')],
          ),
        ),
        emitsError(isA<ArgumentError>()),
      );
    });
  });
}
