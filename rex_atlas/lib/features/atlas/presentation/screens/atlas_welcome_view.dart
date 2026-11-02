import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/formatting/naira.dart';
import '../../../../core/widgets/pressable.dart';
import '../../application/atlas_controller.dart';
import '../../domain/models/models.dart';
import '../widgets/atlas_brand.dart';
import '../widgets/atlas_composer.dart';
import '../widgets/atlas_header.dart';

/// Frame 2: the collapsed Atlas sheet shown when Atlas opens.
class AtlasWelcomeView extends StatelessWidget {
  const AtlasWelcomeView({
    super.key,
    required this.controller,
    required this.onAttach,
    required this.onVoice,
    required this.onComposerFocus,
    this.now,
  });

  final AtlasController controller;
  final VoidCallback onAttach;
  final VoidCallback onVoice;
  final VoidCallback onComposerFocus;

  /// Injectable clock for tests/screenshots.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final bottom = math.max(
      RexDimens.composerBottomInset,
      MediaQuery.viewInsetsOf(context).bottom + 12,
    );
    return DecoratedBox(
      decoration: const _WelcomeBackground(),
      child: Column(
        children: [
          const SizedBox(height: RexDimens.sheetHandleTop),
          const SheetHandle(color: RexColors.welcomeHandle),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(top: 29),
              child: _WelcomeContent(
                controller: controller,
                now: now ?? DateTime.now(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              RexDimens.composerHorizontalInset,
              12,
              RexDimens.composerHorizontalInset,
              bottom,
            ),
            child: AtlasComposer(
              tone: ComposerTone.onDark,
              enabled: !controller.isBusy,
              onSend: controller.send,
              onAttach: onAttach,
              onVoice: onVoice,
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
    final latest = controller.latestTransfer;
    return Column(
      children: [
        const AtlasBotAvatar(size: 103),
        const SizedBox(height: 12),
        Text(RexDates.greeting(now), style: RexTypography.welcomeGreeting),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$name!', style: RexTypography.welcomeGreeting),
            const SizedBox(width: 6),
            // Figma uses an emoji image ("Emoji", 22.7pt); the system emoji
            // font renders the same glyph.
            const Text('👋', style: TextStyle(fontSize: 21, height: 1.2)),
          ],
        ),
        const SizedBox(height: 10),
        Text('How can I help you today?', style: RexTypography.welcomeSubtitle),
        const SizedBox(height: 21),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 31),
          child: Row(
            children: [
              _QuickAction(
                icon: RexSvg.sendAltFilled,
                color: RexColors.accentMint,
                label: 'Send\nMoney',
                onTap: () => controller.send('Send Money'),
              ),
              const SizedBox(width: 7),
              _QuickAction(
                icon: RexSvg.piggyBank,
                color: RexColors.accentOrange,
                label: 'Save\nMoney',
                onTap: () => controller.send('Save Money'),
              ),
              const SizedBox(width: 7),
              _QuickAction(
                icon: RexSvg.banknotes,
                color: RexColors.accentCyan,
                label: 'Pay\nBills',
                onTap: () => controller.send('Pay Bills'),
              ),
              const SizedBox(width: 7),
              _QuickAction(
                icon: RexSvg.phoneCall,
                color: RexColors.accentMint,
                label: 'Buy\nAirtime',
                onTap: () => controller.send('Buy Airtime'),
              ),
            ],
          ),
        ),
        if (latest != null) ...[
          const SizedBox(height: 45),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recent Transactions',
                        style: RexTypography.welcomeSection,
                      ),
                    ),
                    Pressable(
                      semanticLabel: 'See all transactions',
                      onTap: () =>
                          controller.send('Show my recent transactions'),
                      child: Text(
                        'See All',
                        style: RexTypography.welcomeSection,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                _RecentTransferCard(
                  record: latest,
                  onTap: () => controller.viewReceipt(latest.reference),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final RexSvg icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Pressable(
        semanticLabel: label.replaceAll('\n', ' '),
        onTap: onTap,
        child: Container(
          height: 109,
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
                child: RexSvgIcon(icon, size: 21, color: color),
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

class _RecentTransferCard extends StatelessWidget {
  const _RecentTransferCard({required this.record, required this.onTap});

  final TransactionRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      semanticLabel:
          'Transfer to ${record.counterpartyName}, ${Naira.plain(record.amountKobo)}',
      onTap: onTap,
      child: SizedBox(
        height: 78,
        child: Stack(
          children: [
            // Second, offset layer behind the card (Figma "Frame 2147235114").
            Positioned(
              left: 0,
              right: 0,
              top: 9,
              height: 69,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 69,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 19),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D6B9D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 33,
                      height: 33,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Transform.rotate(
                        angle: 3 * math.pi / 4,
                        child: const RexSvgIcon(
                          RexSvg.arrowLeft,
                          size: 16,
                          color: RexColors.accentMint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.counterpartyName ?? record.title,
                            style: RexTypography.welcomeTxTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            record.counterpartyMasked ?? '',
                            style: RexTypography.welcomeTxMeta,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Naira.plain(record.amountKobo),
                          style: RexTypography.welcomeTxTitle,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          RexDates.welcome(record.timestamp),
                          style: RexTypography.welcomeTxMeta,
                        ),
                      ],
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

/// Navy base with the three blurred glows from Figma (ellipses 1589, 1591,
/// 1592), approximated with radial gradients.
class _WelcomeBackground extends Decoration {
  const _WelcomeBackground();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _WelcomePainter();
}

class _WelcomePainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final size = cfg.size!;
    final rect = offset & size;
    canvas.drawRect(rect, Paint()..color = RexColors.welcomeBase);
    // Positions are relative to the 402 x 631 Figma sheet.
    final sx = size.width / 402;
    void glow(double cx, double cy, double r, double opacity) {
      final c = Offset(rect.left + cx * sx, rect.top + cy);
      canvas.drawCircle(
        c,
        r * sx,
        Paint()
          ..shader = RadialGradient(
            colors: [
              RexColors.welcomeGlow.withValues(alpha: opacity),
              RexColors.welcomeGlow.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r * sx)),
      );
    }

    glow(-3.5, 160, 190, 0.9); // Ellipse 1589
    glow(325.5, 45, 200, 0.95); // Ellipse 1591
    glow(206, size.height - 5, 260, 1.0); // Ellipse 1592
  }
}
