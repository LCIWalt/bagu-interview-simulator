import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'tokens.dart';

/// 玻璃容器：模糊 + 渐变填充 + 上亮下暗描边 + 顶部高光。
///
/// 性能约定：同屏模糊层 ≤3；列表项外层请加 [RepaintBoundary]。
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(MockSpace.s4),
    this.radius = MockRadius.lg,
    this.blur = MockBlur.regular,
    this.quality,
    this.elevated = false,
    this.tint,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;

  /// 覆盖全局降级等级（demo 页/单独组件用）。
  final GlassQuality? quality;
  final bool elevated;
  final Color? tint;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final effective = quality ?? tokens.glassQuality;
    final shape = BorderRadius.circular(radius);

    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[tint ?? tokens.tintTop, tokens.tintBottom],
        ),
        border: Border.all(color: tokens.strokeBottom),
        boxShadow: elevated ? tokens.floatShadow : tokens.ambientShadow,
      ),
      child: Stack(
        children: <Widget>[
          // 顶部 120° 高光。
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: shape,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: const Alignment(0, -0.2),
                      colors: <Color>[
                        tokens.specular,
                        tokens.specular.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );

    if (effective != GlassQuality.flat) {
      content = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: effective == GlassQuality.blurOnly ? MockBlur.light : blur,
          sigmaY: effective == GlassQuality.blurOnly ? MockBlur.light : blur,
        ),
        child: content,
      );
    }

    content = ClipRRect(borderRadius: shape, child: content);
    if (onTap != null) {
      content = Semantics(
        button: true,
        label: semanticLabel,
        child: Material(
          color: Colors.transparent,
          child: InkWell(borderRadius: shape, onTap: onTap, child: content),
        ),
      );
    }
    return content;
  }
}

/// 玻璃按钮：44×44 最小点击区，主/次两种强调。
class GlassButton extends StatefulWidget {
  const GlassButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.primary = true,
    this.busy = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final bool busy;
  final bool expand;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;
  bool _activating = false;
  DateTime? _pressedAt;
  Timer? _releaseTimer;

  static const Duration _minPress = Duration(milliseconds: 90);

  @override
  void dispose() {
    _releaseTimer?.cancel();
    super.dispose();
  }

  void _activate() {
    if (widget.onPressed == null || widget.busy || _activating) return;
    _activating = true;
    Timer(const Duration(milliseconds: 70), () {
      _activating = false;
      if (mounted) widget.onPressed?.call();
    });
  }

  void _highlight(bool pressed) {
    _releaseTimer?.cancel();
    if (pressed) {
      _pressedAt = DateTime.now();
      setState(() => _pressed = true);
      return;
    }
    final held = _pressedAt == null
        ? _minPress
        : DateTime.now().difference(_pressedAt!);
    final remaining = _minPress - held;
    if (remaining <= Duration.zero) {
      setState(() => _pressed = false);
      return;
    }
    _releaseTimer = Timer(remaining, () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final enabled = widget.onPressed != null && !widget.busy;
    final foreground = widget.primary
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    final child = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.busy)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        else if (widget.icon != null)
          Icon(widget.icon, size: 18, color: foreground),
        if (widget.busy || widget.icon != null)
          const SizedBox(width: MockSpace.s2),
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(color: foreground),
          ),
        ),
      ],
    );

    final button = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: widget.primary
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(MockRadius.pill),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MockSpace.s5,
                    vertical: MockSpace.s3,
                  ),
                  child: child,
                ),
              )
            : GlassPanel(
                radius: MockRadius.pill,
                padding: const EdgeInsets.symmetric(
                  horizontal: MockSpace.s5,
                  vertical: MockSpace.s3,
                ),
                tint: tokens.tintTop,
                child: child,
              ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(MockRadius.pill),
          onTap: enabled ? _activate : null,
          onHighlightChanged: enabled ? _highlight : null,
          child: AnimatedScale(
            scale: _pressed ? 0.94 : 1,
            duration: Duration(milliseconds: _pressed ? 60 : 120),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: _pressed ? 0.85 : 1,
              duration: Duration(milliseconds: _pressed ? 60 : 120),
              child: button,
            ),
          ),
        ),
      ),
    );
  }
}

/// 玻璃底部弹层；内容区保持纯色高对比。
class GlassSheet extends StatelessWidget {
  const GlassSheet({
    required this.title,
    required this.child,
    super.key,
    this.actions = const <Widget>[],
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    List<Widget> actions = const <Widget>[],
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) =>
          GlassSheet(title: title, actions: actions, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(MockSpace.s3),
        child: GlassPanel(
          elevated: true,
          padding: const EdgeInsets.fromLTRB(
            MockSpace.s4,
            MockSpace.s3,
            MockSpace.s4,
            MockSpace.s4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(MockRadius.pill),
                  ),
                ),
              ),
              const SizedBox(height: MockSpace.s4),
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: MockSpace.s3),
              Flexible(child: SingleChildScrollView(child: child)),
              if (actions.isNotEmpty) ...<Widget>[
                const SizedBox(height: MockSpace.s4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
