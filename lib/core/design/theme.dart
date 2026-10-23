import 'package:flutter/material.dart';

import 'tokens.dart';

/// 应用主题：Material 3 + 项目 tokens。
///
/// 三端共用同一套 tokens，仅导航与窗口行为按平台适配（指南 §8.1）。
ThemeData buildMockTheme(
  Brightness brightness, {
  GlassQuality glassQuality = GlassQuality.full,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2F6F6B),
    brightness: brightness,
  );
  final tokens = brightness == Brightness.dark
      ? MockTokens.dark(quality: glassQuality)
      : MockTokens.light(quality: glassQuality);
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    visualDensity: VisualDensity.standard,
  );
  return base.copyWith(
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF0E1114)
        : const Color(0xFFF3F5F7),
    textTheme: base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    cardTheme: const CardThemeData(elevation: 0),
    appBarTheme: AppBarTheme(
      // 透明 AppBar 在 shell 的透明 Scaffold 后是黑色窗口，浅色模式下会看不见
      // 返回/操作按钮；使用 surface 保证对比度。
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: scheme.onSurface),
      actionsIconTheme: IconThemeData(color: scheme.onSurface),
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        color: scheme.onSurface,
      ),
      centerTitle: false,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.secondaryContainer,
      selectedIconTheme: IconThemeData(color: scheme.onSecondaryContainer),
      unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      selectedLabelTextStyle: TextStyle(color: scheme.onSurface),
      unselectedLabelTextStyle: TextStyle(color: scheme.onSurfaceVariant),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.secondaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.onSecondaryContainer
              : scheme.onSurfaceVariant,
        );
      }),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.5),
      thickness: 1,
      space: MockSpace.s5,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MockRadius.md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MockRadius.md),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: MockSpace.s4,
        vertical: MockSpace.s3,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MockRadius.md),
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[tokens],
  );
}

/// 背景：低饱和渐变 + 两个色斑，为玻璃提供可感知的层次。
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const <Color>[
                  Color(0xFF0E1114),
                  Color(0xFF141C22),
                  Color(0xFF0E1114),
                ]
              : const <Color>[
                  Color(0xFFF7F9FB),
                  Color(0xFFE9F0F2),
                  Color(0xFFF4F6F8),
                ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -120,
            right: -80,
            child: _Blob(
              color: scheme.primary.withValues(alpha: isDark ? 0.10 : 0.16),
              size: 320,
            ),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: _Blob(
              color: scheme.tertiary.withValues(alpha: isDark ? 0.08 : 0.12),
              size: 360,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
