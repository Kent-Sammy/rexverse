import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Animated version of the Figma success badge (layer
/// "lottiefiles.com/95088-success"): the halo blooms, the teal disc pops,
/// the tick draws itself and confetti bursts out, then it rests on the same
/// final frame as the static export. Plays once; shows the final frame
/// straight away when the OS asks for reduced motion.
class SuccessBadge extends StatefulWidget {
  const SuccessBadge({super.key, this.size = 64});

  /// Width of the badge (the export was 189 × 180 for 62.8 pt).
  final double size;

  @override
  State<SuccessBadge> createState() => _SuccessBadgeState();
}

class _SuccessBadgeState extends State<SuccessBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _c.value = 1;
    } else if (_c.status == AnimationStatus.dismissed) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return ExcludeSemantics(
      child: SizedBox(
        width: s,
        height: s * 180 / 189,
        child: CustomPaint(painter: _BadgePainter(_c)),
      ),
    );
  }
}

class _BadgePainter extends CustomPainter {
  _BadgePainter(this.t) : super(repaint: t);
  final Animation<double> t;

  static const _teal = Color(0xFF00DAB9);
  static const _confetti = [
    Color(0xFFF87171),
    Color(0xFF60A5FA),
    Color(0xFFFBBF24),
    Color(0xFF34D399),
    Color(0xFFA78BFA),
    Color(0xFF2DD4BF),
  ];

  double _seg(double v, double a, double b, [Curve c = Curves.linear]) =>
      c.transform(((v - a) / (b - a)).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final v = t.value;
    final w = size.width;
    final center = size.center(Offset.zero);
    final inner = w * 0.25;
    final halo = w * 0.35;

    // 1. Halo blooms (20% teal, as in the export).
    final h = _seg(v, 0, 0.4, Curves.easeOutBack);
    if (h > 0) {
      canvas.drawCircle(
        center,
        halo * h,
        Paint()..color = _teal.withValues(alpha: 0.2),
      );
    }

    // 2. Disc pops.
    final d = _seg(v, 0.1, 0.55, Curves.elasticOut);
    if (d > 0) {
      canvas.drawCircle(center, inner * d, Paint()..color = _teal);
    }

    // 3. Tick draws itself.
    final k = _seg(v, 0.4, 0.75, Curves.easeOutCubic);
    if (k > 0) {
      final path = Path()
        ..moveTo(center.dx - inner * 0.42, center.dy + inner * 0.02)
        ..lineTo(center.dx - inner * 0.1, center.dy + inner * 0.33)
        ..lineTo(center.dx + inner * 0.45, center.dy - inner * 0.3);
      final drawn = Path();
      for (final m in path.computeMetrics()) {
        drawn.addPath(m.extractPath(0, m.length * k), Offset.zero);
      }
      canvas.drawPath(
        drawn,
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.055
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // 4. Confetti bursts out and settles around the halo.
    final c = _seg(v, 0.35, 1, Curves.easeOutCubic);
    if (c > 0) {
      const n = 12;
      for (var i = 0; i < n; i++) {
        final angle =
            -math.pi / 2 + i * 2 * math.pi / n + (i.isEven ? 0.12 : -0.1);
        final dist = inner + (halo * 1.12 - inner) * c + (i % 3) * w * 0.012;
        final p = center + Offset(math.cos(angle), math.sin(angle)) * dist;
        final paint = Paint()
          ..color = _confetti[i % _confetti.length].withValues(
            alpha: 0.95 * math.min(1, c * 2),
          );
        if (i % 3 == 0) {
          canvas.drawCircle(p, w * 0.018, paint);
        } else {
          canvas.save();
          canvas.translate(p.dx, p.dy);
          canvas.rotate(angle + c * 2);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: w * 0.05,
                height: w * 0.018,
              ),
              Radius.circular(w * 0.01),
            ),
            paint,
          );
          canvas.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(_BadgePainter old) => false;
}
