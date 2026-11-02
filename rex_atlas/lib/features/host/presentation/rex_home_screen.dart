import 'package:flutter/material.dart';

import '../../../app/demo_device_frame.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/pressable.dart';
import '../../atlas/atlas.dart';
import '../../atlas/presentation/widgets/atlas_brand.dart';

/// Stand-in for the existing Rex home screen (Figma frame 1, 25217:40957).
///
/// It exists only to give Atlas a realistic host context and its two entry
/// points ("Ask RexAtlas....." and the RexAtlas service tile). It is not a
/// reimplementation of the Rex app; other controls show an explanatory notice.
class RexHomeScreen extends StatefulWidget {
  const RexHomeScreen({super.key, required this.atlas, this.now});

  final AtlasController atlas;
  final DateTime? now;

  @override
  State<RexHomeScreen> createState() => _RexHomeScreenState();
}

class _RexHomeScreenState extends State<RexHomeScreen> {
  void _openAtlas() =>
      showRexAtlas(context, controller: widget.atlas, now: widget.now);

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
              // Figma: status bar ends at 41, header starts at 56 (inset 62 - 6).
              SizedBox(height: top > 18 ? top - 6 : 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _Header(
                  onAsk: _openAtlas,
                  onBell: () => _notInPrototype('Notifications'),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  children: [
                    _BalanceCard(onAction: _notInPrototype),
                    const SizedBox(height: 10),
                    _ServicesGrid(
                      onAtlas: _openAtlas,
                      onOther: _notInPrototype,
                    ),
                    const SizedBox(height: 10),
                    _PromoBanner(
                      onTap: () =>
                          _notInPrototype('Capital Market Investments'),
                    ),
                    const SizedBox(height: 10),
                    _SectionCard(
                      title: 'Suggested Savings Plan',
                      onMore: () => _notInPrototype('Savings plans'),
                      child: _SavingsPlan(
                        onTap: () => _notInPrototype('Savings goals'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SectionCard(
                      title: 'Learn Finance',
                      onMore: () => _notInPrototype('Learn Finance'),
                      child: _LearnItem(
                        onTap: () => _notInPrototype('Learn Finance'),
                      ),
                    ),
                  ],
                ),
              ),
              _BottomNav(onTap: _notInPrototype),
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
  const _Header({required this.onAsk, required this.onBell});
  final VoidCallback onAsk;
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
                    Text(
                      'Ask RexAtlas.....',
                      style: RexTypography.host(14, color: RexColors.navy),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
  const _BalanceCard({required this.onAction});
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final white = RexTypography.host(10, color: Colors.white);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
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
            padding: const EdgeInsets.only(top: 20),
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
                    const Icon(
                      Icons.copy_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
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
                  style: white.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _cardButton('Transfer', () => onAction('Transfer')),
                    const SizedBox(width: 8),
                    _cardButton('Add Money', () => onAction('Add Money')),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 38,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: Row(
                children: [
                  const RexSvgIcon(RexSvg.checkCircleOutlined, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Transfer to JIDE KOSOKO ALIU - ',
                          ),
                          TextSpan(
                            text: '₦5000.00',
                            style: RexTypography.host(
                              10,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      style: RexTypography.host(10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('Transactions', style: RexTypography.host(10)),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: RexColors.textStrong,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardButton(String label, VoidCallback onTap) => Pressable(
    semanticLabel: label,
    onTap: onTap,
    child: Container(
      width: 136,
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
  );
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid({required this.onAtlas, required this.onOther});
  final VoidCallback onAtlas;
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
              ),
              gap,
              tile(
                'RexVault',
                RexColors.tileCyan,
                const RexSvgIcon(RexSvg.briefcase, size: 24),
              ),
              gap,
              tile(
                'RexFlex',
                RexColors.tileGreen,
                const RexSvgIcon(RexSvg.ticket, size: 24),
              ),
              gap,
              tile(
                'RexAtlas',
                RexColors.tileBlue,
                const AtlasMark(width: 24, height: 19),
                onTap: onAtlas,
                key: const Key('home-atlas-tile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 95),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 8,
              decoration: const BoxDecoration(
                color: RexColors.bannerBlue,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [RexColors.bannerBlue, Color(0xFF3570B8)],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capital Market Investments',
                            style: RexTypography.host(
                              12,
                              weight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Subscribe to live IPOs and exercise rights issues...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: RexTypography.host(8, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Pressable(
                            semanticLabel: 'Explore Offers',
                            onTap: onTap,
                            child: Container(
                              height: 26,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Explore Offers',
                                style: RexTypography.host(
                                  10,
                                  weight: FontWeight.w600,
                                  color: RexColors.navy,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Coin-stack illustration not exported (see docs/ASSETS.md).
                    const Icon(
                      Icons.trending_up_rounded,
                      size: 48,
                      color: Color(0x99FFFFFF),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.onMore,
    required this.child,
  });
  final String title;
  final VoidCallback onMore;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: RexTypography.host(12, weight: FontWeight.w600),
                ),
              ),
              Pressable(
                semanticLabel: 'See more $title',
                onTap: onMore,
                child: Row(
                  children: [
                    Text(
                      'See More',
                      style: RexTypography.host(
                        10,
                        weight: FontWeight.w600,
                        color: RexColors.navy,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: RexColors.navy,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SavingsPlan extends StatelessWidget {
  const _SavingsPlan({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: RexColors.hairline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detty December',
                  style: RexTypography.host(11, weight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  'Save small-small now, ball in December.',
                  style: RexTypography.host(9, color: RexColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Pressable(
                  semanticLabel: 'Start Goal',
                  onTap: onTap,
                  child: Row(
                    children: [
                      Text(
                        'Start Goal',
                        style: RexTypography.host(
                          10,
                          weight: FontWeight.w600,
                          color: RexColors.primary,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 12,
                        color: RexColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Figma "🎉" illustration (77 × 59), exported by the design owner.
          Image.asset(
            AtlasAssets.partyPopper,
            excludeFromSemantics: true,
            width: 78,
            height: 59,
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _LearnItem extends StatelessWidget {
  const _LearnItem({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      semanticLabel: 'How to beat lifestyle inflation in your 20s',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: RexColors.hairline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 75,
              height: 69,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F5EC),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: RexColors.iconGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDF7E8),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'MINDSET',
                      style: RexTypography.host(
                        7,
                        weight: FontWeight.w600,
                        color: RexColors.iconGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'How to beat lifestyle inflation in your 20s',
                    style: RexTypography.host(11, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '6 mins Read',
                    style: RexTypography.host(
                      9,
                      color: RexColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    // Icons are the Figma exports (active navy, inactive #D2D8E5); labels use
    // the darker navInactive so the text meets WCAG contrast.
    Widget item(RexSvg icon, String label, {bool active = false}) {
      final color = active ? RexColors.navy : RexColors.navInactive;
      return Expanded(
        child: Pressable(
          semanticLabel: label,
          onTap: active ? () {} : () => onTap(label),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RexSvgIcon(icon, size: 24),
              const SizedBox(height: 7),
              Text(
                label,
                style: RexTypography.host(
                  13,
                  weight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(29, 11, 29, bottom > 0 ? bottom - 24 : 10),
      child: Row(
        children: [
          item(RexSvg.navHome, 'Home', active: true),
          item(RexSvg.navSave, 'Save'),
          item(RexSvg.navInvest, 'Invest'),
          item(RexSvg.navBorrow, 'Borrow'),
          item(RexSvg.navMore, 'More'),
        ],
      ),
    );
  }
}
