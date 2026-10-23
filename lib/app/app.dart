import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/theme.dart';
import '../core/design/tokens.dart';
import '../l10n/generated/app_localizations.dart';
import 'providers.dart';
import 'router.dart';

class MockMateApp extends ConsumerWidget {
  const MockMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider).valueOrNull;
    final localeCode = prefs?.localeCode;
    // 移动端先用 blur-only，低端机再降到 flat；桌面端完整玻璃。
    final quality = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? GlassQuality.blurOnly
        : GlassQuality.full;

    return MaterialApp.router(
      routerConfig: appRouter,
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: prefs?.themeMode ?? ThemeMode.system,
      theme: buildMockTheme(Brightness.light, glassQuality: quality),
      darkTheme: buildMockTheme(Brightness.dark, glassQuality: quality),
      locale: localeCode == null ? null : Locale(localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
