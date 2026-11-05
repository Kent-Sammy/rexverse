import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/models/models.dart';

/// A shared photo (thumbnail) or document (file chip) on the user's side.
class AttachmentBubble extends StatelessWidget {
  const AttachmentBubble({super.key, required this.message});
  final AttachmentMessage message;

  static String _size(int b) {
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final m = message;
    if (m.isImage && m.imageBytes != null) {
      return Semantics(
        label: 'Image ${m.fileName}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200, maxHeight: 220),
            child: Image.memory(
              m.imageBytes!,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
      decoration: BoxDecoration(
        gradient: RexColors.userGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  m.fileName,
                  style: RexTypography.bubbleUser,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _size(m.sizeBytes),
                  style: RexTypography.bubbleUser.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
