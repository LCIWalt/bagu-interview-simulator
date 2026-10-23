import 'dart:async';
import 'dart:convert';

import '../contracts/contracts.dart';
import '../util/redact.dart';
import 'domain_authority.dart';
import 'page_fetcher.dart';
import 'search_cache.dart';
import 'search_transport.dart';

abstract interface class SearchQueryRewriter {
  Future<List<String>> rewrite(String query);
}

class PassthroughQueryRewriter implements SearchQueryRewriter {
  const PassthroughQueryRewriter();

  @override
  Future<List<String>> rewrite(String query) async => <String>[query];
}

/// Tavily 搜索 + 单页抓取（T-050/T-051）。
class TavilySearchProvider implements SearchProvider {
  TavilySearchProvider({
    required this.apiKey,
    Uri? baseUrl,
    SearchTransport? transport,
    SearchQueryRewriter? rewriter,
    PageCache? cache,
    this.timeout = const Duration(seconds: 15),
  }) : _baseUrl = baseUrl ?? Uri.parse('https://api.tavily.com'),
       _transport = transport ?? DioSearchTransport(),
       _rewriter = rewriter ?? const PassthroughQueryRewriter(),
       _fetcher = PageFetcher(transport: transport ?? DioSearchTransport()) {
    if (cache != null) {
      _cache = cache;
    }
  }

  final String apiKey;
  final Uri _baseUrl;
  final SearchTransport _transport;
  final SearchQueryRewriter _rewriter;
  final PageFetcher _fetcher;
  final Duration timeout;
  PageCache? _cache;

  @override
  String get id => 'tavily';

  Uri get _searchUri {
    final base = _baseUrl.toString().replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base/search');
  }

  @override
  Future<List<SearchHit>> search(SearchQuery q) async {
    if (apiKey.trim().isEmpty) {
      throw const AuthFailure('tavily api key is missing');
    }
    final queries = await _rewriter.rewrite(q.query);
    final hits = <String, SearchHit>{};
    for (final query in queries) {
      final response = await _transport.postJson(
        _searchUri,
        headers: const <String, String>{'Content-Type': 'application/json'},
        body: <String, Object?>{
          'api_key': apiKey,
          'query': query,
          'max_results': q.maxResults,
          'search_depth': 'basic',
          'include_answer': false,
          'include_raw_content': false,
        },
      );
      _checkStatus(response.statusCode);
      final text = await _read(response.body);
      final decoded = _decode(text);
      final results = decoded['results'];
      if (results is! List) continue;
      for (final item in results) {
        if (item is! Map<String, dynamic>) continue;
        final url = item['url']?.toString() ?? '';
        final hit = SearchHit(
          url: url,
          title: item['title']?.toString() ?? url,
          snippet: redact(item['content']?.toString() ?? '', maxLength: 500),
          publishedAt: DateTime.tryParse(
            item['published_date']?.toString() ?? '',
          ),
          authority: DomainAuthority.classify(url),
        );
        if (url.isNotEmpty) hits.putIfAbsent(url, () => hit);
      }
    }
    final list = hits.values.toList();
    return list.take(q.maxResults).toList(growable: false);
  }

  @override
  Future<ExtractedPage> fetch(String url) async {
    final cached = await _cache?.get(url);
    if (cached != null) return cached;
    final page = await _fetcher.fetch(url);
    await _cache?.put(page);
    return page;
  }

  void _checkStatus(int status) {
    if (status == 401 || status == 403) {
      throw AuthFailure('tavily http $status', statusCode: status);
    }
    if (status == 429) {
      throw const RateLimitFailure('tavily rate limited');
    }
    if (status < 200 || status >= 300) {
      throw NetworkFailure('tavily http $status', statusCode: status);
    }
  }

  Future<String> _read(
    Stream<List<int>> body, {
    int maxBytes = 1024 * 1024,
  }) async {
    final bytes = <int>[];
    await for (final chunk in body) {
      if (bytes.length + chunk.length > maxBytes) {
        throw const ParseFailure('search response too large');
      }
      bytes.addAll(chunk);
    }
    return utf8.decode(bytes, allowMalformed: true);
  }

  Map<String, dynamic> _decode(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw const ParseFailure('tavily response is not a JSON object');
      }
      return decoded;
    } on FormatException catch (error) {
      throw ParseFailure('tavily response is invalid JSON', cause: error);
    }
  }
}
