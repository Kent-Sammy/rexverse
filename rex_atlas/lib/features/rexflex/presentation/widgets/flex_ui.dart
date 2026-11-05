import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/demo_device_frame.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/formatting/naira.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../atlas/presentation/widgets/atlas_brand.dart';
import '../../domain/rexflex_models.dart';

/// Shared RexFlex building blocks, measured from the "rexflex" Figma
/// section (402 × 874/903 frames).
abstract final class FlexColors {
  static const background = RexColors.appBackground; // #F1F5FF
  static const navy = RexColors.navy; // titles + primary buttons
  static const panel = Color(0xFFE9F1FF); // detail boxes
  static const selectedBorder = Color(0xFF9DB8F2);
  static const noteBg = Color(0xFFFFF1DC);
  static const noteIcon = Color(0xFFF5A524);
  static const noteText = Color(0xFF5B4A1F);
  static const label = RexColors.textSecondary; // #696969
  static const value = RexColors.textPrimary;
  static const green = RexColors.success; // #008000
  static const greenBg = Color(0xFFE1FFE3);
  static const settledBg = Color(0xFFD3FBD9);
  static const purple = Color(0xFF7A2BD6);
  static const purpleBg = Color(0xFFF1E6FF);
  static const secondaryBg = Color(0xFFDCE7FF);
}

abstract final class FlexAssets {
  /// Figma exports supplied by the design owner (3×, transparent).
  static const hero = 'assets/images/rexflex/rexflex_hero.png'; // 1206×681
  static const cash = 'assets/images/rexflex/rexflex_cash.png'; // 246×124
  static const cashTilt = 'assets/images/rexflex/rexflex_cash_tilt.png';
  static const journey = 'assets/images/rexflex/rexflex_journey.png';
}

/// `₦ 3,112.00` – the balance-card style with a space after the sign.
String flexCardAmount(int kobo) =>
    '${Naira.symbol} ${Naira.grouped(kobo).substring(1)}';

/// Back arrow + either a centred title ("RexFlex Loan") or a large
/// left-aligned title with subtitle ("RexFlex", "Choose a Repayment Term").
class FlexScaffold extends StatelessWidget {
  const FlexScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.centeredTitle = false,
    required this.children,
    this.bottom,
    this.background = FlexColors.background,
  });

  final String title;
  final String? subtitle;
  final bool centeredTitle;
  final List<Widget> children;
  final Widget? bottom;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final back = Pressable(
      key: const Key('flex-back'),
      semanticLabel: 'Back',
      onTap: () => Navigator.of(context).maybePop(),
      child: const SizedBox(
        width: 44,
        height: 44,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.arrow_back, size: 24, color: RexColors.textStrong),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: math.max(pad.top, 20) + 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: centeredTitle
                    ? SizedBox(
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(alignment: Alignment.centerLeft, child: back),
                            Semantics(
                              header: true,
                              child: Text(
                                title,
                                style: RexTypography.host(
                                  17,
                                  weight: FontWeight.w700,
                                  color: FlexColors.navy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Align(alignment: Alignment.centerLeft, child: back),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    if (!centeredTitle) ...[
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: RexTypography.host(
                            22,
                            weight: FontWeight.w700,
                            color: FlexColors.navy,
                          ),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: RexTypography.host(
                            12,
                            weight: FontWeight.w500,
                            color: FlexColors.label,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ] else
                      const SizedBox(height: 8),
                    ...children,
                  ],
                ),
              ),
              if (bottom != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    math.max(16, pad.bottom + 8),
                  ),
                  child: bottom,
                ),
            ],
          ),
          if (DemoDeviceFrame.showsStatusBar(context))
            const Positioned(left: 0, right: 0, top: 0, child: DemoStatusBar()),
        ],
      ),
    );
  }
}

class FlexButton extends StatelessWidget {
  const FlexButton({
    super.key,
    required this.label,
    required this.onTap,
    this.secondary = false,
    this.busy = false,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onTap;
  final bool secondary;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !busy;
    final bg = secondary ? FlexColors.secondaryBg : FlexColors.navy;
    final fg = secondary ? FlexColors.navy : Colors.white;
    return Pressable(
      semanticLabel: label,
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: busy
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
                )
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: RexTypography.host(
                    14,
                    weight: FontWeight.w600,
                    color: fg,
                  ),
                ),
        ),
      ),
    );
  }
}

class FlexCard extends StatelessWidget {
  const FlexCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = Colors.white,
    this.border,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color? border;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      border: border == null ? null : Border.all(color: border!, width: 1.5),
    ),
    child: child,
  );
}

/// Navy → blue card with the cash stack: "Outstanding Balance ₦ 3,112.00".
class FlexBalanceCard extends StatelessWidget {
  const FlexBalanceCard({
    super.key,
    required this.label,
    required this.amountKobo,
    required this.caption,
    this.tiltedCash = false,
  });
  final String label;
  final int amountKobo;
  final String caption;

