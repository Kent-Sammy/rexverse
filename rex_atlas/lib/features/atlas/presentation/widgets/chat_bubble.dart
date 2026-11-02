import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

enum BubbleTail { left, right, none }

/// iMessage-style bubble: generous 18pt corners and a curled tail on the
/// last bubble of a group. Colours follow the Rex Atlas Figma tokens.
class ChatBubbleBorder extends ShapeBorder {
  const ChatBubbleBorder({required this.tail, this.radius = 18});

  final BubbleTail tail;
  final double radius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect r, {TextDirection? textDirection}) {
    final rad = radius.clamp(0.0, r.height / 2);
    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(r, Radius.circular(rad)));
    if (tail == BubbleTail.none) return body;

    // Curled tail hugging the bottom corner, tip slightly outside the bubble.
    final t = Path();
    if (tail == BubbleTail.right) {
      final x = r.right, y = r.bottom;
      t
        ..moveTo(x - 12, y - 14)
        ..quadraticBezierTo(x - 1, y - 6, x + 5, y)
        ..quadraticBezierTo(x - 5, y + 1, x - 14, y - 4)
        ..close();
      t.addRect(Rect.fromLTRB(x - 14, y - 16, x - 4, y));
    } else {
      final x = r.left, y = r.bottom;
      t
        ..moveTo(x + 12, y - 14)
        ..quadraticBezierTo(x + 1, y - 6, x - 5, y)
        ..quadraticBezierTo(x + 5, y + 1, x + 14, y - 4)
        ..close();
      t.addRect(Rect.fromLTRB(x + 4, y - 16, x + 14, y));
    }
    return Path.combine(PathOperation.union, body, t);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) =>
      ChatBubbleBorder(tail: tail, radius: radius * t);
}

const _bubblePadding = EdgeInsets.symmetric(horizontal: 12, vertical: 9);

/// Assistant bubble (light blue). [tail] is false for all but the last
/// bubble in a run of assistant messages.
class AssistantBubble extends StatelessWidget {
  const AssistantBubble({
    super.key,
    required this.child,
    this.color = RexColors.bubbleAssistant,
    this.tail = true,
  });

  final Widget child;
  final Color color;
  final bool tail;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: _bubblePadding,
      decoration: ShapeDecoration(
        color: color,
        shape: ChatBubbleBorder(tail: tail ? BubbleTail.left : BubbleTail.none),
      ),
      child: Align(
        widthFactor: 1,
        heightFactor: 1,
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }
}

/// User bubble (primary blue).
class UserBubble extends StatelessWidget {
  const UserBubble({super.key, required this.text, this.tail = true});
  final String text;
  final bool tail;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: _bubblePadding,
      decoration: ShapeDecoration(
        color: RexColors.primary,
        shape: ChatBubbleBorder(
          tail: tail ? BubbleTail.right : BubbleTail.none,
        ),
      ),
      child: Text(text, style: RexTypography.bubbleUser),
    );
  }
}
