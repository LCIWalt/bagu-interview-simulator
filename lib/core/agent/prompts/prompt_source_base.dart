import 'dart:convert';

/// prompt 文本来源抽象。放在 agent 层之外注入，保证 `core/agent` 不依赖 Flutter。
abstract interface class PromptSource {
  Future<String> read(String assetPath);

  Future<List<String>> list(String directory);
}

/// 内存源，测试与脚本使用。
class InMemoryPromptSource implements PromptSource {
  InMemoryPromptSource(Map<String, String> files)
    : _files = Map<String, String>.of(files);

  final Map<String, String> _files;

  @override
  Future<String> read(String assetPath) async {
    final content = _files[assetPath];
    if (content == null) {
      throw StateError('prompt not found: $assetPath');
    }
    return content;
  }

  @override
  Future<List<String>> list(String directory) async {
    final prefix = directory.endsWith('/') ? directory : '$directory/';
    return _files.keys.where((String path) => path.startsWith(prefix)).toList()
      ..sort();
  }
}

/// 解析 front-matter 的轻量工具（YAML 交给调用方解析）。
({Map<String, String> meta, String body}) splitFrontMatter(String source) {
  final normalized = source.replaceAll('\r\n', '\n');
  if (!normalized.startsWith('---\n')) {
    return (meta: const <String, String>{}, body: normalized);
  }
  final end = normalized.indexOf('\n---', 4);
  if (end < 0) {
    throw const FormatException('front-matter 未闭合（缺少结尾 ---）');
  }
  final header = normalized.substring(4, end);
  final rest = normalized.substring(end + 4);
  return (
    meta: parseSimpleYaml(header),
    body: rest.startsWith('\n') ? rest.substring(1) : rest,
  );
}

/// 只支持一层 key: value（prompt front-matter 的既定格式）。
Map<String, String> parseSimpleYaml(String yamlText) {
  final result = <String, String>{};
  for (final rawLine in const LineSplitter().convert(yamlText)) {
    final line = rawLine.trimRight();
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
    final separator = line.indexOf(':');
    if (separator <= 0) {
      throw FormatException('无法解析 front-matter 行: $line');
    }
    final key = line.substring(0, separator).trim();
    var value = line.substring(separator + 1).trim();
    if ((value.startsWith('[') && value.endsWith(']')) ||
        (value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.substring(1, value.length - 1);
    }
    result[key] = value;
  }
  return result;
}
