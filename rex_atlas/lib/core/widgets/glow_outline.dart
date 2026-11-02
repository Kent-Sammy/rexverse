import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design_system/rex_colors.dart';

/// Animated gradient outline with a soft outer glow, used to draw attention
/// to the home "Ask RexAtlas" bar. The gradient rotates and the glow
/// breathes; both hold still when the OS asks for reduced motion.
class GlowOutline extends StatefulWidget {
  const GlowOutline({
    super.key,
    required this.child,
    this.radius = 20,
    this.strokeWidth = 1.6,
    this.colors = const [
      RexColors.ringCyan,
      RexColors.ringPurple,
      RexColors.primary,
      RexColors.ringCyan,
    ],
  });

  final Widget child;
  final double radius;
  final double strokeWidth;
  final List<Color> colors;

  @override
  State<GlowOutline> createState() => _GlowOutlineState();
}

class _GlowOutlineState extends State<GlowOutline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GlowPainter(_c, widget.radius, widget.colors, glow: true),
      foregroundPainter: _GlowPainter(
        _c,
        widget.radius,
        widget.colors,
        strokeWidth: widget.strokeWidth,
      ),
      child: widget.child,
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter(
    this.t,
    this.radius,
    this.colors, {
    this.glow = false,
    this.strokeWidth = 1.6,
  }) : super(repaint: t);

  final Animation<double> t;
  final double radius;
  final List<Color> colors;
  final bool glow;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final a = t.value * 2 * math.pi;
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    final shader = SweepGradient(
      colors: colors,
      transform: GradientRotation(a),
    ).createShader(rect);
    if (glow) {
      final breathe = 0.5 + 0.5 * math.sin(a * 2);
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 + 4 * breathe)
          ..color = Colors.white.withValues(alpha: 0.45 + 0.4 * breathe),
      );
    } else {
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  @override
  bool shouldRepaint(_GlowPainter old) => false;
}
