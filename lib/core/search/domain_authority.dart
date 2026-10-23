import '../contracts/contracts.dart';

/// 来源权威分级（指南 §7.3.2）。A 一手、B 高质量二手、C 社区、D 排除。
abstract final class DomainAuthority {
  static const Set<String> _firstParty = <String>{
    'go.dev',
    'golang.org',
    'docs.python.org',
    'developer.mozilla.org',
    'w3.org',
    'rfc-editor.org',
    'ietf.org',
    'kernel.org',
    'postgresql.org',
    'dev.mysql.com',
    'redis.io',
    'kubernetes.io',
    'react.dev',
    'nodejs.org',
    'docs.oracle.com',
    'learn.microsoft.com',
    'docs.aws.amazon.com',
    'developer.apple.com',
    'openjdk.org',
    'sqlite.org',
  };

  static const Set<String> _qualitySecondary = <String>{
    'netflixtechblog.com',
    'engineering.fb.com',
    'uber.com',
    'cloudflare.com',
    'github.blog',
    'aws.amazon.com',
    'infoq.com',
  };

  static const Set<String> _community = <String>{
    'stackoverflow.com',
    'segmentfault.com',
    'juejin.cn',
    'zhihu.com',
    'csdn.net',
    'cnblogs.com',
    'reddit.com',
    'dev.to',
    'medium.com',
    'v2ex.com',
  };

  static const Set<String> _excluded = <String>{
    'baijiahao.baidu.com',
    'toutiao.com',
    'sohu.com',
    '163.com',
    'qq.com',
  };

  static SourceAuthority classify(String url) {
    final host = _host(url);
    if (host.isEmpty) return SourceAuthority.d;
    if (_excluded.any((String domain) => _matches(host, domain))) {
      return SourceAuthority.d;
    }
    if (host.endsWith('.gov') || host.endsWith('.edu')) {
      return SourceAuthority.a;
    }
    if (_firstParty.any((String domain) => _matches(host, domain))) {
      return SourceAuthority.a;
    }
    if (_qualitySecondary.any((String domain) => _matches(host, domain))) {
      return SourceAuthority.b;
    }
    if (_community.any((String domain) => _matches(host, domain))) {
      return SourceAuthority.c;
    }
    return SourceAuthority.c;
  }

  static bool _matches(String host, String domain) =>
      host == domain || host.endsWith('.$domain');

  static String _host(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    final host = uri.host.toLowerCase();
    return host.startsWith('www.') ? host.substring(4) : host;
  }
}

/// 抓取 URL 安全校验：仅 http(s)、拒绝内网/本机/元数据地址。
String? validateFetchUrl(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || uri.host.isEmpty) return 'URL 无法解析';
  if (uri.scheme != 'http' && uri.scheme != 'https') return '仅允许 http/https';
  if (uri.userInfo.isNotEmpty) return 'URL 不允许包含用户信息';
  if (uri.port != 0 && !<int>{80, 443, 8080, 8443}.contains(uri.port)) {
    return '端口 ${uri.port} 不允许';
  }
  final host = uri.host.toLowerCase();
  if (host == 'localhost' ||
      host.endsWith('.localhost') ||
      host.endsWith('.local') ||
      host.endsWith('.internal') ||
      host == 'metadata.google.internal') {
    return '不允许访问内网地址';
  }
  if (host == '0.0.0.0' || host == '::1' || host == '[::1]') {
    return '不允许访问本机地址';
  }
  final ipv4 = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$')
      .firstMatch(host);
  if (ipv4 != null) {
    final parts = <int>[
      for (var i = 1; i <= 4; i++) int.tryParse(ipv4.group(i)!) ?? 0,
    ];
    if (parts.any((int part) => part > 255)) return 'IP 非法';
    final first = parts[0];
    final second = parts[1];
    if (first == 10 ||
        first == 127 ||
        first == 0 ||
        (first == 169 && second == 254) ||
        (first == 172 && second >= 16 && second <= 31) ||
        (first == 192 && second == 168) ||
        (first == 100 && second >= 64 && second <= 127)) {
      return '不允许访问内网地址';
    }
  }
  return null;
}
