import 'dart:convert';

import 'package:flutter/material.dart';

/// 非敏感应用偏好，落在 `settings` 表（key = `app.preferences`）。
class AppPreferences {
  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.localeCode,
    this.semanticSearch = false,
  });

  final ThemeMode themeMode;

  /// null = 跟随系统；`zh` / `en`。
  final String? localeCode;

  /// 实验性本地向量检索；默认关，失败自动回退 FTS。
  final bool semanticSearch;

  AppPreferences copyWith({
    ThemeMode? themeMode,
    String? localeCode,
    bool? semanticSearch,
    bool clearLocale = false,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      localeCode: clearLocale ? null : (localeCode ?? this.localeCode),
      semanticSearch: semanticSearch ?? this.semanticSearch,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'themeMode': themeMode.name,
    'locale': localeCode,
    'semanticSearch': semanticSearch,
  };

  static AppPreferences fromJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const AppPreferences();
      final modeName = decoded['themeMode']?.toString() ?? 'system';
      final mode = ThemeMode.values.firstWhere(
        (ThemeMode value) => value.name == modeName,
        orElse: () => ThemeMode.system,
      );
      final locale = decoded['locale']?.toString();
      return AppPreferences(
        themeMode: mode,
        localeCode: (locale == null || locale.isEmpty) ? null : locale,
        semanticSearch: decoded['semanticSearch'] == true,
      );
    } on FormatException {
      return const AppPreferences();
    }
  }
}
