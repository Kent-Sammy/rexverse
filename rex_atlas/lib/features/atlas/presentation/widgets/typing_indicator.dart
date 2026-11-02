import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

/// Three pulsing dots (+ optional status label) inside an assistant bubble.
/// Not drawn in Figma; kept minimal so the user can see Atlas is working.
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
    duration: const Duration(milliseconds: 900),
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
          AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final t = ((_c.value - i * 0.2) % 1.0);
                final o = 0.35 + 0.65 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: RexColors.navy.withValues(alpha: o),
                    shape: BoxShape.circle,
                  ),
                );
              }),
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
