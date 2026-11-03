import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/dates.dart';
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
    final bottom = math.max(
      RexDimens.composerBottomInset,
      MediaQuery.viewInsetsOf(context).bottom + 12,
    );
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
    return Column(
      children: [
        const GlowingAtlasAvatar(size: 103),
        const SizedBox(height: 12),
        Text(RexDates.greeting(now), style: RexTypography.welcomeGreeting),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$name!', style: RexTypography.welcomeGreeting),
            const SizedBox(width: 6),
            // Figma uses an emoji image ("Emoji", 22.7pt); the system emoji
            // font renders the same glyph.
            const ExcludeSemantics(
              child: Text('👋', style: TextStyle(fontSize: 21, height: 1.2)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('How can I help you today?', style: RexTypography.welcomeSubtitle),
        const SizedBox(height: 21),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 31),
          // Two balanced rows of four quick actions.
          child: Column(
            children: [
              Row(
                children: [
                  _QuickAction(
                    icon: const RexSvgIcon(
                      RexSvg.sendAltFilled,
                      size: 21,
                      color: RexColors.accentMint,
                    ),
                    label: 'Send\nMoney',
                    onTap: () => controller.send('Send Money'),
                  ),
                  const SizedBox(width: 7),
                  _QuickAction(
                    icon: const RexSvgIcon(
                      RexSvg.piggyBank,
                      size: 21,
                      color: RexColors.accentOrange,
                    ),
                    label: 'Save\nMoney',
                    onTap: () => controller.send('Save Money'),
                  ),
                  const SizedBox(width: 7),
                  _QuickAction(
                    icon: const RexSvgIcon(
                      RexSvg.banknotes,
                      size: 21,
                      color: RexColors.accentCyan,
                    ),
                    label: 'Pay\nBills',
                    onTap: () => controller.send('Pay Bills'),
                  ),
                  const SizedBox(width: 7),
                  _QuickAction(
                    icon: const RexSvgIcon(
                      RexSvg.phoneCall,
                      size: 21,
                      color: RexColors.accentMint,
                    ),
                    label: 'Buy\nAirtime',
                    onTap: () => controller.send('Buy Airtime'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _QuickAction(
                    key: const Key('welcome-fixed-deposit'),
                    icon: const RexSvgIcon(
                      RexSvg.briefcase,
                      size: 21,
                      color: Color(0xFFB9A8FF),
                    ),
                    label: 'Fixed\nDeposit',
                    onTap: () => controller.send('Save in RexVault'),
                  ),
                  const SizedBox(width: 7),
                  _QuickAction(
                    icon: const RexSvgIcon(
                      RexSvg.light,
                      size: 22,
                      color: Color(0xFFFFD54F),
                    ),
                    label: 'Electricity',
                    onTap: () => controller.send('Pay electricity bill'),
                  ),
                  const SizedBox(width: 7),
                  _QuickAction(
                    icon: const Icon(
                      Icons.tv_rounded,
                      size: 21,
                      color: Color(0xFF8FB6FF),
                    ),
                    label: 'Cable\nTV',
                    onTap: () => controller.send('Pay cable TV'),
                  ),
                  const SizedBox(width: 7),
                  _QuickAction(
                    icon: const Icon(
                      Icons.receipt_long_rounded,
                      size: 21,
                      color: Color(0xFFFFB38A),
                    ),
                    label: 'Recent\nActivity',
                    onTap: () => controller.send('Show my recent transactions'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Pressable(
        semanticLabel: label.replaceAll('\n', ' '),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 109),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: icon,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: RexTypography.welcomeTile,
              ),
            ],
          ),
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
