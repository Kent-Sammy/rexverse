import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Spacing, radii and component sizes measured from Figma frame geometry
/// (402 x 874 frames, "RexAtlas  New work flow").
abstract final class RexDimens {
  /// Width of the Figma artboards. Used only by the demo device frame.
  static const designWidth = 402.0;
  static const designHeight = 874.0;

  // Sheet
  static const sheetRadius = 20.0;
  static const sheetHandleWidth = 48.0;
  static const sheetHandleHeight = 4.0;
  static const sheetHandleTop = 13.0; // welcome sheet
  static const chatHandleTop = 18.0; // chat sheet

  /// Welcome (collapsed) sheet height on the 874pt artboard. Figma: 631.
  /// Product-owner changes: recent-transaction card removed, a second row of
  /// quick actions added and more room above the message bar:
  /// content 510 (two tile rows end at 502 + 8) + 24 gap + 48 bar + 26 = 608.
  static const collapsedSheetHeight = 608.0;

  // Chat layout
  static const pagePadding = 16.0;
  static const messageGap = 20.0;
  static const avatarSize = 33.0;
  static const avatarGap = 8.0; // avatar -> bubble
  static const userAvatarGap = 6.0; // bubble -> user avatar
  static const bubbleRadius = 10.0;
  static const bubblePaddingH = 10.0;
  static const bubblePaddingV = 10.0;
  static const bubbleTail = 8.0;

  // Composer
  static const composerHeight = 48.0;
  static const composerHorizontalInset = 17.0;
  static const composerBottomInset = 26.0;

  /// Space under the message bar. Thin home indicators (iPhone, Android
  /// gesture bar: up to 34 pt) keep the Figma 26 pt inset. Taller system
  /// bars, such as Android's three-button navigation, get the bar's height
  /// plus 8 pt so the input never sits underneath them. An open keyboard
  /// wins over both.
  static double composerBottom(BuildContext context) {
    final system = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final bar = system > 34 ? system + 8 : composerBottomInset;
    return math.max(bar, keyboard + 12);
  }

  static const composerIconButton = 27.0;

  // Cards
  static const cardRadius = 12.0;
  static const innerCardRadius = 8.0;
}
