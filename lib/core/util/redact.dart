/// 日志/分享前的脱敏（AGENTS.md §4：日志必须过 redact()）。
library;

final RegExp _apiKey = RegExp(r'\bsk-[A-Za-z0-9_\-]{6,}\b');
final RegExp _bearer = RegExp(
  r'\bbearer\s+[A-Za-z0-9._\-]+',
  caseSensitive: false,
);
final RegExp _keyValue = RegExp(
  r'''\b(api[_-]?key|access[_-]?token|secret|authorization)\b\s*[:=]\s*["']?(?!Bearer\b|\*\*\*)([^\s"',}]{4,})["']?''',
  caseSensitive: false,
);
final RegExp _email = RegExp(
  r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}',
);
final RegExp _cnPhone = RegExp(r'(?<!\d)(1[3-9]\d{9})(?!\d)');
final RegExp _internalHost = RegExp(
  r'\b([a-z0-9\-]+\.)+(internal|corp|local|lan|intra)\b',
  caseSensitive: false,
);

/// 返回脱敏后的文本；不修改原文，便于日志与报告复用。
String redact(String input, {int maxLength = 4000}) {
  var output = input
      .replaceAllMapped(_apiKey, (_) => 'sk-***')
      .replaceAllMapped(_bearer, (_) => 'Bearer ***')
      .replaceAllMapped(_keyValue, (Match m) => '${m.group(1)}=***')
      .replaceAllMapped(_email, (Match m) {
        final at = m.group(0)!.indexOf('@');
        return '${m.group(0)!.substring(0, 1)}***${m.group(0)!.substring(at)}';
      })
      .replaceAllMapped(
        _cnPhone,
        (Match m) =>
            '${m.group(1)!.substring(0, 3)}****${m.group(1)!.substring(7)}',
      )
      .replaceAllMapped(_internalHost, (_) => '***.internal');
  if (output.length > maxLength) {
    output = '${output.substring(0, maxLength)}…[truncated]';
  }
  return output;
}
