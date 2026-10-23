import 'dart:convert';

import 'prompt_source_base.dart';

/// prompt 变量缺失/多余时抛出，消息必须可直接定位到 id 与变量名。
class PromptVariableException implements Exception {
  const PromptVariableException(this.promptId, this.problems);

  final String promptId;
  final List<String> problems;

  @override
  String toString() =>
      'PromptVariableException($promptId): ${problems.join('; ')}';
}

/// 版本化 prompt：front-matter 元数据 + 正文 + `{{variable}}` 注入。
class PromptTemplate {
  const PromptTemplate({
    required this.id,
    required this.version,
    required this.model,
    required this.temperature,
    required this.variables,
    required this.body,
    required this.assetPath,
  });

  final String id;
  final int version;

  /// 默认模型；运行时可由 provider 配置覆盖。
  final String model;
  final double temperature;
  final List<String> variables;
  final String body;
  final String assetPath;

  static final RegExp _placeholder = RegExp(r'\{\{\s*([A-Za-z0-9_.]+)\s*\}\}');

  Set<String> get placeholders =>
      _placeholder.allMatches(body).map((RegExpMatch m) => m.group(1)!).toSet();

  static PromptTemplate parse(String source, {required String assetPath}) {
    final (:meta, :body) = splitFrontMatter(source);
    final id = meta['id'];
    if (id == null || id.trim().isEmpty) {
      throw FormatException('$assetPath: front-matter 缺少 id');
    }
    final version = int.tryParse(meta['version'] ?? '');
    if (version == null || version <= 0) {
      throw FormatException('$assetPath: version 必须是正整数');
    }
    final model = meta['model']?.trim();
    if (model == null || model.isEmpty) {
      throw FormatException('$assetPath: 缺少 model');
    }
    final temperature = double.tryParse(meta['temperature'] ?? '');
    if (temperature == null || temperature < 0 || temperature > 2) {
      throw FormatException('$assetPath: temperature 必须在 0–2 之间');
    }
    final variables = _parseList(meta['variables']);
    if (variables.isEmpty) {
      throw FormatException('$assetPath: variables 不能为空');
    }

    final template = PromptTemplate(
      id: id,
      version: version,
      model: model,
      temperature: temperature,
      variables: variables,
      body: body,
      assetPath: assetPath,
    );

    final placeholders = template.placeholders;
    final undeclared = placeholders.difference(variables.toSet());
    final unused = variables.toSet().difference(placeholders);
    final problems = <String>[
      if (undeclared.isNotEmpty) '正文未声明变量: ${undeclared.join(', ')}',
      if (unused.isNotEmpty) '声明但未使用: ${unused.join(', ')}',
    ];
    if (problems.isNotEmpty) {
      throw FormatException('$assetPath: ${problems.join('; ')}');
    }
    return template;
  }

  static List<String> _parseList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const <String>[];
    var value = raw.trim();
    if (value.startsWith('[') && value.endsWith(']')) {
      value = value.substring(1, value.length - 1);
    }
    return value
        .split(',')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  /// 注入变量。缺变量/多余变量都会报错，避免 prompt 静默带 `{{x}}` 发给模型。
  String render(Map<String, String> values) {
    final expected = variables.toSet();
    final provided = values.keys.toSet();
    final missing = expected.difference(provided);
    final extra = provided.difference(expected);
    if (missing.isNotEmpty || extra.isNotEmpty) {
      throw PromptVariableException(id, <String>[
        if (missing.isNotEmpty) '缺少变量: ${missing.join(', ')}',
        if (extra.isNotEmpty) '未知变量: ${extra.join(', ')}',
      ]);
    }
    return body.replaceAllMapped(_placeholder, (Match match) {
      final name = match.group(1)!;
      final value = values[name];
      if (value == null) {
        throw PromptVariableException(id, <String>['缺少变量: $name']);
      }
      return value;
    });
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'version': version,
    'model': model,
    'temperature': temperature,
    'variables': variables,
    'assetPath': assetPath,
  };

  @override
  String toString() => jsonEncode(toJson());
}

/// 启动时加载全部 prompt，校验 id 唯一。
class PromptRegistry {
  const PromptRegistry(this.byId);

  final Map<String, PromptTemplate> byId;

  static const String defaultDirectory = 'assets/prompts';

  static Future<PromptRegistry> load(
    PromptSource source, {
    String directory = defaultDirectory,
  }) async {
    final paths = await source.list(directory);
    if (paths.isEmpty) {
      throw StateError('没有找到 prompt: $directory');
    }
    final byId = <String, PromptTemplate>{};
    for (final path in paths) {
      final template = PromptTemplate.parse(
        await source.read(path),
        assetPath: path,
      );
      final existing = byId[template.id];
      if (existing != null) {
        final templateId = template.id;
        throw FormatException(
          'prompt id 重复: $templateId（${existing.assetPath} 与 $path）',
        );
      }
      byId[template.id] = template;
    }
    return PromptRegistry(Map<String, PromptTemplate>.unmodifiable(byId));
  }

  PromptTemplate require(String id) {
    final template = byId[id];
    if (template == null) {
      throw StateError('未注册的 prompt: $id（已注册: ${byId.keys.join(', ')}）');
    }
    return template;
  }

  Iterable<PromptTemplate> get all => byId.values;
}
