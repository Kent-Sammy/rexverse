import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/demo_device_frame.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/pressable.dart';
import '../../atlas/atlas.dart';
import '../../atlas/presentation/widgets/atlas_brand.dart';
import '../../rexflex/rexflex.dart';
import '../../transactions/data/transactions_feed.dart';
import '../../transactions/presentation/all_transactions_screen.dart';
import '../../atlas/presentation/screens/atlas_receipt_screen.dart';
import '../../transactions/domain/account_transaction.dart';
import 'home_promos.dart';
import 'recent_transactions_card.dart';

/// Stand-in for the existing Rex home screen (Figma frame 1, 25217:40957).
///
/// It exists only to give Atlas a realistic host context and its two entry
/// points ("Ask RexAtlas....." and the RexAtlas service tile). It is not a
/// reimplementation of the Rex app; other controls show an explanatory notice.
class RexHomeScreen extends StatefulWidget {
  const RexHomeScreen({
    super.key,
    required this.atlas,
    required this.rexflex,
    this.now,
  });

  final AtlasController atlas;
  final RexFlexController rexflex;
  final DateTime? now;

  @override
  State<RexHomeScreen> createState() => _RexHomeScreenState();
}

class _RexHomeScreenState extends State<RexHomeScreen> {
  /// Bumped when the user comes back to Home, so Recent Transactions shows
  /// anything they just did.
  int _txnsVersion = 0;

  void _refreshRecent() {
    if (mounted) setState(() => _txnsVersion++);
  }

  void _openAtlas([String? startWith]) => showRexAtlas(
    context,
    controller: widget.atlas,
    now: widget.now,
    initialMessage: startWith,
  ).then((_) => _refreshRecent());

  void _openRexFlex() =>
      openRexFlex(context, widget.rexflex).then((_) => _refreshRecent());

  /// One feed for the Home card and the All Transactions page.
  late final TransactionsFeed _feed = TransactionsFeed(
    history: widget.atlas.deps.history,
    receipts: widget.atlas.deps.receipts,
    rexflex: widget.rexflex,
    accounts: widget.atlas.deps.accounts,
    clock: widget.now == null ? null : () => widget.now!,
  );

