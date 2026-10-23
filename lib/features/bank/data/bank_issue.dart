import 'package:yaml/yaml.dart';

/// 题库解析/校验问题：带文件、行列与字段路径，便于直接定位。
class BankIssue {
  const BankIssue({
    required this.file,
    required this.message,
    this.line = 0,
    this.column = 0,
    this.field = '',
  });

  final String file;
  final String message;

  /// 0-based，与 YAML source span 一致；展示时 +1。
  final int line;
  final int column;
  final String field;

  String format() {
    final location = line > 0 || column > 0 ? '${line + 1}:${column + 1}' : '?';
    final fieldSuffix = field.isEmpty ? '' : ' [$field]';
    return '$file:$location$fieldSuffix $message';
  }

  @override
  String toString() => format();
}

BankIssue issueAt(String file, String field, String message, YamlNode? node) {
  final start = node?.span.start;
  return BankIssue(
    file: file,
    message: message,
    field: field,
    line: start?.line ?? 0,
    column: start?.column ?? 0,
  );
}

/// 读取 YAML 节点的字段字符串；类型不符时记录问题。
String? readString(
  YamlMap map,
  String key,
  String file,
  String path,
  List<BankIssue> issues, {
  bool required = true,
}) {
  final node = map.nodes[key];
  if (node == null) {
    if (required) {
      issues.add(issueAt(file, path, '缺少必填字段', map));
    }
    return null;
  }
  if (node.value is! String) {
    issues.add(issueAt(file, path, '必须是字符串', node));
    return null;
  }
  final value = (node.value as String).trim();
  if (value.isEmpty && required) {
    issues.add(issueAt(file, path, '不能为空', node));
    return null;
  }
  return value;
}

int? readInt(
  YamlMap map,
  String key,
  String file,
  String path,
  List<BankIssue> issues, {
  required int min,
  required int max,
}) {
  final node = map.nodes[key];
  if (node == null) {
    issues.add(issueAt(file, path, '缺少必填字段', map));
    return null;
  }
  final value = node.value;
  final parsed = value is int ? value : int.tryParse('$value');
  if (parsed == null) {
    issues.add(issueAt(file, path, '必须是整数', node));
    return null;
  }
  if (parsed < min || parsed > max) {
    issues.add(issueAt(file, path, '必须在 $min–$max 之间', node));
    return null;
  }
  return parsed;
}

List<String>? readStringList(
  YamlMap map,
  String key,
  String file,
  String path,
  List<BankIssue> issues, {
  bool required = false,
  int minLength = 0,
}) {
  final node = map.nodes[key];
  if (node == null) {
    if (required) {
      issues.add(issueAt(file, path, '缺少必填字段', map));
    }
    return null;
  }
  final value = node.value;
  if (value is! List) {
    issues.add(issueAt(file, path, '必须是数组', node));
    return null;
  }
  final result = <String>[];
  for (var i = 0; i < value.length; i++) {
    final item = value[i];
    if (item is! String || item.trim().isEmpty) {
      issues.add(issueAt(file, '$path[$i]', '必须是非空字符串', node));
      continue;
    }
    result.add(item.trim());
  }
  if (result.length < minLength) {
    issues.add(issueAt(file, path, '至少需要 $minLength 项', node));
  }
  final duplicates = <String>{};
  for (final item in result) {
    if (!duplicates.add(item)) {
      issues.add(issueAt(file, path, '存在重复项：$item', node));
    }
  }
  return result;
}

/// `source` 节点：必须给出来源 URL 与许可证（T-011 合规要求）。
Map<String, Object?>? readSource(
  YamlMap map,
  String file,
  List<BankIssue> issues,
) {
  final node = map.nodes['source'];
  if (node == null) {
    issues.add(issueAt(file, 'source', '缺少来源信息（url/title/license）', map));
    return null;
  }
  if (node.value is! YamlMap) {
    issues.add(issueAt(file, 'source', '必须是对象', node));
    return null;
  }
  final source = node.value as YamlMap;
  final url = readString(source, 'url', file, 'source.url', issues);
  final title = readString(source, 'title', file, 'source.title', issues);
  final license = readString(source, 'license', file, 'source.license', issues);
  if (url != null) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isScheme('http') && !uri.isScheme('https')) {
      issues.add(
        issueAt(file, 'source.url', '必须是 http(s) URL', source.nodes['url']),
      );
    }
  }
  final retrievedAt = source.nodes['retrievedAt'];
  DateTime? parsedDate;
  if (retrievedAt != null) {
    parsedDate = DateTime.tryParse('${retrievedAt.value}');
    if (parsedDate == null) {
      issues.add(
        issueAt(file, 'source.retrievedAt', '必须是 ISO 日期', retrievedAt),
      );
    }
  }
  if (url == null ||
      title == null ||
      license == null ||
      parsedDate == null && retrievedAt != null) {
    return null;
  }
  return <String, Object?>{
    'url': url,
    'title': title,
    'license': license,
    'retrievedAt': ?parsedDate,
  };
}

/// 解析单个 YAML 文本为问题 + 问题列表；不抛异常，便于批量收集。
({YamlMap? map, List<BankIssue> issues}) parseYamlDocument(
  String content,
  String file,
) {
  final issues = <BankIssue>[];
  final Object? node;
  try {
    node = loadYamlNode(content, sourceUrl: Uri.file(file));
  } on YamlException catch (error) {
    issues.add(
      BankIssue(
        file: file,
        message: 'YAML 语法错误：${error.message}',
        line: error.span?.start.line ?? 0,
        column: error.span?.start.column ?? 0,
      ),
    );
    return (map: null, issues: issues);
  }
  if (node is! YamlMap) {
    issues.add(BankIssue(file: file, message: '根节点必须是对象'));
    return (map: null, issues: issues);
  }
  return (map: node, issues: issues);
}