  /// The "Available loan amount" card shows the tilted cash bleeding off the
  /// corner; the balance cards show the flat stack.
  final bool tiltedCash;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: EdgeInsets.fromLTRB(16, 16, tiltedCash ? 96 : 12, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RexColors.userGradientStart, RexColors.userGradientEnd],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: RexTypography.host(
                    12,
                    weight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  flexCardAmount(amountKobo),
                  style: RexTypography.host(
                    24,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  caption,
                  style: RexTypography.host(
                    12,
                    weight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (!tiltedCash)
            const ExcludeSemantics(
              child: Image(
                image: AssetImage(FlexAssets.cash),
                width: 80,
                filterQuality: FilterQuality.high,
              ),
            ),
        ],
      ),
    );
    if (!tiltedCash) return body;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          body,
          const Positioned(
            right: 0,
            bottom: 0,
            child: ExcludeSemantics(
              child: Image(
                image: AssetImage(FlexAssets.cashTilt),
                width: 86,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Light-blue panel with a title, hairline and label/value rows.
class FlexDetailBox extends StatelessWidget {
  const FlexDetailBox({super.key, required this.title, required this.rows});
  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: FlexColors.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: RexTypography.host(
              13,
              weight: FontWeight.w600,
              color: RexColors.textStrong,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: Colors.white),
          const SizedBox(height: 6),
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: RexTypography.host(
                        12,
                        weight: FontWeight.w500,
                        color: FlexColors.label,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: RexTypography.host(
                        12,
                        weight: FontWeight.w500,
                        color: FlexColors.value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Amber note with a shield icon ("8% interest per 30 days").
class FlexNote extends StatelessWidget {
  const FlexNote(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: FlexColors.noteBg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const RexSvgIcon(RexSvg.flexSafeLock, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: RexTypography.host(
              12,
              weight: FontWeight.w500,
              color: FlexColors.noteText,
            ),
          ),
        ),
      ],
    ),
  );
}

class FlexRadio extends StatelessWidget {
  const FlexRadio({super.key, required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 160),
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: selected ? FlexColors.navy : const Color(0xFF8FB0F5),
        width: 1.6,
      ),
    ),
    padding: const EdgeInsets.all(3.5),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? FlexColors.navy : Colors.transparent,
      ),
    ),
  );
}

/// Selectable option card used for terms and repayment types.
class FlexOptionCard extends StatelessWidget {
  const FlexOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.detail,
    required this.selected,
    required this.onTap,
    this.unselectedColor = Colors.white,
  });
  final String title;
  final String subtitle;
  final String? detail;

  /// White on the light page; light blue on white sheets.
  final Color unselectedColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: Pressable(
        semanticLabel: '$title. $subtitle',
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF5F8FF) : unselectedColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? FlexColors.selectedBorder : unselectedColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: RexTypography.host(
                        15,
                        weight: FontWeight.w600,
                        color: RexColors.textStrong,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: RexTypography.host(
                        12,
                        weight: FontWeight.w500,
                        color: FlexColors.label,
                      ),
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        detail!,
                        style: RexTypography.host(
                          12,
                          weight: FontWeight.w500,
                          color: FlexColors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FlexRadio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class FlexIconBubble extends StatelessWidget {
  const FlexIconBubble({
    super.key,
    required this.icon,
    required this.bg,
    required this.fg,
    this.size = 36,
  });
  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
    child: Icon(icon, size: size * 0.5, color: fg),
  );
}

class FlexPill extends StatelessWidget {
  const FlexPill(this.text, {super.key, required this.fg, required this.bg});
  final String text;
  final Color fg;
  final Color bg;

  factory FlexPill.successful() => const FlexPill(
    'Successful',
    fg: FlexColors.green,
    bg: FlexColors.greenBg,
  );
  factory FlexPill.forStatus(LoanStatus s) => switch (s) {
    LoanStatus.pending => const FlexPill(
      'Pending',
      fg: FlexColors.purple,
      bg: FlexColors.purpleBg,
    ),
    LoanStatus.active => const FlexPill(
      'Active',
      fg: RexColors.navy,
      bg: FlexColors.secondaryBg,
    ),
    LoanStatus.settled => const FlexPill(
      'Settled',
      fg: FlexColors.green,
      bg: FlexColors.greenBg,
    ),
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: RexTypography.host(10, weight: FontWeight.w600, color: fg),
    ),
  );
}

/// "Loan Disbursement  + ₦3,000.00  Successful" row.
class FlexTxnTile extends StatelessWidget {
  const FlexTxnTile(this.txn, {super.key});
  final LoanTxn txn;

