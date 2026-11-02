import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';
import '../../device/device_services.dart';
import 'atlas_header.dart';

/// "+" menu: choose a photo or a document to share with Atlas.
class AttachmentOptionsSheet extends StatelessWidget {
  const AttachmentOptionsSheet({super.key});

  static Future<AttachmentKind?> show(BuildContext context) =>
      showModalBottomSheet<AttachmentKind>(
        context: context,
        barrierColor: RexColors.scrim,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RexDimens.sheetRadius),
          ),
        ),
        builder: (_) => const AttachmentOptionsSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 13, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: SheetHandle()),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              'Share with Rex Atlas',
              style: RexTypography.sheetTitle.copyWith(fontSize: 17),
            ),
          ),
          const SizedBox(height: 14),
          _Option(
            key: const Key('attach-photo'),
            icon: Icons.photo_library_rounded,
            title: 'Photo or screenshot',
            subtitle: 'From your gallery',
            onTap: () => Navigator.of(context).pop(AttachmentKind.image),
          ),
          const SizedBox(height: 8),
          _Option(
            key: const Key('attach-document'),
            icon: Icons.description_rounded,
            title: 'Document',
            subtitle: 'PDF, Word, Excel or text, up to 10 MB',
            onTap: () => Navigator.of(context).pop(AttachmentKind.document),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      semanticLabel: title,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: RexColors.softBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: RexColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: RexTypography.suggestionTitle),
                  Text(subtitle, style: RexTypography.suggestionSub),
                ],
              ),
            ),
            const RexSvgIcon(
              RexSvg.chevron,
              size: 12,
              color: RexColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
