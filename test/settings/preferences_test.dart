import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/settings/preferences.dart';

void main() {
  test('semanticSearch defaults off and round-trips', () {
    expect(const AppPreferences().semanticSearch, isFalse);
    const prefs = AppPreferences(
      themeMode: ThemeMode.dark,
      localeCode: 'zh',
      semanticSearch: true,
    );
    final decoded = AppPreferences.fromJson(jsonEncode(prefs.toJson()));
    expect(decoded.themeMode, ThemeMode.dark);
    expect(decoded.localeCode, 'zh');
    expect(decoded.semanticSearch, isTrue);
  });

  test('copyWith toggles semantic search without touching locale', () {
    const prefs = AppPreferences(localeCode: 'en');
    final next = prefs.copyWith(semanticSearch: true);
    expect(next.semanticSearch, isTrue);
    expect(next.localeCode, 'en');
  });
}
