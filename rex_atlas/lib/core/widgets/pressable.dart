import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Tap target with a soft press state (slight scale-down + dim) and a light
/// selection haptic. Used instead of Material ink so the Figma surfaces render
/// without ripples.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
    this.enabled = true,
    this.behavior = HitTestBehavior.opaque,
    this.pressedScale = 0.97,
    this.haptic = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool enabled;
  final HitTestBehavior behavior;

  /// Scale while pressed. 1.0 disables the effect (e.g. for text links).
  final double pressedScale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  bool get _active => widget.enabled && widget.onTap != null;

  void _set(bool v) {
    if (_active && v != _down) setState(() => _down = v);
  }

  void _tap() {
    if (widget.haptic) HapticFeedback.selectionClick();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _active,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: _active ? _tap : null,
        child: AnimatedScale(
          scale: _down ? widget.pressedScale : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: _down ? 0.8 : 1,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
