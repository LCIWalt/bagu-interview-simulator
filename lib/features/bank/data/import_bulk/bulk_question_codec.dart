import 'dart:convert';

/// 把字段 Map 转成题库 YAML，复用 BankQuestionParser 的完整校验。
String questionMapToYaml(Map<String, Object?> map) {
  final buffer = StringBuffer();
  for (final entry in map.entries) {
    final value = entry.value;
    if (value == null) continue;
    if (value is Map) {
      buffer.writeln('${entry.key}:');
      _writeMap(buffer, value, 2);
    } else if (value is List) {
      if (value.isEmpty) {
        buffer.writeln('${entry.key}: []');
        continue;
      }
      buffer.writeln('${entry.key}:');
      for (final item in value) {
        if (item is Map) {
          buffer.writeln('  -');
          _writeMap(buffer, item, 4);
        } else {
          buffer.writeln('  - ${_scalar(item)}');
        }
      }
    } else {
      buffer.writeln('${entry.key}: ${_scalar(value)}');
    }
  }
  return buffer.toString();
}

void _writeMap(StringBuffer buffer, Map<dynamic, dynamic> map, int indent) {
  final spaces = ' ' * indent;
  for (final entry in map.entries) {
    final value = entry.value;
    if (value is Map) {
      buffer.writeln('$spaces${entry.key}:');
      _writeMap(buffer, value, indent + 2);
    } else if (value is List) {
      if (value.isEmpty) {
        buffer.writeln('$spaces${entry.key}: []');
        continue;
      }
      buffer.writeln('$spaces${entry.key}:');
      for (final item in value) {
        buffer.writeln('$spaces  - ${_scalar(item)}');
      }
    } else if (value != null) {
      buffer.writeln('$spaces${entry.key}: ${_scalar(value)}');
    }
  }
}

String _scalar(Object? value) {
  if (value is num || value is bool) return '$value';
  return jsonEncode('$value');
}

/// 极简 CSV 解析：支持双引号、转义双引号与字段内换行。
List<List<String>> parseCsv(String content) {
  final rows = <List<String>>[];
  final field = StringBuffer();
  var row = <String>[];
  var quoted = false;
  for (var i = 0; i < content.length; i++) {
    final char = content[i];
    if (quoted) {
      if (char == '"') {
        if (i + 1 < content.length && content[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        field.write(char);
      }
      continue;
    }
    if (char == '"') {
      quoted = true;
    } else if (char == ',') {
      row.add(field.toString());
      field.clear();
    } else if (char == '\n') {
      row.add(field.toString());
      field.clear();
      rows.add(row);
      row = <String>[];
    } else if (char != '\r') {
      field.write(char);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    rows.add(row);
  }
  return rows;
}

/// Markdown：`## 标题` 分块，块内为 YAML 键值；id 缺省时按标题生成。
List<Map<String, Object?>> parseMarkdownQuestions(String content) {
  final blocks = <Map<String, Object?>>[];
  final lines = content.replaceAll('\r\n', '\n').split('\n');
  var current = <String>[];
  String? title;

  void flush() {
    if (current.isEmpty && title == null) return;
    final yaml = current.join('\n');
    final meta = _simpleYaml(yaml);
    meta['title'] = title ?? meta['title'] ?? '';
    meta['id'] ??= 'md-${_hash('$title|$yaml').substring(0, 10)}';
    blocks.add(meta);
    current = <String>[];
    title = null;
  }

  for (final line in lines) {
    if (line.startsWith('## ')) {
      flush();
      title = line.substring(3).trim();
    } else if (line.trim() == '---' && title == null) {
      continue;
    } else if (title != null || current.isNotEmpty) {
      current.add(line);
    }
  }
  flush();
  return blocks;
}

Map<String, Object?> _simpleYaml(String yaml) {
  final map = <String, Object?>{};
  String? listKey;
  final list = <String>[];
  void flushList() {
    if (listKey != null) {
      map[listKey!] = List<String>.of(list);
      listKey = null;
      list.clear();
    }
  }

  for (final raw in yaml.split('\n')) {
    final line = raw.trimRight();
    if (line.trim().isEmpty) continue;
    if (line.startsWith('  - ') || line.startsWith('- ')) {
      final value = line.replaceFirst(RegExp(r'^\s*-\s*'), '').trim();
      list.add(_unquote(value));
      continue;
    }
    flushList();
    final index = line.indexOf(':');
    if (index <= 0) continue;
    final key = line.substring(0, index).trim();
    final value = line.substring(index + 1).trim();
    if (value.isEmpty) {
      listKey = key;
    } else {
      map[key] = _unquote(value);
    }
  }
  flushList();
  return map;
}

String _unquote(String value) {
  if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
    try {
      return jsonDecode(value) as String;
    } on FormatException {
      return value.substring(1, value.length - 1);
    }
  }
  if (value.length >= 2 && value.startsWith("'") && value.endsWith("'")) {
    return value.substring(1, value.length - 1);
  }
  if (value.startsWith('[') && value.endsWith(']')) {
    return value;
  }
  return value;
}

String _hash(String value) {
  var hash = 0xcbf29ce484222325;
  for (final code in value.codeUnits) {
    hash ^= code;
    hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}
