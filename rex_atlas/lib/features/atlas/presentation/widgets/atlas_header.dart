import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';
import 'atlas_brand.dart';

/// "Rex Atlas / Your AI agent" header with expand + close.
class AtlasHeader extends StatelessWidget {
  const AtlasHeader({
    super.key,
    required this.isFullscreen,
    required this.onToggleFullscreen,
    required this.onClose,
    this.soundOn = true,
    this.onToggleSound,
  });

  final bool soundOn;
  final VoidCallback? onToggleSound;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 33,
        maxHeight: double.infinity,
      ),
      child: Row(
        children: [
          const AtlasMarkBadge(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text('Rex Atlas', style: RexTypography.headerTitle),
                ),
                Text(
                  'Your AI agent',
                  style: RexTypography.headerSubtitle,
                ),
              ],
            ),
          ),
          if (onToggleSound != null)
            Pressable(
              key: const Key('atlas-sound-toggle'),
              semanticLabel: soundOn
                  ? 'Mute chat sounds'
                  : 'Turn on chat sounds',
              onTap: onToggleSound,
              child: SizedBox(
                width: 36,
                height: 33,
                child: Center(
                  child: Icon(
                    soundOn
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    size: 22,
                    color: RexColors.headerIcon,
                  ),
                ),
              ),
            ),
          // Icons sit where Figma puts them (centres at x 337 and 374); the
          // tap areas are widened to 36 pt and the full 33 pt header height.
          Pressable(
            semanticLabel: isFullscreen
                ? 'Exit full screen'
                : 'Expand to full screen',
            onTap: onToggleFullscreen,
            child: SizedBox(
              width: 36,
              height: 33,
              child: Center(
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
          ),
          Pressable(
            semanticLabel: 'Close Rex Atlas',
            onTap: onClose,
            child: const SizedBox(
              width: 36,
              height: 33,
              child: Center(
                child: RexSvgIcon(
                  RexSvg.close,
                  size: 24,
                  color: RexColors.headerIcon,
                ),
              ),
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
