import 'dart:async';
import 'dart:convert';

import 'package:html/parser.dart' as html_parser;

import '../contracts/contracts.dart';
import 'domain_authority.dart';
import 'search_transport.dart';

/// 单页抓取（T-051）：安全 URL、体积/类型限制、限速、正文抽取，`<untrusted>` 由上层包裹。
class PageFetcher {
  PageFetcher({
    required this.transport,
    this.maxBytes = 2 * 1024 * 1024,
    this.maxTextChars = 100000,
    this.minHostInterval = const Duration(seconds: 1),
    Future<void> Function(Duration)? delay,
  }) : _delay = delay ?? Future<void>.delayed;

  final SearchTransport transport;
  final int maxBytes;
  final int maxTextChars;
  final Duration minHostInterval;
  final Future<void> Function(Duration) _delay;
  final Map<String, DateTime> _lastFetch = <String, DateTime>{};

  Future<ExtractedPage> fetch(String url) async {
    final error = validateFetchUrl(url);
    if (error != null) throw NetworkFailure(error);
    final uri = Uri.parse(url);
    final now = DateTime.now();
    final last = _lastFetch[uri.host];
    if (last != null) {
      final wait = minHostInterval - now.difference(last);
      if (wait > Duration.zero) await _delay(wait);
    }
    _lastFetch[uri.host] = DateTime.now();

    final response = await transport.get(
      uri,
      headers: const <String, String>{
        'Accept': 'text/html,application/xhtml+xml,text/plain;q=0.9',
        'User-Agent':
            'BaguInterviewSimulator/0.1 (self-use interview practice)',
      },
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw AuthFailure(
        'fetch http ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    if (response.statusCode == 429) {
      throw const RateLimitFailure('fetch http 429');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NetworkFailure(
        'fetch http ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('text/html') &&
        !contentType.contains('text/plain')) {
      throw const ParseFailure('unsupported content-type');
    }

    final bytes = <int>[];
    await for (final chunk in response.body) {
      if (bytes.length + chunk.length > maxBytes) {
        throw const ParseFailure('page exceeds size limit');
      }
      bytes.addAll(chunk);
    }
    final charset = _charset(contentType);
    final htmlText = charset == 'iso-8859-1'
        ? latin1.decode(bytes, allowInvalid: true)
        : utf8.decode(bytes, allowMalformed: true);
    return extract(url: url, htmlText: htmlText, fetchedAt: DateTime.now());
  }

  ExtractedPage extract({
    required String url,
    required String htmlText,
    required DateTime fetchedAt,
  }) {
    final document = html_parser.parse(htmlText);
    for (final tag in <String>[
      'script',
      'style',
      'noscript',
      'nav',
      'footer',
      'header',
      'svg',
    ]) {
      for (final element in document.querySelectorAll(tag)) {
        element.remove();
      }
    }
    final title =
        (document.querySelector('title')?.text ??
                document.querySelector('h1')?.text ??
                url)
            .trim();
    final root = document.querySelector('article') ?? document.body;
    final text = (root?.text ?? '')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n+'), '\n\n')
        .trim();
    if (text.isEmpty) throw const ParseFailure('page has no readable text');
    return ExtractedPage(
      url: url,
      title: title.isEmpty ? url : title,
      textMarkdown: text.length > maxTextChars
          ? text.substring(0, maxTextChars)
          : text,
      fetchedAt: fetchedAt,
      authority: DomainAuthority.classify(url),
    );
  }

  String _charset(String contentType) {
    final match = RegExp(
      r'charset=([\w-]+)',
      caseSensitive: false,
    ).firstMatch(contentType);
    return match?.group(1)?.toLowerCase() ?? 'utf-8';
  }
}
