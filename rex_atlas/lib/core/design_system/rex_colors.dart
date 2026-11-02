import 'package:flutter/painting.dart';

/// Rex / Rex Atlas colour tokens.
///
/// Figma variables could not be read (Figma MCP plan limit), so every value
/// here was sampled from the rendered Figma frames in the
/// "RexAtlas  New work flow" section (node 25218:51967). See
/// `docs/DESIGN_TOKENS.md` for where each value was measured.
abstract final class RexColors {
  // Brand
  static const navy = Color(0xFF002766);
  static const primary = Color(0xFF323DFF);
  static const logoNavy = Color(0xFF002D93);

  // Surfaces
  static const white = Color(0xFFFFFFFF);
  static const appBackground = Color(0xFFF1F5FF);
  static const bubbleAssistant = Color(0xFFE2EBFF);
  static const softBlue = Color(0xFFE2EBFF);
  static const avatarFill = Color(0xFFC5D7FF);
  static const fingerprintCircle = Color(0xFFF1F2FF);
  static const divider = Color(0xFFF2F2F4);
  static const hairline = Color(0xFFF2F2F2);

  // Atlas sheet chrome
  static const sheetHandle = Color(0xFFC0D6FF);
  static const welcomeHandle = Color(0xFFA9C4F6);
  static const headerIcon = Color(0xFF6CA4FF);

  /// Scrim drawn over the host app while Atlas is open.
  /// Solved from dimmed vs. undimmed pixels: #090D1E at 75% opacity.
  static const scrim = Color(0xBF090D1E);

  // Welcome sheet gradient
  static const welcomeBase = Color(0xFF002766);
  static const welcomeGlow = Color(0xFF1D58BD);

  // Text
  static const textPrimary = Color(0xFF313131);
  static const textStrong = Color(0xFF130F26);
  static const textSecondary = Color(0xFF838383);
  static const textMuted = Color(0xFF696666);
  static const textPlaceholder = Color(0xFF969696);
  static const textSubtle = Color(0xFF797979);
  static const textBody = Color(0xFF646464);
  static const textDetailTitle = Color(0xFF444444);
  static const textDetailLabel = Color(0xFFA5A5A5);
  static const textDetailValue = Color(0xFF505050);
  static const textTxMeta = Color(0xFF96A1B8);

  // Status
  static const success = Color(0xFF008000);
  static const successTeal = Color(0xFF3DD6C9);
  static const successHalo = Color(0xFFDDF8F5);
  static const error = Color(0xFFD92D20);
  static const errorSoft = Color(0xFFFDECEA);

  // Icon accents (quick actions / suggestions / history)
  static const accentGreen = Color(0xFF00BC4F);
  static const accentMint = Color(0xFF86FFB9);
  static const accentOrange = Color(0xFFFFA412);
  static const accentCyan = Color(0xFF00BCD3);
  static const accentBlue = Color(0xFF1456F4);
  static const gtBankOrange = Color(0xFFD94F00);

  // Transaction history icon circles
  static const historyGreenBg = Color(0xFFE1FFE3);
  static const historyGreen = Color(0xFF15E11D);
  static const historyBlueBg = Color(0xFFE7F0FE);
  static const historyCyanBg = Color(0xFFE2FCFF);
  static const historyOrangeBg = Color(0xFFFFF0D9);

  // Avatar ring gradient (assistant avatar)
  static const ringCyan = Color(0xFF02BEFF);
  static const ringPurple = Color(0xFF9A35FF);

  // Confirmation / success card wash
  static const washBlue = Color(0xFFDCECFF);
  static const washPink = Color(0xFFFCD7FF);

  // Host (Rex home) tokens
  static const hostCardBlue = Color(0xFF1953B4);
  static const hostCardNavy = Color(0xFF0B3A8C);
  static const hostCheckGreen = Color(0xFF4DCA7C);
  static const tileGreen = Color(0xFFEBF3EB);
  static const tileBlue = Color(0xFFEFF3FF);
  static const tileOrange = Color(0xFFFFF7EB);
  static const tileCyan = Color(0xFFEBFAFC);
  static const iconGreen = Color(0xFF13B850);
  static const iconBlue = Color(0xFF5177FD);
  static const iconOrange = Color(0xFFFF981F);
  static const iconCyan = Color(0xFF14C3DA);
  static const navInactive = Color(0xFFB9C3D6);
  static const bannerBlue = Color(0xFF4F86C8);
}
