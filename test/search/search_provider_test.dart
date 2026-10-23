import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/search/domain_authority.dart';
import 'package:mockmate/core/search/page_fetcher.dart';
import 'package:mockmate/core/search/search_cache.dart';
import 'package:mockmate/core/search/search_transport.dart';
import 'package:mockmate/core/search/tavily_provider.dart';

class _FakeTransport implements SearchTransport {
  _FakeTransport({
    this.postBody,
    this.getBody,
    this.status = 200,
    this.headers = const {},
  });

  final String? postBody;
  final String? getBody;
  final int status;
  final Map<String, String> headers;
  final List<Uri> posts = <Uri>[];
  final List<Uri> gets = <Uri>[];

  @override
  Future<SearchResponse> postJson(
    Uri url, {
    required Map<String, String> headers,
    required Map<String, Object?> body,
  }) async {
    posts.add(url);
    return SearchResponse(
      statusCode: status,
      body: Stream<List<int>>.value(utf8.encode(postBody ?? '{}')),
      headers: this.headers,
    );
  }

  @override
  Future<SearchResponse> get(
    Uri url, {
    required Map<String, String> headers,
  }) async {
    gets.add(url);
    return SearchResponse(
      statusCode: status,
      body: Stream<List<int>>.value(utf8.encode(getBody ?? '')),
      headers: <String, String>{
        'content-type': 'text/html; charset=utf-8',
        ...this.headers,
      },
    );
  }

  @override
  void close() {}
}

void main() {
  group('DomainAuthority / validateFetchUrl', () {
    test('classifies sources', () {
      expect(
        DomainAuthority.classify('https://go.dev/doc/x'),
        SourceAuthority.a,
      );
      expect(
        DomainAuthority.classify('https://www.rfc-editor.org/rfc/rfc9293'),
        SourceAuthority.a,
      );
      expect(
        DomainAuthority.classify('https://netflixtechblog.com/x'),
        SourceAuthority.b,
      );
      expect(
        DomainAuthority.classify('https://stackoverflow.com/q/1'),
        SourceAuthority.c,
      );
      expect(
        DomainAuthority.classify('https://baijiahao.baidu.com/x'),
        SourceAuthority.d,
      );
    });

    test('rejects local and non-http urls', () {
      expect(validateFetchUrl('http://localhost/x'), isNotNull);
      expect(validateFetchUrl('http://127.0.0.1/x'), isNotNull);
      expect(validateFetchUrl('http://192.168.1.4/x'), isNotNull);
      expect(validateFetchUrl('http://169.254.169.254/latest'), isNotNull);
      expect(validateFetchUrl('ftp://example.com/x'), isNotNull);
      expect(validateFetchUrl('https://go.dev/doc'), isNull);
    });
  });

  group('PageFetcher', () {
    test(
      'extracts readable text, strips scripts and wraps size limits',
      () async {
        final html = '''
<html><head><title>Go 文档</title><style>.x{}</style></head>
<body><nav>导航</nav><article><h1>GMP</h1><p>P 提供执行上下文。</p>
<script>alert(1)</script></article><footer>页脚</footer></body></html>
''';
        final fetcher = PageFetcher(
          transport: _FakeTransport(getBody: html),
          delay: (Duration _) async {},
        );
        final page = await fetcher.fetch('https://go.dev/doc/gmp');
        expect(page.title, 'Go 文档');
        expect(page.textMarkdown, contains('P 提供执行上下文'));
        expect(page.textMarkdown, isNot(contains('alert')));
        expect(page.textMarkdown, isNot(contains('导航')));
        expect(page.authority, SourceAuthority.a);
      },
    );

    test('rejects non-html content and oversized pages', () async {
      final fetcher = PageFetcher(
        transport: _FakeTransport(
          getBody: 'x' * 20,
          headers: <String, String>{'content-type': 'application/pdf'},
        ),
        delay: (Duration _) async {},
        maxBytes: 10,
      );
      expect(
        () => fetcher.fetch('https://example.com/a.pdf'),
        throwsA(isA<ParseFailure>()),
      );
    });

    test('rejects private URL before calling transport', () async {
      final transport = _FakeTransport(getBody: '<html><body>x</body></html>');
      final fetcher = PageFetcher(
        transport: transport,
        delay: (Duration _) async {},
      );
      await expectLater(
        fetcher.fetch('http://10.0.0.1/secret'),
        throwsA(isA<NetworkFailure>()),
      );
      expect(transport.gets, isEmpty);
    });
  });

  group('TavilySearchProvider', () {
    String results(List<Map<String, Object?>> items) =>
        jsonEncode(<String, Object?>{'results': items});

    test('normalizes results and dedupes across rewritten queries', () async {
      final transport = _FakeTransport(
        postBody: results(<Map<String, Object?>>[
          <String, Object?>{
            'url': 'https://go.dev/doc/1',
            'title': 'A',
            'content': 'snippet',
            'published_date': '2026-01-01T00:00:00Z',
          },
          <String, Object?>{
            'url': 'https://go.dev/doc/1',
            'title': 'A2',
            'content': 'dup',
          },
        ]),
      );
      final provider = TavilySearchProvider(
        apiKey: 'k',
        transport: transport,
        rewriter: _Rewriter(),
      );
      final hits = await provider.search(const SearchQuery(query: 'GMP'));
      expect(hits, hasLength(1));
      expect(hits.single.authority, SourceAuthority.a);
      expect(hits.single.snippet, 'snippet');
      expect(transport.posts, hasLength(2));
    });

    test('missing key is AuthFailure', () async {
      final provider = TavilySearchProvider(
        apiKey: '',
        transport: _FakeTransport(),
      );
      await expectLater(
        provider.search(const SearchQuery(query: 'q')),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('429 is RateLimitFailure', () async {
      final provider = TavilySearchProvider(
        apiKey: 'k',
        transport: _FakeTransport(status: 429),
      );
      await expectLater(
        provider.search(const SearchQuery(query: 'q')),
        throwsA(isA<RateLimitFailure>()),
      );
    });
  });

  test('page cache stores and expires entries', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final cache = DriftPageCache(db);
    final page = ExtractedPage(
      url: 'https://go.dev/doc',
      title: 't',
      textMarkdown: 'body',
      fetchedAt: DateTime.now(),
      authority: SourceAuthority.a,
    );
    await cache.put(page, ttl: const Duration(hours: 1));
    final cached = await cache.get(page.url);
    expect(cached?.title, 't');

    await cache.put(page, ttl: const Duration(seconds: -1));
    expect(await cache.get(page.url), isNull);
  });
}

class _Rewriter implements SearchQueryRewriter {
  @override
  Future<List<String>> rewrite(String query) async => <String>[
    query,
    '$query docs',
  ];
}
