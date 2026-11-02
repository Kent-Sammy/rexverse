import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/replaceable_asset.dart';

/// Figma artwork exported by the design owner (see docs/ASSETS.md).
abstract final class AtlasAssets {
  /// "Gemini_Generated_Image_cpel96cpel96cpel 1" incl. its gradient ring.
  static const assistantAvatar = 'assets/images/atlas_assistant_avatar.png';

  /// Mark on a light-blue disc ("Frame 2147234634", 33 × 33).
  static const badge = 'assets/images/rex_atlas_badge.svg';

  /// Mark on a navy disc with gradient stroke ("Component 5", home bar).
  static const badgeDark = 'assets/images/rex_atlas_badge_dark.svg';

  /// The mark alone (paths from the badge export).
  static const mark = 'assets/images/rex_atlas_mark.svg';

  /// Success illustration ("https://lottiefiles.com/95088-success" layer).
  static const successBadge = 'assets/images/success_badge.png';

  /// "🎉" illustration on the home savings card.
  static const partyPopper = 'assets/images/party_popper.png';

  /// Bank logos by bank code, e.g. GTBank Plc → `banks/058.svg`.
  static String bankLogo(String code) => 'assets/images/banks/$code.svg';
}

/// Assistant avatar (robot portrait with cyan→purple ring).
class AtlasBotAvatar extends StatelessWidget {
  const AtlasBotAvatar({super.key, this.size = RexDimens.avatarSize});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AtlasAssets.assistantAvatar,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Rex Atlas',
    );
  }
}

/// Rex Atlas mark on its light-blue disc (header, confirmation card).
class AtlasMarkBadge extends StatelessWidget {
  const AtlasMarkBadge({
    super.key,
    this.size = RexDimens.avatarSize,
    this.dark = false,
  });

  final double size;

  /// Navy disc variant used in the home "Ask RexAtlas" bar.
  final bool dark;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    dark ? AtlasAssets.badgeDark : AtlasAssets.badge,
    width: size,
    height: size,
  );
}

/// The Rex Atlas mark without a disc (home "RexAtlas" service tile).
class AtlasMark extends StatelessWidget {
  const AtlasMark({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset(AtlasAssets.mark, width: width, height: height);
}

/// Circular bank logo. Uses the Figma export when one exists for the bank
/// code (GTBank). Banks that never appear in the designs (the mock bank
/// directory includes others) fall back to a coloured disc with initials.
class BankLogo extends StatelessWidget {
  const BankLogo({
    super.key,
    required this.code,
    required this.shortName,
    this.size = 35,
  });

  final String code;
  final String shortName;
  final double size;

  static const _palette = [
    Color(0xFF0D6EFD),
    Color(0xFFE21B23),
    Color(0xFF6F2DBD),
    Color(0xFF0FA958),
    Color(0xFF1B1F3B),
    Color(0xFF00897B),
  ];

  @override
  Widget build(BuildContext context) {
    final color =
        _palette[code.codeUnits.fold(0, (a, b) => a + b) % _palette.length];
    final label = shortName.length <= 3 ? shortName : shortName.substring(0, 3);
    return ClipOval(
      child: ReplaceableAsset(
        path: AtlasAssets.bankLogo(code),
        width: size,
        height: size,
        placeholder: Container(
          color: color,
          alignment: Alignment.center,
          child: Text(
            label.toUpperCase(),
            style: RexTypography.demoBadge.copyWith(fontSize: size * 0.24),
          ),
        ),
      ),
    );
  }
}
