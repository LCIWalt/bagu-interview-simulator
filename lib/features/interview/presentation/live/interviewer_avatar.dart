import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design/tokens.dart';

enum InterviewerAvatarState { idle, listening, thinking, speaking }

/// 小深表情状态机（T-064）。Rive 资产缺失时的过渡实现：CustomPainter。
class InterviewerAvatar extends StatefulWidget {
  const InterviewerAvatar({
    super.key,
    required this.state,
    this.size = 40,
    this.semanticLabel = '小深',
  });

  final InterviewerAvatarState state;
  final double size;
  final String semanticLabel;

  @override
  State<InterviewerAvatar> createState() => _InterviewerAvatarState();
}

class _InterviewerAvatarState extends State<InterviewerAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    return Semantics(
      label: widget.semanticLabel,
      image: true,
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) => CustomPaint(
            painter: _AvatarPainter(
              state: widget.state,
              progress: _controller.value,
              primary: theme.colorScheme.primary,
              surface: theme.colorScheme.surface,
              accent: tokens.success,
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter({
    required this.state,
    required this.progress,
    required this.primary,
    required this.surface,
    required this.accent,
  });

  final InterviewerAvatarState state;
  final double progress;
  final Color primary;
  final Color surface;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final wave = math.sin(progress * math.pi * 2);

    // 呼吸光晕
    canvas.drawCircle(
      center,
      radius * (0.94 + 0.03 * wave),
      Paint()..color = primary.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      center,
      radius * 0.82,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            primary.withValues(alpha: 0.95),
            primary.withValues(alpha: 0.65),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // 天线
    final antennaPaint = Paint()
      ..color = surface.withValues(alpha: 0.9)
      ..strokeWidth = size.shortestSide * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.78),
      Offset(center.dx, center.dy - radius * 0.98),
      antennaPaint,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 1.0),
      radius * 0.06,
      Paint()..color = accent,
    );

    // 脸
    final faceRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: radius * 1.18,
        height: radius * 1.02,
      ),
      Radius.circular(radius * 0.38),
    );
    canvas.drawRRect(
      faceRect,
      Paint()..color = surface.withValues(alpha: 0.94),
    );

    // 眼睛
    final eyeY = center.dy - radius * 0.1;
    final eyeOffset = radius * 0.28;
    final blink = state == InterviewerAvatarState.idle && progress > 0.92
        ? 0.15
        : 1.0;
    final eyeHeight = radius * 0.16 * blink;
    final listening = state == InterviewerAvatarState.listening;
    final eyeWidth = radius * (listening ? 0.14 : 0.11);
    for (final dx in <double>[-eyeOffset, eyeOffset]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + dx, eyeY),
          width: eyeWidth,
          height: listening ? eyeHeight * 1.25 : eyeHeight,
        ),
        Paint()..color = primary,
      );
      if (state == InterviewerAvatarState.thinking) {
        canvas.drawCircle(
          Offset(center.dx + dx, eyeY - radius * 0.14),
          radius * 0.025,
          Paint()..color = surface.withValues(alpha: 0.8),
        );
      }
    }

    // 嘴/状态
    final mouthY = center.dy + radius * 0.26;
    if (state == InterviewerAvatarState.speaking) {
      final openness = 0.10 + 0.10 * (0.5 + 0.5 * wave);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, mouthY),
          width: radius * 0.34,
          height: radius * openness * 2,
        ),
        Paint()..color = primary,
      );
    } else if (state == InterviewerAvatarState.thinking) {
      for (var i = 0; i < 3; i++) {
        final phase = (progress + i * 0.2) % 1;
        canvas.drawCircle(
          Offset(center.dx + (i - 1) * radius * 0.18, mouthY),
          radius * 0.045,
          Paint()..color = primary.withValues(alpha: 0.25 + 0.6 * phase),
        );
      }
    } else {
      final smile = state == InterviewerAvatarState.listening ? 0.6 : 0.35;
      final path = Path()
        ..moveTo(center.dx - radius * 0.16, mouthY)
        ..quadraticBezierTo(
          center.dx,
          mouthY + radius * smile * 0.25,
          center.dx + radius * 0.16,
          mouthY,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * 0.045
          ..strokeCap = StrokeCap.round,
      );
    }

    // 思考气泡
    if (state == InterviewerAvatarState.thinking) {
      for (var i = 0; i < 3; i++) {
        final alpha = 0.15 + 0.55 * ((progress + i * 0.25) % 1);
        canvas.drawCircle(
          Offset(
            center.dx + radius * (0.72 + i * 0.16),
            center.dy - radius * (0.65 + i * 0.12),
          ),
          radius * (0.05 + i * 0.012),
          Paint()..color = surface.withValues(alpha: alpha),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_AvatarPainter oldDelegate) =>
      oldDelegate.state != state ||
      oldDelegate.progress != progress ||
      oldDelegate.primary != primary ||
      oldDelegate.surface != surface;
}
