import 'failure.dart';

/// 来源权威分级（指南 §7.3.2）：A 一手、B 高质量二手、C 社区、D 排除。
enum SourceAuthority { a, b, c, d }

class SearchQuery {
  const SearchQuery({
    required this.query,
    this.maxResults = 5,
    this.locale = 'zh-CN',
    this.freshnessDays,
  });

  final String query;
  final int maxResults;
  final String locale;
  final int? freshnessDays;
}

class SearchHit {
  const SearchHit({
    required this.url,
    required this.title,
    required this.snippet,
    this.publishedAt,
    this.authority = SourceAuthority.c,
  });

  final String url;
  final String title;
  final String snippet;
  final DateTime? publishedAt;
  final SourceAuthority authority;
}

/// 抓取后的正文；`textMarkdown` 已去除脚本/样式，仍按不可信输入处理。
class ExtractedPage {
  const ExtractedPage({
    required this.url,
    required this.title,
    required this.textMarkdown,
    required this.fetchedAt,
    this.contentType = 'text/html',
    this.authority = SourceAuthority.c,
  });

  final String url;
  final String title;
  final String textMarkdown;
  final DateTime fetchedAt;
  final String contentType;
  final SourceAuthority authority;
}

abstract interface class SearchProvider {
  String get id;

  Future<List<SearchHit>> search(SearchQuery q);

  Future<ExtractedPage> fetch(String url);
}

/// 所有抓取内容进入模型前必须包裹为不可信块（指南 §5.3）。
String wrapUntrusted(String content, {String source = 'web'}) =>
    '<untrusted source="$source">\n$content\n</untrusted>';

/// 抓取失败的统一构造，方便上层区分「无网络」与「内容不可用」。
Failure fetchFailure(String message, {Object? cause}) =>
    NetworkFailure(message, cause: cause);
