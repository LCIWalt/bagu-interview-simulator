import 'dart:convert';

import '../contracts/contracts.dart';
import '../util/redact.dart';
import 'domain_authority.dart';
import 'page_fetcher.dart';
import 'search_cache.dart';
import 'search_transport.dart';

/// OpenAI 兼容的 Web Search（`web_search_options`）作为 SearchProvider。
///
/// 仅把返回的 `url_citation` 当作候选 URL；正文仍由 PageFetcher 抓取并做
/// 权威分级/逐字证据校验，不直接采信模型回答。
class OpenAiWebSearchProvider implements SearchProvider {
  OpenAiWebSearchProvider({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    SearchTransport? transport,
    PageCache? cache,
  }) : _transport = transport ?? DioSearchTransport(),
       _fetcher = PageFetcher(transport: transport ?? DioSearchTransport()) {
    _cache = cache;
  }

  final String apiKey;
  final Uri baseUrl;
  final String model;
  final SearchTransport _transport;
  final PageFetcher _fetcher;
  PageCache? _cache;

  @override
  String get id => 'openai-web-search';

  Uri get _chatUri {
    var path = baseUrl.path;
    while (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    if (path.endsWith('/chat/completions')) {
      return baseUrl.replace(path: path);
    }
    path = path.isEmpty ? '/chat/completions' : '$path/chat/completions';
    return baseUrl.replace(path: path);
  }

  @override
  Future<List<SearchHit>> search(SearchQuery q) async {
    if (apiKey.trim().isEmpty) {
      throw const AuthFailure('web search api key is missing');
    }
    if (model.trim().isEmpty) {
      throw const ParseFailure('web search model is empty');
    }
    final response = await _transport.postJson(
      _chatUri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'Accept-Encoding': 'identity',
      },
      body: <String, Object?>{
        'model': model,
        'messages': <Object?>[
          <String, Object?>{'role': 'user', 'content': q.query},
        ],
        'web_search_options': <String, Object?>{
          'search_context_size': 'medium',
        },
        'stream': false,
      },
    );
    final text = await _read(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _failure(response.statusCode, text);
    }
    final decoded = _decode(text);
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) return const <SearchHit>[];
    final message = (choices.first as Map<String, dynamic>)['message'];
    if (message is! Map<String, dynamic>) return const <SearchHit>[];
    final content = message['content']?.toString() ?? '';
    final annotations = message['annotations'];
    final hits = <String, SearchHit>{};
    if (annotations is List) {
      for (final raw in annotations) {
        if (raw is! Map<String, dynamic>) continue;
        final citation = raw['url_citation'];
        if (citation is! Map<String, dynamic>) continue;
        final url = citation['url']?.toString() ?? '';
        if (url.isEmpty) continue;
        final title = citation['title']?.toString() ?? url;
        hits.putIfAbsent(
          url,
          () => SearchHit(
            url: url,
            title: title,
            snippet: redact(content, maxLength: 500),
            authority: DomainAuthority.classify(url),
          ),
        );
        if (hits.length >= q.maxResults) break;
      }
    }
    if (hits.isEmpty && content.isNotEmpty) {
      // 部分网关不返回 annotations，只把链接写进正文；只取 http(s) URL。
      for (final match in RegExp(
        r'https?://[^\s)\]<>"]+',
      ).allMatches(content)) {
        final url = match.group(0)!.replaceAll(RegExp(r'[.,;:!?]+$'), '');
        hits.putIfAbsent(
          url,
          () => SearchHit(
            url: url,
            title: url,
            snippet: redact(content, maxLength: 500),
            authority: DomainAuthority.classify(url),
          ),
        );
        if (hits.length >= q.maxResults) break;
      }
    }
    return hits.values.toList(growable: false);
  }

  @override
  Future<ExtractedPage> fetch(String url) async {
    final cached = await _cache?.get(url);
    if (cached != null) return cached;
    final page = await _fetcher.fetch(url);
    await _cache?.put(page);
    return page;
  }

  Failure _failure(int status, String body) {
    final detail = redact(body, maxLength: 400);
    if (status == 401 || status == 403) {
      return AuthFailure(
        'web search http $status: $detail',
        statusCode: status,
      );
    }
    if (status == 429) {
      return const RateLimitFailure('web search rate limited');
    }
    if (status == 400 || status == 404) {
      return NetworkFailure(
        'web search http $status: $detail',
        statusCode: status,
      );
    }
    return NetworkFailure(
      'web search http $status: $detail',
      statusCode: status,
    );
  }

  Future<String> _read(
    Stream<List<int>> body, {
    int maxBytes = 1024 * 1024,
  }) async {
    final bytes = <int>[];
    await for (final chunk in body) {
      if (bytes.length + chunk.length > maxBytes) {
        throw const ParseFailure('web search response too large');
      }
      bytes.addAll(chunk);
    }
    return utf8.decode(bytes, allowMalformed: true);
  }

  Map<String, dynamic> _decode(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw const ParseFailure('web search response is not an object');
      }
      return decoded;
    } on FormatException catch (error) {
      throw ParseFailure('web search invalid JSON', cause: error);
    }
  }
}
