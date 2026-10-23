import 'package:flutter/material.dart';

/// 圆角、间距、动效等与主题无关的标量（指南 §8.2）。
abstract final class MockRadius {
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
  static const double pill = 999;
}

abstract final class MockSpace {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 24;
  static const double s6 = 32;
  static const double s7 = 48;
  static const double s8 = 64;
}

abstract final class MockBlur {
  static const double light = 12;
  static const double regular = 24;
  static const double thick = 40;
}

abstract final class MockMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);
  static const Curve curve = Cubic(0.2, 0.8, 0.2, 1);
}

/// 玻璃三级降级（指南 §8.3）。
enum GlassQuality {
  /// 模糊 + （后续）折射着色器。
  full,

  /// 只有模糊，低端 Android / 省电模式。
  blurOnly,

  /// 半透明纯色，关闭透明度或帧率过低时。
  flat;

  static GlassQuality resolve({
    required bool reduceTransparency,
    required bool lowEndDevice,
  }) {
    if (reduceTransparency) return GlassQuality.flat;
    if (lowEndDevice) return GlassQuality.blurOnly;
    return GlassQuality.full;
  }
}

/// 设计 tokens 的运行时载体，按明暗主题取值。
@immutable
class MockTokens extends ThemeExtension<MockTokens> {
  const MockTokens({
    required this.brightness,
    required this.glassQuality,
    required this.tintTop,
    required this.tintBottom,
    required this.strokeTop,
    required this.strokeBottom,
    required this.specular,
    required this.ambientShadow,
    required this.floatShadow,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  final Brightness brightness;
  final GlassQuality glassQuality;

  /// 玻璃填充：白 8% / 黑 6%。
  final Color tintTop;
  final Color tintBottom;

  /// 描边：上亮下暗，α 18% → 6%。
  final Color strokeTop;
  final Color strokeBottom;

  /// 顶部 120° 高光，白 22% → 0。
  final Color specular;

  final List<BoxShadow> ambientShadow;
  final List<BoxShadow> floatShadow;

  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  double get blur {
    switch (glassQuality) {
      case GlassQuality.full:
        return MockBlur.regular;
      case GlassQuality.blurOnly:
        return MockBlur.light;
      case GlassQuality.flat:
        return 0;
    }
  }

  /// 同屏最多 3 个模糊层（性能红线）。
  static const int maxBlurLayers = 3;

  static MockTokens light({GlassQuality quality = GlassQuality.full}) =>
      _for(Brightness.light, quality);

  static MockTokens dark({GlassQuality quality = GlassQuality.full}) =>
      _for(Brightness.dark, quality);

  static MockTokens _for(Brightness brightness, GlassQuality quality) {
    final isDark = brightness == Brightness.dark;
    return MockTokens(
      brightness: brightness,
      glassQuality: quality,
      tintTop: (isDark ? Colors.black : Colors.white).withValues(
        alpha: isDark ? 0.06 : 0.08,
      ),
      tintBottom: (isDark ? Colors.black : Colors.white).withValues(
        alpha: isDark ? 0.03 : 0.04,
      ),
      strokeTop: Colors.white.withValues(alpha: isDark ? 0.18 : 0.5),
      strokeBottom: Colors.white.withValues(alpha: 0.06),
      specular: Colors.white.withValues(alpha: 0.22),
      ambientShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      floatShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ],
      success: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
      warning: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
      danger: isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
      info: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
    );
  }

  @override
  MockTokens copyWith({
    Brightness? brightness,
    GlassQuality? glassQuality,
    Color? tintTop,
    Color? tintBottom,
    Color? strokeTop,
    Color? strokeBottom,
    Color? specular,
    List<BoxShadow>? ambientShadow,
    List<BoxShadow>? floatShadow,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
  }) {
    return MockTokens(
      brightness: brightness ?? this.brightness,
      glassQuality: glassQuality ?? this.glassQuality,
      tintTop: tintTop ?? this.tintTop,
      tintBottom: tintBottom ?? this.tintBottom,
      strokeTop: strokeTop ?? this.strokeTop,
      strokeBottom: strokeBottom ?? this.strokeBottom,
      specular: specular ?? this.specular,
      ambientShadow: ambientShadow ?? this.ambientShadow,
      floatShadow: floatShadow ?? this.floatShadow,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
    );
  }

  @override
  MockTokens lerp(ThemeExtension<MockTokens>? other, double t) {
    if (other is! MockTokens) return this;
    return MockTokens(
      brightness: t < 0.5 ? brightness : other.brightness,
      glassQuality: t < 0.5 ? glassQuality : other.glassQuality,
      tintTop: Color.lerp(tintTop, other.tintTop, t)!,
      tintBottom: Color.lerp(tintBottom, other.tintBottom, t)!,
      strokeTop: Color.lerp(strokeTop, other.strokeTop, t)!,
      strokeBottom: Color.lerp(strokeBottom, other.strokeBottom, t)!,
      specular: Color.lerp(specular, other.specular, t)!,
      ambientShadow: BoxShadow.lerpList(ambientShadow, other.ambientShadow, t)!,
      floatShadow: BoxShadow.lerpList(floatShadow, other.floatShadow, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockTokens &&
          brightness == other.brightness &&
          glassQuality == other.glassQuality;

  @override
  int get hashCode => Object.hash(brightness, glassQuality);
}

extension MockTokensContext on BuildContext {
  MockTokens get tokens =>
      Theme.of(this).extension<MockTokens>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? MockTokens.dark()
          : MockTokens.light());
}