  Future<void> _openReceipt(AccountTransaction t) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => AtlasReceiptScreen(
        reference: t.reference,
        receipts: _feed,
        onRepeat: _openAtlas,
      ),
    ),
  );

  Future<void> _openTransactions() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AllTransactionsScreen(
          feed: _feed,
          onRepeat: _openAtlas,
          onAskAtlas: _openAtlas,
          onOpenRexFlex: _openRexFlex,
        ),
      ),
    );
    _refreshRecent();
  }

  /// "Share Here" on the IPO banner: opens the phone's share sheet.
  Future<void> _shareIpo() => SharePlus.instance.share(
    ShareParams(
      text:
          'Dangote Refinery IPO is now live on Rex. '
          "Don't miss out on the opportunity!",
    ),
  );

  void _notInPrototype(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$what is part of the main Rex app, not this Atlas prototype.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: RexColors.appBackground,
      body: Stack(
        children: [
          Column(
            children: [
              // Figma: status bar ends at 41; the RexPlay strip sits right
              // under it, then the header (inset 62 - 21).
              SizedBox(height: top >= 50 ? top - 21 : top),
              RexPlayStrip(onTap: () => _notInPrototype('RexPlay')),
              const SizedBox(height: 11),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _Header(
                  onAsk: _openAtlas,
                  onCoins: () => _notInPrototype('Rex coins'),
                  onBell: () => _notInPrototype('Notifications'),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          10,
                          20,
                          _BottomNav.heightOf(context) + 12,
                        ),
                        children: [
                          _BalanceCard(
                            onAction: _notInPrototype,
                            onBorrow: _openRexFlex,
                          ),
                          const SizedBox(height: 10),
                          RecentTransactionsCard(
                            feed: _feed,
                            onSeeAll: _openTransactions,
                            onOpen: _openReceipt,
                            refresh: _txnsVersion,
                          ),
                          const SizedBox(height: 10),
                          _ServicesGrid(
                            onAtlas: _openAtlas,
                            onRexFlex: _openRexFlex,
                            onAsk: _openAtlas,
                            onOther: _notInPrototype,
                          ),
                          const SizedBox(height: 10),
                          PromoCarousel(
                            onRexyDecember: () =>
                                _openAtlas('I want to save with Rexy December'),
                            onInvest: () => _notInPrototype('RexInvest'),
                            onShare: _shareIpo,
                            onPlay: () => _notInPrototype('RexPlay'),
                          ),
                          const SizedBox(height: 12),
                          DoMoreWithRex(onAction: _notInPrototype),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _BottomNav(
                        onAtlas: _openAtlas,
                        onTap: _notInPrototype,
                      ),
                    ),
                  ],
                ),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.onAsk,
    required this.onCoins,
    required this.onBell,
  });
  final VoidCallback onAsk;
  final VoidCallback onCoins;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Pressable(
              key: const Key('home-ask-atlas'),
              semanticLabel: 'Ask Rex Atlas',
              onTap: onAsk,
              focusRadius: 20,
              child: Container(
                height: 40,
                padding: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const AtlasMarkBadge(size: 21.7, dark: true),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Ask RexAtlas.....',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RexTypography.host(14, color: RexColors.navy),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          CoinPill(coins: 0, onTap: onCoins),
          const SizedBox(width: 4),
          Pressable(
            semanticLabel: 'Notifications',
            onTap: onBell,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const RexSvgIcon(RexSvg.notification, size: 24),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: InitialsAvatar(
              initials: 'OM',
              size: 24,
              background: const Color(0xFFCFDCFF),
              style: RexTypography.host(
                14,
                weight: FontWeight.w500,
                color: const Color(0xFF274981),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.onAction, required this.onBorrow});
  final ValueChanged<String> onAction;
  final VoidCallback onBorrow;

  @override
  Widget build(BuildContext context) {
    final white = RexTypography.host(10, color: Colors.white);
    return Container(
      constraints: const BoxConstraints(minHeight: 156),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B3A8C),
            RexColors.hostCardBlue,
            Color(0xFF0E3F94),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '11028281921 | Ololade Mr. Money',
                  style: white,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.copy_rounded, size: 12, color: Colors.white),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₦500,563,670.00',
                  style: RexTypography.host(
                    22,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const RexSvgIcon(RexSvg.eye, size: 17),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Book Balance :  ₦500,563,670.00',
            style: white.copyWith(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                _cardButton('Transfer', () => onAction('Transfer')),
                const SizedBox(width: 8),
                _cardButton('Add Money', () => onAction('Add Money')),
                const SizedBox(width: 8),
                _cardButton('Borrow', onBorrow, key: const Key('home-borrow')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardButton(String label, VoidCallback onTap, {Key? key}) => Expanded(
    child: Pressable(
      key: key,
      semanticLabel: label,
      onTap: onTap,
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: RexTypography.host(
            10,
            weight: FontWeight.w600,
            color: RexColors.navy,
          ),
        ),
      ),
    ),
  );
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid({
    required this.onAtlas,
    required this.onRexFlex,
    required this.onAsk,
    required this.onOther,
  });
  final VoidCallback onAtlas;
  final VoidCallback onRexFlex;

  /// Opens Atlas and starts a flow (e.g. "Save Money").
  final ValueChanged<String> onAsk;
  final ValueChanged<String> onOther;

  @override
  Widget build(BuildContext context) {
    Widget tile(
      String label,
      Color bg,
      Widget icon, {
      VoidCallback? onTap,
      Key? key,
    }) => Expanded(
      child: Pressable(
        key: key,
        semanticLabel: label,
        onTap: onTap ?? () => onOther(label),
        child: Container(
          constraints: const BoxConstraints(minHeight: 73),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 26, child: Center(child: icon)),
              const SizedBox(height: 9),
              Text(label, style: RexTypography.host(10)),
            ],
          ),
        ),
      ),
    );
    const gap = SizedBox(width: 8.5);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              tile(
                'Airtime',
                RexColors.tileGreen,
                const Icon(
                  Icons.phone_in_talk_rounded,
                  size: 24,
                  color: RexColors.iconGreen,
                ),
                onTap: () => onAsk('Buy Airtime'),
                key: const Key('home-airtime-tile'),
              ),
              gap,
              tile(
                'Data',
                RexColors.tileBlue,
                const RexSvgIcon(RexSvg.wifiSquare, size: 24),
              ),
              gap,
              tile(
                'Electricity',
                RexColors.tileOrange,
                const RexSvgIcon(RexSvg.light, size: 28),
                onTap: () => onAsk('Pay electricity bill'),
                key: const Key('home-electricity-tile'),
              ),
              gap,
              tile(
                'Budgets',
                RexColors.tileCyan,
                const RexSvgIcon(RexSvg.lightbulbAi, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              tile(
                'RexSave',
                RexColors.tileOrange,
                const RexSvgIcon(RexSvg.wallet, size: 24),
                onTap: () => onAsk('Save Money'),
                key: const Key('home-rexsave-tile'),
              ),
              gap,
              tile(
                'RexVault',
                RexColors.tileCyan,
                const RexSvgIcon(RexSvg.briefcase, size: 24),
                onTap: () => onAsk('Save in RexVault'),
                key: const Key('home-rexvault-tile'),
              ),
              gap,
              tile(
                'RexFlex',
                RexColors.tileGreen,
                const RexSvgIcon(RexSvg.ticket, size: 24),
                onTap: onRexFlex,
                key: const Key('home-rexflex-tile'),
              ),
              gap,
              tile(
                'RexGO',
                RexColors.tileBlue,
                const RexSvgIcon(RexSvg.rexgo, size: 24),
                onTap: () => onOther('RexGO'),
                key: const Key('home-rexgo-tile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.onAtlas, required this.onTap});
  final VoidCallback onAtlas;
  final ValueChanged<String> onTap;

  /// How far the RexAtlas button rises above the bar.
  static const _rise = 18.0;
  static const _ring = 56.0;

  /// Icon, gap and label; grows with the system text size.
  static double _barContent(BuildContext context) =>
      24 + 7 + MediaQuery.textScalerOf(context).scale(12.5) * 1.3 + 2;

  static double _bottomPad(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    // Thin home indicators (≤ 34) keep the Figma spacing; taller system
    // bars (Android three-button nav) push the labels above them.
    // Never less than 10, so thin Android gesture bars (1–33 pt) also work.
    return bottom > 34 ? bottom + 6 : math.max(10.0, bottom - 24);
  }

  /// Total height including the raised button, for padding the content.
  static double heightOf(BuildContext context) =>
      _rise + 11 + _barContent(context) + _bottomPad(context);

  @override
  Widget build(BuildContext context) {
    // Icons are the Figma exports (active navy, inactive #D2D8E5); labels use
    // the darker navInactive so the text meets WCAG contrast.
    Widget label(String text, {bool active = false}) => FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        style: RexTypography.host(
          12.5,
          weight: FontWeight.w600,
          color: active ? RexColors.navy : RexColors.navInactive,
        ),
      ),
    );

    Widget item(RexSvg icon, String text, {bool active = false}) => Expanded(
      child: Pressable(
        key: Key('nav-${text.toLowerCase()}'),
        semanticLabel: text,
        onTap: active ? () {} : () => onTap(text),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RexSvgIcon(icon, size: 24),
            const SizedBox(height: 7),
            label(text, active: active),
          ],
        ),
      ),
    );

    final atlas = Expanded(
      child: Pressable(
        key: const Key('nav-rexatlas'),
        semanticLabel: 'Open RexAtlas',
        onTap: onAtlas,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Space the raised button occupies inside the bar.
            const SizedBox(height: _ring - _rise - 11 + 4),
            label('RexAtlas'),
          ],
        ),
      ),
    );

    return SizedBox(
      height: heightOf(context),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // White bar with a soft shadow cast upwards.
          Positioned.fill(
            top: _rise,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14002766),
                    blurRadius: 24,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            top: _rise,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 11, 8, _bottomPad(context)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  item(RexSvg.navHome, 'Home', active: true),
                  item(RexSvg.navSave, 'RexSave'),
                  atlas,
                  item(RexSvg.navInvest, 'RexInvest'),
                  item(RexSvg.navMore, 'More'),
                ],
              ),
            ),
          ),
          // Raised RexAtlas button: white ring, light-blue halo, navy mark.
          Positioned(
            top: 0,
            child: ExcludeSemantics(
              child: Pressable(
                semanticLabel: 'Open RexAtlas',
                onTap: onAtlas,
                child: Container(
                  width: _ring,
                  height: _ring,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1F002766),
                        blurRadius: 18,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCE7FF),
                      shape: BoxShape.circle,
                    ),
                    child: // Plain navy disc: the export's gradient outline is clipped off.
                    ClipOval(
                      child: SizedBox(
                        width: 27,
                        height: 27,
                        child: OverflowBox(
                          maxWidth: 31,
                          maxHeight: 31,
                          child: SvgPicture.asset(
                            AtlasAssets.badgeDark,
                            width: 31,
                          ),
                        ),
                      ),
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
}
