import 'package:flutter/widgets.dart';

/// One-shot entrance used for new chat messages: an iMessage-like pop that
/// fades in, rises a few points and scales up from the sender's side.
class Appear extends StatefulWidget {
  const Appear({
    super.key,
    required this.child,
    this.offset = 14,
    this.fromScale = 0.92,
    this.alignment = Alignment.bottomCenter,
    this.duration = const Duration(milliseconds: 380),
  });

  final Widget child;
  final double offset;
  final double fromScale;

  /// Scale origin: bottom-right for the user, bottom-left for Atlas.
  final Alignment alignment;
  final Duration duration;

  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the OS "reduce motion" setting.
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _c.value = 1;
    } else if (_c.status == AnimationStatus.dismissed) {
      _c.forward();
    }
  }

  late final Animation<double> _move = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutBack,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0, 0.6, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _move.value;
        return Opacity(
          opacity: _fade.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * widget.offset),
            child: Transform.scale(
              scale: widget.fromScale + (1 - widget.fromScale) * t,
              alignment: widget.alignment,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
