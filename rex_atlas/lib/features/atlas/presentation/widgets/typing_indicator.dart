import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

/// iMessage-style typing dots: a soft wave bouncing through three dots, with
/// an optional status label ("Processing your transfer…").
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key, this.label});
  final String? label;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label ?? 'Rex Atlas is typing',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 18,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  // Each dot rises and brightens in turn.
                  final phase = (_c.value - i * 0.16) % 1.0;
                  final wave = phase < 0.5
                      ? math.sin(phase * 2 * math.pi)
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(0, -4 * wave.clamp(0.0, 1.0)),
                    child: Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: RexColors.navy.withValues(
                          alpha: 0.35 + 0.45 * wave.clamp(0.0, 1.0),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          if (widget.label != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.label!,
                style: RexTypography.bubble.copyWith(
                  color: RexColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
