import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/replaceable_asset.dart';

/// Asset slots for Figma artwork that could not be exported.
/// Drop the exported files at these paths to replace the placeholders.
abstract final class AtlasAssetSlots {
  /// Figma layer "Gemini_Generated_Image_cpel96cpel96cpel 1" (e.g. 25217:42513).
  static const assistantAvatar = 'assets/images/atlas_assistant_avatar.png';

  /// Rex Atlas mark used in the header (e.g. 25217:43423 "Frame").
  static const atlasMark = 'assets/images/rex_atlas_mark.svg';

  /// Bank logos, named by bank code, e.g. `assets/images/banks/058.png`
  /// for the "GTBank Plc" component (25218:43726).
  static String bankLogo(String code) => 'assets/images/banks/$code.png';
}

/// Assistant avatar with the cyan→purple ring from Figma.
///
/// Placeholder (until [AtlasAssetSlots.assistantAvatar] is supplied): blue
/// disc with a robot glyph.
class AtlasBotAvatar extends StatelessWidget {
  const AtlasBotAvatar({super.key, this.size = RexDimens.avatarSize});

  final double size;

  @override
  Widget build(BuildContext context) {
    final ring = math.max(1.5, size * 0.055);
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ring),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RexColors.ringCyan, RexColors.ringPurple],
        ),
      ),
      child: ClipOval(
        child: ReplaceableAsset(
          path: AtlasAssetSlots.assistantAvatar,
          placeholder: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF5A63FF), RexColors.primary],
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.smart_toy_rounded,
              size: size * 0.55,
              color: const Color(0xFFE8ECF5),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rex Atlas mark inside a light-blue disc (header, confirmation card).
class AtlasMarkBadge extends StatelessWidget {
  const AtlasMarkBadge({super.key, this.size = RexDimens.avatarSize});
  final double size;

  @override
  Widget build(BuildContext context) {
    final markW = size * 17.8 / 33;
    final markH = size * 14.2 / 33;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: RexColors.avatarFill,
        shape: BoxShape.circle,
      ),
      child: AtlasMark(width: markW, height: markH),
    );
  }
}

class AtlasMark extends StatelessWidget {
  const AtlasMark({
    super.key,
    required this.width,
    required this.height,
    this.primary = RexColors.logoNavy,
    this.accent = RexColors.headerIcon,
  });

  final double width;
  final double height;
  final Color primary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ReplaceableAsset(
      path: AtlasAssetSlots.atlasMark,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholder: CustomPaint(
        size: Size(width, height),
        painter: _AtlasMarkPainter(primary, accent),
      ),
    );
  }
}

/// TEMPORARY approximation of the Rex Atlas mark (a navy "X" with a lighter
/// chevron), traced by eye from the Figma render. Replace with the real
/// vector via [AtlasAssetSlots.atlasMark].
class _AtlasMarkPainter extends CustomPainter {
  _AtlasMarkPainter(this.primary, this.accent);
  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size s) {
    final stroke = s.height * 0.2;
    final p = Paint()
      ..color = primary
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final inset = stroke / 2;
    final xw = s.width * 0.62;
    canvas.drawLine(
      Offset(inset, inset),
      Offset(xw - inset, s.height - inset),
      p,
    );
    canvas.drawLine(
      Offset(inset, s.height - inset),
      Offset(xw - inset, inset),
      p,
    );
    final a = Paint()
      ..color = accent
      ..strokeWidth = stroke * 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(s.width - inset, s.height * 0.18)
      ..lineTo(s.width * 0.74, s.height * 0.5)
      ..lineTo(s.width - inset, s.height * 0.82);
    canvas.drawPath(path, a);
  }

  @override
  bool shouldRepaint(_AtlasMarkPainter old) =>
      old.primary != primary || old.accent != accent;
}

/// Circular bank logo. Placeholder: coloured disc with the bank's initials
/// (GTBank uses its sampled brand orange).
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
    RexColors.gtBankOrange,
    Color(0xFF0D6EFD),
    Color(0xFFE21B23),
    Color(0xFF6F2DBD),
    Color(0xFF0FA958),
    Color(0xFF1B1F3B),
  ];

  @override
  Widget build(BuildContext context) {
    final color = code == '058'
        ? RexColors.gtBankOrange
        : _palette[code.codeUnits.fold(0, (a, b) => a + b) % _palette.length];
    final label = shortName.length <= 3 ? shortName : shortName.substring(0, 3);
    return ClipOval(
      child: ReplaceableAsset(
        path: AtlasAssetSlots.bankLogo(code),
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
