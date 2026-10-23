import 'dart:convert';

/// provider 角色；模型名/端点全部可配置，不硬编码（指南 §5.4）。
enum ProviderRole { interviewer, scorer, embedding, tts, search }

/// 单个 provider 的非敏感配置。密钥本体在 SecureStore，按 [keyAlias] 取。
class ProviderConfig {
  const ProviderConfig({
    required this.role,
    required this.baseUrl,
    required this.model,
    this.temperature = 0.7,
    this.enabled = false,
  });

  final ProviderRole role;
  final String baseUrl;
  final String model;
  final double temperature;
  final bool enabled;

  String get keyAlias => 'mockmate.provider.${role.name}';

  bool get hasEndpoint => baseUrl.trim().isNotEmpty && model.trim().isNotEmpty;

  ProviderConfig copyWith({
    String? baseUrl,
    String? model,
    double? temperature,
    bool? enabled,
  }) {
    return ProviderConfig(
      role: role,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, Object?> get modelMap => <String, Object?>{
    'model': model,
    'temperature': temperature,
  };

  static ProviderConfig fromRow({
    required ProviderRole role,
    required String baseUrl,
    required String modelMapJson,
    required bool enabled,
  }) {
    var model = '';
    var temperature = 0.7;
    if (modelMapJson.isNotEmpty) {
      final decoded = jsonDecode(modelMapJson);
      if (decoded is Map<String, dynamic>) {
        model = decoded['model']?.toString() ?? '';
        final raw = decoded['temperature'];
        if (raw is num) temperature = raw.toDouble();
      }
    }
    return ProviderConfig(
      role: role,
      baseUrl: baseUrl,
      model: model,
      temperature: temperature,
      enabled: enabled,
    );
  }

  /// 默认值只作为表单初值，用户可改；不含任何密钥。
  static ProviderConfig defaults(ProviderRole role) {
    return switch (role) {
      ProviderRole.interviewer => const ProviderConfig(
        role: ProviderRole.interviewer,
        baseUrl: 'https://api.deepseek.com',
        model: 'deepseek-chat',
      ),
      ProviderRole.scorer => const ProviderConfig(
        role: ProviderRole.scorer,
        baseUrl: 'https://api.deepseek.com',
        model: 'deepseek-chat',
        temperature: 0.2,
      ),
      ProviderRole.embedding => const ProviderConfig(
        role: ProviderRole.embedding,
        baseUrl: '',
        model: 'bge-small-zh-v1.5-int8',
      ),
      ProviderRole.tts => const ProviderConfig(
        role: ProviderRole.tts,
        baseUrl: 'https://api.openai.com/v1',
        model: 'tts-1',
        temperature: 1,
      ),
      ProviderRole.search => const ProviderConfig(
        role: ProviderRole.search,
        baseUrl: 'https://api.tavily.com',
        model: 'tavily-search',
        temperature: 0,
      ),
    };
  }
}
