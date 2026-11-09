import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/widgets/pressable.dart';
import '../../atlas/presentation/widgets/atlas_brand.dart';

/// Artwork for the home dashboard (Figma node 25371:78681).
abstract final class HomeAssets {
  static const bannerRexyDecember =
      'assets/images/home/banner_rexy_december.png';
  static const bannerDangoteInvest =
      'assets/images/home/banner_dangote_invest.png';
  static const bannerDangoteShare =
      'assets/images/home/banner_dangote_share.png';
  static const bannerRexPlay = 'assets/images/home/banner_rexplay.png';
  static const coin = 'assets/images/home/rex_coin.png';
  static const bag = 'assets/images/home/rexshop_bag.png';
}

// ---------------------------------------------------------------------------
// RexPlay strip
// ---------------------------------------------------------------------------

/// Green "RexPlay... Play. Learn. Earn  Play Now!!!" strip under the
/// status bar.
class RexPlayStrip extends StatelessWidget {
  const RexPlayStrip({super.key, required this.onTap});
  final VoidCallback onTap;

  static const _green = Color(0xFF0B7A35);

  @override
  Widget build(BuildContext context) {
    final italic = RexTypography.host(
      12,
      weight: FontWeight.w600,
      color: _green,
    ).copyWith(fontStyle: FontStyle.italic);
    return Pressable(
      key: const Key('home-rexplay'),
      semanticLabel: 'RexPlay. Play, learn and earn. Play now',
      onTap: onTap,
      pressedScale: 1,
      child: Container(
        height: 28,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFA8EFBF),
              Color(0xFFC4FAD4),
              Color(0xFFC4FAD4),
              Color(0xFFA8EFBF),
            ],
            stops: [0, 0.2, 0.8, 1],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const RexSvgIcon(RexSvg.gamepad, size: 22),
            const SizedBox(width: 12),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'RexPlay... Play. Learn. Earn   '),
                      TextSpan(
                        text: 'Play Now!!!',
                        style: italic.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: _green,
                        ),
                      ),
                    ],
                  ),
                  style: italic,
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const RexSvgIcon(RexSvg.gamepad, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Rex coins balance pill in the header.
class CoinPill extends StatelessWidget {
  const CoinPill({super.key, required this.coins, required this.onTap});
  final int coins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      key: const Key('home-coins'),
      semanticLabel: '$coins Rex coins',
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 8, right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              HomeAssets.coin,
              width: 22,
              height: 22,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: 8),
            Text(
              '$coins',
              style: RexTypography.host(14, color: RexColors.navy),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dots
// ---------------------------------------------------------------------------

/// Page dots: the active page is a short pill.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Slide ${index + 1} of $count',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: i == index ? 10 : 4,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFA9B4F2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Auto-advance
// ---------------------------------------------------------------------------

/// Moves a looping [PageView] on every few seconds. Pauses while the user
/// swipes, and stays still when the system asks for reduced motion.
mixin _AutoAdvance<T extends StatefulWidget> on State<T> {
  final pages = PageController(initialPage: _loopStart);
  Timer? _timer;

  /// Start far from page 0 so the loop works in both directions.
  static const _loopStart = 3000;
  static const interval = Duration(seconds: 4);

  int get pageCount;

  int pageOf(int raw) => (raw - _loopStart) % pageCount;

  void _restart() {
    _timer?.cancel();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    _timer = Timer.periodic(interval, (_) {
      if (!mounted || !pages.hasClients) return;
      pages.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restart();
  }

  /// Wrap the PageView so a swipe resets the timer.
  Widget autoAdvance(Widget child) => NotificationListener<ScrollNotification>(
    onNotification: (n) {
      if (n is ScrollStartNotification && n.dragDetails != null) {
        _timer?.cancel();
      } else if (n is ScrollEndNotification) {
        _restart();
      }
      return false;
    },
    child: child,
  );

  @override
  void dispose() {
    _timer?.cancel();
    pages.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Promo carousel (stacked cards)
// ---------------------------------------------------------------------------

class _Promo {
  const _Promo({
    required this.image,
    required this.label,
    required this.peek,
    required this.onTap,
  });

  /// The full banner as designed (text and button are part of the image).
  final String image;

  /// What a screen reader announces for the banner.
  final String label;

  /// Colour of this banner's edge when it peeks out behind the front card.
  final Gradient peek;
  final VoidCallback onTap;
}

/// Swipeable banners stacked like cards, with page dots. Each banner is the
/// designer's export used as-is; tapping anywhere on it runs its action.
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({
    super.key,
    required this.onRexyDecember,
    required this.onInvest,
    required this.onShare,
    required this.onPlay,
  });

  final VoidCallback onRexyDecember;
  final VoidCallback onInvest;
  final VoidCallback onShare;
  final VoidCallback onPlay;

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel>
    with _AutoAdvance<PromoCarousel> {
  int _index = 0;

  /// The exports are 1041 × 375 (about 3× a 347 × 125 banner).
  static const _aspect = 1041 / 375;

  @override
  int get pageCount => _promos.length;

  late final List<_Promo> _promos = [
    _Promo(
      image: HomeAssets.bannerRexyDecember,
      label:
          'Rexy December. Save from ₦10,000 and get 5% upfront. Lock for 2 '
          'months and receive 5% of your deposit upfront. Start Saving Now',
      peek: const LinearGradient(
        colors: [Color(0xFFFFE7B8), Color(0xFFF7C66A)],
      ),
      onTap: widget.onRexyDecember,
    ),
    _Promo(
      image: HomeAssets.bannerDangoteInvest,
      label:
          'Dangote Refinery IPO is now live. Invest for yourself, and your '
          'children. Invest Here',
      peek: const LinearGradient(
        colors: [Color(0xFF0B6BE8), Color(0xFF0A2A6B)],
      ),
      onTap: widget.onInvest,
    ),
    _Promo(
      image: HomeAssets.bannerDangoteShare,
      label:
          'Dangote Refinery IPO is now live. Tell your loved ones, so they do '
          'not miss out on the opportunity. Share Here',
      peek: const LinearGradient(
        colors: [Color(0xFFA100FF), Color(0xFF6A00D9)],
      ),
      onTap: widget.onShare,
    ),
    _Promo(
      image: HomeAssets.bannerRexPlay,
      label:
          'RexPlay. Play more. Know more. Challenge yourself with fun quizzes '
          'across different topics. Play Now',
      peek: const LinearGradient(
        colors: [Color(0xFF14A83C), Color(0xFF07702A)],
      ),
      onTap: widget.onPlay,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final height = c.maxWidth / _aspect;
        final next = _promos[(_index + 1) % _promos.length];
        final after = _promos[(_index + 2) % _promos.length];
        Widget peek(Gradient g, double inset, double drop) => Positioned(
          left: inset,
          right: inset,
          top: drop,
          height: height,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              gradient: g,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        return Column(
          children: [
            SizedBox(
              height: height + 16,
              child: Stack(
                children: [
                  peek(after.peek, 22, 16),
                  peek(next.peek, 8, 8),
                  SizedBox(
                    height: height,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: autoAdvance(
                        PageView.builder(
                          key: const Key('home-promos'),
                          controller: pages,
                          onPageChanged: (i) =>
                              setState(() => _index = pageOf(i)),
                          itemBuilder: (context, i) {
                            final p = _promos[pageOf(i)];
                            return Pressable(
                              key: Key('home-banner-${pageOf(i)}'),
                              semanticLabel: p.label,
                              onTap: p.onTap,
                              pressedScale: 0.98,
                              child: Image.asset(
                                p.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: height,
                                filterQuality: FilterQuality.medium,
                                excludeFromSemantics: true,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            PageDots(count: _promos.length, index: _index),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Do more with Rex
// ---------------------------------------------------------------------------

class _MoreSlide {
  const _MoreSlide({
    required this.title,
    required this.body,
    required this.cta,
    required this.art,
  });
  final String title;
  final String body;
  final String cta;
  final Widget art;
}

/// "Do more with Rex" card: one swipeable slide at a time, with dots.
class DoMoreWithRex extends StatefulWidget {
  const DoMoreWithRex({super.key, required this.onAction});
  final ValueChanged<String> onAction;

  @override
  State<DoMoreWithRex> createState() => _DoMoreWithRexState();
}

class _DoMoreWithRexState extends State<DoMoreWithRex>
    with _AutoAdvance<DoMoreWithRex> {
  int _index = 0;

  @override
  int get pageCount => _slides.length;

  static final _slides = [
    _MoreSlide(
      title: 'RexShop',
      body: 'Your favourite stores, now just a tap away.',
      cta: 'Shop Now',
      art: Image.asset(
        HomeAssets.bag,
        fit: BoxFit.fitWidth,
        alignment: Alignment.bottomCenter,
        excludeFromSemantics: true,
      ),
    ),
    _MoreSlide(
      title: 'Detty December',
      body: 'Save small-small now, ball in December.',
      cta: 'Start Goal',
      art: Image.asset(
        AtlasAssets.partyPopper,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    ),
    const _MoreSlide(
      title: 'Learn Finance',
      body: 'How to beat lifestyle inflation in your 20s. 6 mins read.',
      cta: 'Read Now',
      art: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 44,
          color: RexColors.iconGreen,
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
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
                  'Do more with Rex',
                  style: RexTypography.host(13, weight: FontWeight.w600),
                ),
              ),
              Pressable(
                semanticLabel: 'See more ways to use Rex',
                onTap: () => widget.onAction('More Rex services'),
                child: Row(
                  children: [
                    Text(
                      'See More',
                      style: RexTypography.host(
                        11,
                        weight: FontWeight.w600,
                        color: RexColors.navy,
                      ),
                    ),
                    const RexSvgIcon(
                      RexSvg.chevron,
                      size: 14,
                      color: RexColors.navy,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 84 * scale,
            child: autoAdvance(
              PageView.builder(
                key: const Key('home-do-more'),
                controller: pages,
                onPageChanged: (i) => setState(() => _index = pageOf(i)),
                itemBuilder: (context, i) {
                  final s = _slides[pageOf(i)];
                  return Pressable(
                    semanticLabel: '${s.title}. ${s.body} ${s.cta}',
                    onTap: () => widget.onAction(s.title),
                    pressedScale: 0.99,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(22, 10, 8, 10),
                              child: _FitColumn(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Text(
                                    s.title,
                                    style: RexTypography.host(
                                      14,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    s.body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: RexTypography.host(
                                      10,
                                      color: RexColors.textTxMeta,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        s.cta,
                                        style: RexTypography.host(
                                          11,
                                          weight: FontWeight.w600,
                                          color: RexColors.primary,
                                        ),
                                      ),
                                      const RexSvgIcon(
                                        RexSvg.chevron,
                                        size: 13,
                                        color: RexColors.primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 92,
                            height: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 18, 6),
                              child: s.art,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: PageDots(count: _slides.length, index: _index),
          ),
        ],
      ),
    );
  }
}

/// A left-aligned column that shrinks to fit its box (large system text on
/// a fixed-height banner) instead of overflowing.
class _FitColumn extends StatelessWidget {
  const _FitColumn({
    required this.children,
    this.alignment = Alignment.topLeft,
  });
  final List<Widget> children;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: SizedBox(
        width: c.maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    ),
  );
}
