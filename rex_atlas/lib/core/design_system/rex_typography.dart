import 'package:flutter/painting.dart';

import 'rex_colors.dart';

/// Text styles for Rex Atlas.
///
/// Sizes were derived from Figma text-box geometry: box heights match a
/// 1.21 line height (14 -> 17, 28 -> 34, 10 -> 12) and hug widths match Inter
/// within a few percent. The exact Figma font family could not be confirmed
/// (see docs/DESIGN_TOKENS.md); change [fontFamily] here to swap it globally.
abstract final class RexTypography {
  static const fontFamily = 'Inter';
  static const _lh = 1.21;

  static TextStyle _s(
    double size,
    FontWeight weight,
    Color color, {
    double? height,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height ?? _lh,
    letterSpacing: 0,
  );

  // Atlas header
  static final headerTitle = _s(17, FontWeight.w600, RexColors.navy);
  static final headerSubtitle = _s(10, FontWeight.w400, RexColors.textMuted);

  // Chat
  static final bubble = _s(14, FontWeight.w400, RexColors.textPrimary);
  static final bubbleUser = _s(14, FontWeight.w400, RexColors.white);
  static final avatarInitials = _s(14, FontWeight.w500, RexColors.navy);
  static final composerHint = _s(
    14,
    FontWeight.w400,
    RexColors.textPlaceholder,
  );
  static final composerInput = _s(14, FontWeight.w400, RexColors.textPrimary);

  // Welcome
  static final welcomeGreeting = _s(28, FontWeight.w500, RexColors.white);
  static final welcomeSubtitle = _s(14, FontWeight.w400, RexColors.white);
  static final welcomeTile = _s(14, FontWeight.w400, RexColors.white);
  static final welcomeSection = _s(14, FontWeight.w400, RexColors.white);
  static final welcomeTxTitle = _s(14, FontWeight.w500, RexColors.white);
  static final welcomeTxMeta = _s(10, FontWeight.w400, RexColors.white);

  // Review / confirmation cards
  static final cardName = _s(14, FontWeight.w400, RexColors.textPrimary);
  static final cardSub = _s(12, FontWeight.w400, RexColors.textSecondary);
  static final rowLabel = _s(14, FontWeight.w400, RexColors.textPrimary);
  static final rowValue = _s(14, FontWeight.w500, RexColors.textPrimary);
  static final rowTotal = _s(14, FontWeight.w600, RexColors.textPrimary);
  static final confirmCaption = _s(14, FontWeight.w400, RexColors.textStrong);
  static final confirmAmount = _s(22, FontWeight.w700, RexColors.textStrong);
  static final confirmName = _s(12, FontWeight.w500, RexColors.textStrong);
  static final confirmBank = _s(10, FontWeight.w400, RexColors.textSecondary);

  // Biometric sheet
  static final sheetTitle = _s(20, FontWeight.w600, RexColors.textStrong);
  static final sheetBody = _s(14, FontWeight.w400, RexColors.textSubtle);
  static final link = _s(14, FontWeight.w500, RexColors.primary);

  // Result card
  static final resultTitle = _s(15, FontWeight.w600, RexColors.textStrong);
  static final resultBody = _s(
    11.5,
    FontWeight.w400,
    RexColors.textBody,
    height: 1.22,
  );
  static final smallButton = _s(9, FontWeight.w600, RexColors.navy);
  static final detailTitle = _s(11, FontWeight.w500, RexColors.textDetailTitle);
  static final detailLabel = _s(8, FontWeight.w400, RexColors.textDetailLabel);
  static final detailValue = _s(8, FontWeight.w400, RexColors.textDetailValue);

  // Suggestions
  static final suggestionTitle = _s(14, FontWeight.w400, RexColors.textPrimary);
  static final suggestionSub = _s(12, FontWeight.w400, RexColors.textSecondary);

  // Transaction history
  static final historyTitle = _s(12, FontWeight.w500, RexColors.textStrong);
  static final historyMeta = _s(10, FontWeight.w400, RexColors.textTxMeta);
  static final historyAmount = _s(12, FontWeight.w600, RexColors.textStrong);
  static final historyStatus = _s(10, FontWeight.w500, RexColors.success);

  // Misc
  static final caption = _s(11, FontWeight.w400, RexColors.textSecondary);
  static final demoBadge = _s(8, FontWeight.w700, RexColors.white);

  // Host (Rex home) – used only by the stand-in host screen.
  static TextStyle host(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = RexColors.textStrong,
  }) => _s(size, weight, color);
}
