import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/rex_colors.dart';

/// Tap target with a soft press state (slight scale-down + dim), a light
/// selection haptic, and keyboard support: it is focusable, shows a visible
/// focus ring (WCAG 2.4.7) and activates with Enter/Space.
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
    this.focusRadius = 12,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool enabled;
  final HitTestBehavior behavior;

  /// Scale while pressed. 1.0 disables the effect (e.g. for text links).
  final double pressedScale;
  final bool haptic;
  final double focusRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  bool _focused = false;

  bool get _active => widget.enabled && widget.onTap != null;

  void _set(bool v) {
    if (_active && v != _down) setState(() => _down = v);
  }

  void _tap() {
    if (!_active) return;
    if (widget.haptic) HapticFeedback.selectionClick();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Semantics(
      button: true,
      enabled: _active,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: _active,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _tap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: widget.behavior,
          onTapDown: (_) => _set(true),
          onTapUp: (_) => _set(false),
          onTapCancel: () => _set(false),
          onTap: _active ? _tap : null,
          child: AnimatedScale(
            scale: _down && !reduceMotion ? widget.pressedScale : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: _down ? 0.8 : 1,
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.focusRadius),
                  border: _focused
                      ? Border.all(color: RexColors.primary, width: 2)
                      : null,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