  @override
  Widget build(BuildContext context) {
    final credit = txn.isCredit;
    return FlexCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          FlexIconBubble(
            icon: credit
                ? Icons.arrow_downward_rounded
                : Icons.arrow_outward_rounded,
            bg: credit ? FlexColors.purpleBg : FlexColors.greenBg,
            fg: credit ? FlexColors.purple : FlexColors.green,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.title,
                  style: RexTypography.host(
                    13,
                    weight: FontWeight.w500,
                    color: RexColors.textStrong,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  RexDates.dateTime(txn.at),
                  style: RexTypography.host(
                    10,
                    weight: FontWeight.w500,
                    color: FlexColors.label,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${credit ? '+' : '-'} ${Naira.grouped(txn.amountKobo)}',
                style: RexTypography.host(
                  13,
                  weight: FontWeight.w600,
                  color: RexColors.textStrong,
                ),
              ),
              const SizedBox(height: 4),
              FlexPill.successful(),
            ],
          ),
        ],
      ),
    );
  }
}

/// Icon + title + subtitle + chevron (Support & Information rows).
class FlexMenuRow extends StatelessWidget {
  const FlexMenuRow({
    super.key,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color bg;
  final Color fg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    semanticLabel: title,
    onTap: onTap,
    child: FlexCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          FlexIconBubble(icon: icon, bg: bg, fg: fg, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: RexTypography.host(
                    13,
                    weight: FontWeight.w500,
                    color: RexColors.textStrong,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: RexTypography.host(
                    11,
                    weight: FontWeight.w500,
                    color: FlexColors.label,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: RexColors.textStrong,
          ),
        ],
      ),
    ),
  );
}

class FlexSectionHeader extends StatelessWidget {
  const FlexSectionHeader(this.title, {super.key, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: RexTypography.host(
                15,
                weight: FontWeight.w600,
                color: RexColors.textStrong,
              ),
            ),
          ),
        ),
        if (onSeeAll != null)
          Pressable(
            semanticLabel: 'See all $title',
            onTap: onSeeAll!,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(
                    'See All',
                    style: RexTypography.host(
                      12,
                      weight: FontWeight.w600,
                      color: FlexColors.navy,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: FlexColors.navy,
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

/// Segmented tabs ("All / Pending / Settled").
class FlexTabs extends StatelessWidget {
  const FlexTabs({
    super.key,
    required this.tabs,
    required this.index,
    required this.onChanged,
  });
  final List<String> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => FlexCard(
    padding: const EdgeInsets.all(4),
    child: Row(
      children: [
        for (var i = 0; i < tabs.length; i++)
          Expanded(
            child: Semantics(
              selected: i == index,
              child: Pressable(
                semanticLabel: '${tabs[i]} tab',
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? FlexColors.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tabs[i],
                    style: RexTypography.host(
                      12,
                      weight: FontWeight.w500,
                      color: i == index ? Colors.white : FlexColors.label,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Green check with halo + title + subtitle (success sheets).
class FlexSuccessHeader extends StatelessWidget {
  const FlexSuccessHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const ExcludeSemantics(
        // 189 px export: 64 pt keeps it at 3× density (sharp).
        child: Image(image: AssetImage(AtlasAssets.successBadge), width: 64),
      ),
      const SizedBox(height: 14),
      Semantics(
        header: true,
        liveRegion: true,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: RexTypography.host(
            18,
            weight: FontWeight.w700,
            color: RexColors.textStrong,
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        textAlign: TextAlign.center,
        style: RexTypography.host(13, color: FlexColors.navy),
      ),
    ],
  );
}

/// Small honest label shown on simulated results.
class FlexDemoLabel extends StatelessWidget {
  const FlexDemoLabel({super.key, this.text});
  final String? text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Text(
      text ?? 'Demo data · simulated, no real money moved',
      textAlign: TextAlign.center,
      style: RexTypography.host(
        11,
        weight: FontWeight.w500,
        color: FlexColors.label,
      ),
    ),
  );
}

/// White bottom sheet with an optional title row and close button.
class FlexSheet extends StatelessWidget {
  const FlexSheet({
    super.key,
    this.title,
    required this.child,
    this.onClose,
    this.showClose = true,
  });
  final String? title;
  final Widget child;
  final VoidCallback? onClose;
  final bool showClose;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final close = Pressable(
      key: const Key('flex-sheet-close'),
      semanticLabel: 'Close',
      onTap: onClose ?? () => Navigator.of(context).maybePop(),
      child: const SizedBox(
        width: 40,
        height: 40,
        child: Icon(Icons.close_rounded, size: 22, color: FlexColors.navy),
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.only(bottom: pad.bottom > 0 ? 0 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            title!,
                            style: RexTypography.host(
                              16,
                              weight: FontWeight.w700,
                              color: RexColors.textStrong,
                            ),
                          ),
                        ),
                      ),
                      if (showClose) close,
                    ],
                  ),
                ),
                const Divider(height: 1, color: RexColors.divider),
              ] else if (showClose)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 8, 0),
                    child: close,
                  ),
                ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> showFlexSheet<T>(
  BuildContext context,
  WidgetBuilder builder, {
  bool dismissible = true,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  isDismissible: dismissible,
  enableDrag: dismissible,
  backgroundColor: Colors.transparent,
  barrierColor: const Color(0x99141A2E),
  builder: builder,
);
