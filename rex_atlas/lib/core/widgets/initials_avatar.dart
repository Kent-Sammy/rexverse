import 'package:flutter/widgets.dart';

import '../design_system/design_system.dart';

/// Circular initials avatar ("OM" in the Figma frames).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = RexDimens.avatarSize,
    this.background = RexColors.avatarFill,
    this.style,
  });

  final String initials;
  final double size;
  final Color background;
  final TextStyle? style;

  static String fromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final base = style ?? RexTypography.avatarInitials;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        initials,
        style: base.copyWith(fontSize: base.fontSize! * size / 33),
      ),
    );
  }
}
