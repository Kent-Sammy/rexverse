import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/widgets/appear.dart';
import '../../../../core/widgets/pressable.dart';
import '../../application/atlas_controller.dart';
import '../widgets/atlas_brand.dart';
import '../widgets/atlas_composer.dart';
import '../widgets/atlas_header.dart';

/// Frame 2: the collapsed Atlas sheet shown when Atlas opens.
class AtlasWelcomeView extends StatelessWidget {
  const AtlasWelcomeView({
    super.key,
    required this.controller,
    required this.onAttach,
    required this.onNotice,
    required this.onComposerFocus,
    this.now,
  });

  final AtlasController controller;
  final VoidCallback onAttach;
  final ValueChanged<String> onNotice;
  final VoidCallback onComposerFocus;

  /// Injectable clock for tests/screenshots.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final bottom = RexDimens.composerBottom(context);
    return _AnimatedWelcomeBackground(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Content starts below the handle (13 + 4 + 29 = 46, as in
                // Figma) and scrolls under it, so the avatar glow is never
                // cut off by a clip edge.
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 46),
                    child: _WelcomeContent(
                      controller: controller,
                      now: now ?? DateTime.now(),
                    ),
                  ),
                ),
                const Positioned(
                  top: RexDimens.sheetHandleTop,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SheetHandle(color: RexColors.welcomeHandle),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            // 24 pt between the last row of tiles and the message bar.
            padding: EdgeInsets.fromLTRB(
              RexDimens.composerHorizontalInset,
              24,
              RexDimens.composerHorizontalInset,
              bottom,
            ),
            child: AtlasComposer(
              tone: ComposerTone.onDark,
              enabled: !controller.isBusy,
              onSend: controller.send,
              onAttach: onAttach,
              speech: controller.deps.speech,
              onNotice: onNotice,
              onFocus: onComposerFocus,
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent({required this.controller, required this.now});

  final AtlasController controller;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final name = controller.account?.firstName ?? '';
    // Short phones get a smaller avatar so both rows of actions stay visible.
    final compact = MediaQuery.sizeOf(context).height < 800;
    final greeting = compact
        ? RexTypography.welcomeGreeting.copyWith(fontSize: 22)
        : RexTypography.welcomeGreeting;
    return Column(
      children: [
        GlowingAtlasAvatar(size: compact ? 64 : 92),
        const SizedBox(height: 12),
        // One line when it fits, wrapping word by word for long names or
        // large text.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 7,
            children: [
              Text(RexDates.greeting(now), style: greeting),
              Text('$name!', style: greeting),
              // Figma uses an emoji image ("Emoji", 22.7pt); the system emoji
              // font renders the same glyph.
              const ExcludeSemantics(
                child: Text('👋', style: TextStyle(fontSize: 21, height: 1.2)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text('How can I help you today?', style: RexTypography.welcomeSubtitle),
        const SizedBox(height: 16),
        _SuggestionCarousel(onSelect: controller.send),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              header: true,
              child: Text(
                'QUICK ACTIONS',
                style: RexTypography.welcomeTile.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _QuickActionChips(onSelect: controller.send),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// One quick action: label shown on the chip, text sent to Atlas, icon.
class _Action {
  const _Action(this.label, this.utterance, this.icon, this.color);
  final String label;
  final String utterance;
  final Widget icon;
  final Color color;
}

const _ink = Color(0xFF0A2A7D);

const _rowOne = [
  _Action(
    'Send Money',
    'Send Money',
    RexSvgIcon(RexSvg.sendAltFilled, size: 16, color: _ink),
    RexColors.accentMint,
  ),
  _Action(
    'Save Money',
    'Save Money',
    RexSvgIcon(RexSvg.piggyBank, size: 16, color: _ink),
    Color(0xFFFFC98A),
  ),
  _Action(
    'Pay Bills',
    'Pay Bills',
    RexSvgIcon(RexSvg.banknotes, size: 16, color: _ink),
    Color(0xFF7FE6F2),
  ),
  _Action(
    'Buy Airtime',
    'Buy Airtime',
    RexSvgIcon(RexSvg.phoneCall, size: 16, color: _ink),
    Color(0xFF8FE3FF),
  ),
];

const _rowTwo = [
  _Action(
    'Fixed Deposit',
    'Save in RexVault',
    RexSvgIcon(RexSvg.briefcase, size: 16, color: _ink),
    Color(0xFFB9A8FF),
  ),
  _Action(
    'Electricity',
    'Pay electricity bill',
    RexSvgIcon(RexSvg.light, size: 17, color: _ink),
    Color(0xFFFFD54F),
  ),
  _Action(
    'Cable TV',
    'Pay cable TV',
    Icon(Icons.tv_rounded, size: 16, color: _ink),
    Color(0xFF8FB6FF),
  ),
  _Action(
    'Get a Loan',
    'Get a RexFlex loan',
    RexSvgIcon(RexSvg.ticket, size: 16, color: _ink),
    Color(0xFF9BE7B4),
  ),
  _Action(
    'Recent Activity',
    'Show my recent transactions',
    Icon(Icons.receipt_long_rounded, size: 16, color: _ink),
    Color(0xFFFFB38A),
  ),
];

/// Two rows of glass pills that scroll sideways together, fading out at the
/// right edge to hint there is more.
class _QuickActionChips extends StatelessWidget {
  const _QuickActionChips({required this.onSelect});
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    Widget row(List<_Action> actions, int offset) => Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Appear(
            delay: Duration(milliseconds: 120 + 60 * (offset + i)),
            offset: 10,
            child: _Chip(action: actions[i], onSelect: onSelect),
          ),
        ],
      ],
    );
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (r) => const LinearGradient(
        stops: [0, 0.86, 1],
        colors: [Colors.white, Colors.white, Color(0x00FFFFFF)],
      ).createShader(r),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row(_rowOne, 0),
            const SizedBox(height: 10),
            row(_rowTwo, 4),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.action, required this.onSelect});
  final _Action action;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      key: Key('welcome-action-${action.label}'),
      semanticLabel: action.label,
      onTap: () => onSelect(action.utterance),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: action.color,
                shape: BoxShape.circle,
              ),
              child: action.icon,
            ),
            const SizedBox(width: 8),
            Text(
              action.label,
              style: RexTypography.welcomeTile.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A product tip shown in the hero card. These never describe past
/// transactions, so they make sense for a first-time user too.
class _Suggestion {
  const _Suggestion({
    required this.title,
    required this.body,
    required this.utterance,
    required this.icon,
    required this.colors,
  });
  final String title;
  final String body;
  final String utterance;
  final Widget icon;
  final List<Color> colors;
}

const _suggestions = [
  _Suggestion(
    title: 'RexVault: earn 22%',
    body: '₦100k grows to ₦122k in a year',
    utterance: 'Save in RexVault',
    icon: RexSvgIcon(RexSvg.briefcase, size: 24, color: Colors.white),
    colors: [Color(0xFF9B7BFF), Color(0xFF5A3EE0)],
  ),
  _Suggestion(
    title: 'RexSave: earn 16%',
    body: 'Flexible savings, withdraw any time',
    utterance: 'Save Money',
    icon: RexSvgIcon(RexSvg.piggyBank, size: 24, color: Colors.white),
    colors: [Color(0xFFFFB15C), Color(0xFFE0670F)],
  ),
  _Suggestion(
    title: 'RexFlex: borrow up to ₦3k',
    body: 'Just say “Borrow me 2k”',
    utterance: 'Borrow me 2k',
    icon: RexSvgIcon(RexSvg.ticket, size: 24, color: Colors.white),
    colors: [Color(0xFF2AD49A), Color(0xFF0F8F6B)],
  ),
  _Suggestion(
    title: 'Electricity in seconds',
    body: 'Get your meter token right in chat',
    utterance: 'Pay electricity bill',
    icon: RexSvgIcon(RexSvg.light, size: 26, color: Colors.white),
    colors: [Color(0xFFFFC233), Color(0xFFD98A00)],
  ),
];

/// Swipeable hero card that gently advances every few seconds (paused when
/// the user asks for reduced motion) with page dots underneath.
class _SuggestionCarousel extends StatefulWidget {
  const _SuggestionCarousel({required this.onSelect});
  final ValueChanged<String> onSelect;

  @override
  State<_SuggestionCarousel> createState() => _SuggestionCarouselState();
}

class _SuggestionCarouselState extends State<_SuggestionCarousel> {
  final _pages = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _timer?.cancel();
    _timer = reduce
        ? null
        : Timer.periodic(const Duration(seconds: 5), (_) {
            if (!_pages.hasClients) return;
            _pages.animateToPage(
              (_index + 1) % _suggestions.length,
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeInOutCubic,
            );
          });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = math.max(1.0, MediaQuery.textScalerOf(context).scale(1));
    return Column(
      children: [
        SizedBox(
          height: 98 * scale,
          child: PageView.builder(
            controller: _pages,
            itemCount: _suggestions.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HeroCard(
                suggestion: _suggestions[i],
                onTap: () => widget.onSelect(_suggestions[i].utterance),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ExcludeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _suggestions.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: i == _index ? 1 : 0.4,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.suggestion, required this.onTap});
  final _Suggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = suggestion;
    return Pressable(
      key: Key('welcome-hero-${s.utterance}'),
      semanticLabel: '${s.title}. ${s.body}',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.26),
              Colors.white.withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000A3C),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: s.colors,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: s.icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUGGESTED FOR YOU',
                    style: RexTypography.welcomeTile.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RexTypography.welcomeTile.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RexTypography.welcomeTile.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: Color(0xFF2F3FE0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navy base with the three blurred glows from Figma (ellipses 1589, 1591,
/// 1592), drawn as radial gradients that drift slowly around their Figma
/// positions so the sheet feels alive.
class _AnimatedWelcomeBackground extends StatefulWidget {
  const _AnimatedWelcomeBackground({required this.child});
  final Widget child;

  @override
  State<_AnimatedWelcomeBackground> createState() =>
      _AnimatedWelcomeBackgroundState();
}

class _AnimatedWelcomeBackgroundState extends State<_AnimatedWelcomeBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _respectReducedMotion(context, _c);
    return CustomPaint(painter: _WelcomePainter(_c), child: widget.child);
  }
}

class _WelcomePainter extends CustomPainter {
  _WelcomePainter(this.t) : super(repaint: t);
  final Animation<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = RexColors.welcomeBase);
    // Positions are relative to the 402 x 631 Figma sheet.
    final sx = size.width / 402;
    final a = t.value * 2 * math.pi;
    void glow(
      double cx,
      double cy,
      double r,
      double opacity,
      double phase,
      double ampX,
      double ampY,
    ) {
      final c = Offset(
        (cx + math.sin(a + phase) * ampX) * sx,
        cy + math.cos(a * 1 + phase * 1.3) * ampY,
      );
      final radius = r * sx * (1 + 0.06 * math.sin(a * 2 + phase));
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              RexColors.welcomeGlow.withValues(alpha: opacity),
              RexColors.welcomeGlow.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: radius)),
      );
    }

    glow(-3.5, 160, 190, 0.9, 0, 26, 30); // Ellipse 1589
    glow(325.5, 45, 200, 0.95, 2.1, 30, 22); // Ellipse 1591
    glow(206, size.height - 5, 260, 1.0, 4.2, 40, 14); // Ellipse 1592
  }

  @override
  bool shouldRepaint(_WelcomePainter old) => false;
}

/// Welcome avatar with a soft, breathing cyan→purple glow that slowly
/// rotates around it (echoing the avatar's gradient ring).
class GlowingAtlasAvatar extends StatefulWidget {
  const GlowingAtlasAvatar({super.key, required this.size});
  final double size;

  @override
  State<GlowingAtlasAvatar> createState() => _GlowingAtlasAvatarState();
}

class _GlowingAtlasAvatarState extends State<GlowingAtlasAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _respectReducedMotion(context, _c);
    final s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            left: -s * 0.35,
            top: -s * 0.35,
            right: -s * 0.35,
            bottom: -s * 0.35,
            child: IgnorePointer(child: CustomPaint(painter: _GlowPainter(_c))),
          ),
          AtlasBotAvatar(size: s, onBlue: false),
        ],
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter(this.t) : super(repaint: t);
  final Animation<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    final a = t.value * 2 * math.pi;
    final center = size.center(Offset.zero);
    final base = size.shortestSide / 2 / 1.7; // avatar radius
    final breathe = 0.5 + 0.5 * math.sin(a * 2); // two breaths per turn
    Shader sweep(double r) => SweepGradient(
      transform: GradientRotation(a),
      colors: const [
        RexColors.ringCyan,
        RexColors.ringPurple,
        Color(0xFF4D6BFF),
        RexColors.ringCyan,
      ],
    ).createShader(Rect.fromCircle(center: center, radius: r));

    // Wide soft halo that breathes.
    final haloR = base * (1.18 + 0.12 * breathe);
    canvas.drawCircle(
      center,
      haloR,
      Paint()
        ..shader = sweep(haloR)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          base * (0.32 + 0.14 * breathe),
        )
        ..color = Colors.white.withValues(alpha: 0.75 + 0.25 * breathe),
    );
    // Bright rotating rim hugging the avatar ring.
    final rimR = base + 2;
    canvas.drawCircle(
      center,
      rimR,
      Paint()
        ..shader = sweep(rimR)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => false;
}

/// WCAG 2.2.2 / OS "reduce motion": decorative loops stop when the user has
/// asked for fewer animations.
void _respectReducedMotion(BuildContext context, AnimationController c) {
  final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  if (reduce && c.isAnimating) {
    c.stop();
  } else if (!reduce && !c.isAnimating) {
    c.repeat();
  }
}
