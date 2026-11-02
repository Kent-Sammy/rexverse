import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

enum BubbleTail { left, right }

/// Bubble outline from Figma: 10pt corners, the tail corner squared off and
/// a triangular tail ("Polygon 1") hanging below that edge.
class ChatBubbleBorder extends ShapeBorder {
  const ChatBubbleBorder({
    required this.tail,
    this.radius = RexDimens.bubbleRadius,
    this.tailSize = RexDimens.bubbleTail,
  });

  final BubbleTail tail;
  final double radius;
  final double tailSize;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect r, {TextDirection? textDirection}) {
    final rr = RRect.fromRectAndCorners(
      r,
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
      bottomLeft: tail == BubbleTail.left
          ? Radius.zero
          : Radius.circular(radius),
      bottomRight: tail == BubbleTail.right
          ? Radius.zero
          : Radius.circular(radius),
    );
    final path = Path()..addRRect(rr);
    final t = tailSize;
    final tri = Path();
    if (tail == BubbleTail.right) {
      tri
        ..moveTo(r.right - t * 1.2, r.bottom - 0.5)
        ..lineTo(r.right, r.bottom - 0.5)
        ..lineTo(r.right, r.bottom + t)
        ..close();
    } else {
      tri
        ..moveTo(r.left, r.bottom - 0.5)
        ..lineTo(r.left + t * 1.4, r.bottom - 0.5)
        ..lineTo(r.left, r.bottom + t)
        ..close();
    }
    return Path.combine(PathOperation.union, path, tri);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) =>
      ChatBubbleBorder(tail: tail, radius: radius * t, tailSize: tailSize * t);
}

/// Assistant bubble: light blue, min height 50, text vertically centred.
class AssistantBubble extends StatelessWidget {
  const AssistantBubble({
    super.key,
    required this.child,
    this.color = RexColors.bubbleAssistant,
  });

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: ShapeDecoration(
        color: color,
        shape: const ChatBubbleBorder(tail: BubbleTail.left),
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

/// User bubble: primary blue, 37pt tall for a single line.
class UserBubble extends StatelessWidget {
  const UserBubble({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const ShapeDecoration(
        color: RexColors.primary,
        shape: ChatBubbleBorder(tail: BubbleTail.right),
      ),
      child: Text(text, style: RexTypography.bubbleUser),
    );
  }
}
