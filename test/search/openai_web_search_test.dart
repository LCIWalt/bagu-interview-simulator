import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/search/openai_web_search.dart';
import 'package:mockmate/core/search/search_transport.dart';

class _FakeTransport implements SearchTransport {
  _FakeTransport(this.body, {this.status = 200});

  final String body;
  final int status;
  final List<Uri> posts = <Uri>[];

  @override
  Future<SearchResponse> postJson(
    Uri url, {
    required Map<String, String> headers,
    required Map<String, Object?> body,
  }) async {
    posts.add(url);
    return SearchResponse(
      statusCode: status,
      body: Stream<List<int>>.value(utf8.encode(this.body)),
    );
  }

  @override
  Future<SearchResponse> get(
    Uri url, {
    required Map<String, String> headers,
  }) async {
    return SearchResponse(
      statusCode: 200,
      body: Stream<List<int>>.value(
        utf8.encode('<html><title>t</title><body>body</body></html>'),
      ),
      headers: const <String, String>{'content-type': 'text/html'},
    );
  }

  @override
  void close() {}
}

String _response() => jsonEncode(<String, Object?>{
  'choices': <Object?>[
    <String, Object?>{
      'message': <String, Object?>{
        'content': 'GMP 参考 https://go.dev/doc/gmp',
        'annotations': <Object?>[
          <String, Object?>{
            'type': 'url_citation',
            'url_citation': <String, Object?>{
              'url': 'https://go.dev/doc/gmp',
              'title': 'Go GMP',
            },
          },
          <String, Object?>{
            'type': 'url_citation',
            'url_citation': <String, Object?>{
              'url': 'https://stackoverflow.com/q/1',
              'title': 'SO',
            },
          },
        ],
      },
    },
  ],
});

void main() {
  test('parses url_citation annotations into search hits', () async {
    final transport = _FakeTransport(_response());
    final provider = OpenAiWebSearchProvider(
      apiKey: 'k',
      baseUrl: Uri.parse('https://api.uniapi.io/v1'),
      model: 'gpt-4o-mini-search-preview',
      transport: transport,
    );
    final hits = await provider.search(const SearchQuery(query: 'GMP'));
    expect(hits, hasLength(2));
    expect(hits.first.url, 'https://go.dev/doc/gmp');
    expect(hits.first.authority, SourceAuthority.a);
    expect(transport.posts.single.path, '/v1/chat/completions');
  });

  test('maps 401 to AuthFailure', () async {
    final provider = OpenAiWebSearchProvider(
      apiKey: 'k',
      baseUrl: Uri.parse('https://api.uniapi.io/v1'),
      model: 'm',
      transport: _FakeTransport('{"error":"bad key"}', status: 401),
    );
    await expectLater(
      provider.search(const SearchQuery(query: 'q')),
      throwsA(isA<AuthFailure>()),
    );
  });
}
