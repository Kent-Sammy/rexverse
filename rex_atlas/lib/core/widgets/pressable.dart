import 'package:flutter/widgets.dart';

/// Lightweight tap target with an opacity press state. Used instead of
/// Material ink so the Figma surfaces render without ripples.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
    this.enabled = true,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool enabled;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  bool get _active => widget.enabled && widget.onTap != null;

  void _set(bool v) {
    if (_active && v != _down) setState(() => _down = v);
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
        onTap: _active ? widget.onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 90),
          opacity: _down ? 0.6 : 1,
          child: widget.child,
        ),
      ),
    );
  }
}
