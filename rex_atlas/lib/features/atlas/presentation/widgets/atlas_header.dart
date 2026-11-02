import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';
import 'atlas_brand.dart';

/// "Rex Atlas / Your AI banking assistant" header with expand + close.
class AtlasHeader extends StatelessWidget {
  const AtlasHeader({
    super.key,
    required this.isFullscreen,
    required this.onToggleFullscreen,
    required this.onClose,
  });

  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 33,
      child: Row(
        children: [
          const AtlasMarkBadge(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rex Atlas', style: RexTypography.headerTitle),
                Text(
                  'Your AI banking assistant',
                  style: RexTypography.headerSubtitle,
                ),
              ],
            ),
          ),
          Pressable(
            semanticLabel: isFullscreen
                ? 'Exit full screen'
                : 'Expand to full screen',
            onTap: onToggleFullscreen,
            child: SizedBox(
              width: 24,
              height: 24,
              child: isFullscreen
                  ? const Icon(
                      Icons.close_fullscreen_rounded,
                      size: 20,
                      color: RexColors.headerIcon,
                    )
                  : const RexSvgIcon(
                      RexSvg.maximize,
                      size: 24,
                      color: RexColors.headerIcon,
                    ),
            ),
          ),
          const SizedBox(width: 13),
          Pressable(
            semanticLabel: 'Close Rex Atlas',
            onTap: onClose,
            child: const RexSvgIcon(
              RexSvg.close,
              size: 24,
              color: RexColors.headerIcon,
            ),
          ),
        ],
      ),
    );
  }
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key, this.color = RexColors.sheetHandle});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: RexDimens.sheetHandleWidth,
      height: RexDimens.sheetHandleHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
