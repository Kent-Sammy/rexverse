import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/naira.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/success_badge.dart';
import '../../domain/models/models.dart';
import 'payment_confirmation_card.dart';
import 'payment_parties.dart';
import 'transaction_details_panel.dart';

/// Frame 6 result card ("Transfer Successful!") with receipt actions and the
/// transaction details panel. Also renders the (undesigned) failure state.
class PaymentResultCard extends StatelessWidget {
  const PaymentResultCard({
    super.key,
    required this.result,
    required this.detailRows,
    required this.onViewReceipt,
    required this.onRepeat,
    required this.onCopied,
  });

  final PaymentResult result;
  final List<ReceiptRow> detailRows;
  final VoidCallback onViewReceipt;
  final VoidCallback onRepeat;
  final ValueChanged<String> onCopied;

  @override
  Widget build(BuildContext context) {
    final d = result.draft;
    final r = RecipientInfo.of(d);
    final ok = result.isSuccessful;
    final title = ok ? r.successTitle : r.failureTitle;
    final repeatLabel = r.repeatLabel;
    final token = result.details['Token'];

    return WashCard(
      padding: const EdgeInsets.fromLTRB(16, 21, 16, 14),
      child: Column(
        children: [
          _StatusBadge(success: ok, reference: result.reference),
          const SizedBox(height: 12),
          Text(
            title,
            style: RexTypography.resultTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 236,
            child: ok
                ? Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: Naira.fixed(d.amountKobo),
                          style: RexTypography.resultBody.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: r.successSuffix),
                      ],
                    ),
                    style: RexTypography.resultBody,
                    textAlign: TextAlign.center,
                  )
                : Text(
                    '${result.failureReason ?? 'Something went wrong.'} No money left your account.',
                    style: RexTypography.resultBody,
                    textAlign: TextAlign.center,
                  ),
          ),
          if (ok && token != null) ...[
            const SizedBox(height: 14),
            _TokenBox(
              token: token,
              units: result.details['Units'],
              onCopied: onCopied,
            ),
          ],
          const SizedBox(height: 17),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (ok) ...[
                  Expanded(
                    child: _SmallButton(
                      label: 'View Receipt',
                      background: RexColors.softBlue,
                      foreground: RexColors.navy,
                      onTap: onViewReceipt,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: _SmallButton(
                    label: repeatLabel,
                    background: RexColors.navy,
                    foreground: Colors.white,
                    onTap: onRepeat,
                  ),
                ),
              ],
            ),
          ),
          if (ok) ...[
            const SizedBox(height: 15),
            TransactionDetailsPanel(rows: detailRows, onCopied: onCopied),
          ],
          if (result.isSimulated) ...[
            const SizedBox(height: 10),
            Text(
              'Demo transaction · simulated, not a real bank record',
              style: RexTypography.detailLabel,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatefulWidget {
  const _StatusBadge({required this.success, required this.reference});
  final bool success;

  /// Pops in once per payment, not again when scrolled back into view.
  final String reference;

  static final Set<String> _played = {};

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void initState() {
    super.initState();
    if (_StatusBadge._played.add(widget.reference)) {
      if (widget.success) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
      _c.forward();
    } else {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget badge;
    if (widget.success) {
      // Figma layer "https://lottiefiles.com/95088-success" (62.8 × 59.1),
      // animated: halo, pop, tick draw and confetti.
      badge = const SuccessBadge(size: 62.8);
    } else {
      // Failure state is not designed; mirrors the success badge's shape.
      badge = Container(
        width: 59,
        height: 59,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: RexColors.errorSoft,
          shape: BoxShape.circle,
        ),
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: RexColors.error,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
        ),
      );
    }
    return ScaleTransition(
      scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _c, curve: const Interval(0, 0.35)),
        child: badge,
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      semanticLabel: label,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 34),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(4),
        ),
        // Same text size on both buttons; long labels wrap instead of
        // shrinking.
        child: Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: RexTypography.smallButton.copyWith(color: foreground),
        ),
      ),
    );
  }
}

/// Prepaid electricity token: large, grouped, with a copy button.
class _TokenBox extends StatelessWidget {
  const _TokenBox({required this.token, required this.onCopied, this.units});
  final String token;
  final String? units;
  final ValueChanged<String> onCopied;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Electricity token ${token.replaceAll('-', ' ')}',
      child: Container(
        key: const Key('electricity-token'),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        decoration: BoxDecoration(
          color: RexColors.softBlue,
          borderRadius: BorderRadius.circular(RexDimens.innerCardRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    units == null
                        ? 'Electricity token'
                        : 'Electricity token · $units',
                    style: RexTypography.caption.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      token,
                      style: RexTypography.resultTitle.copyWith(
                        fontSize: 17,
                        letterSpacing: 0.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Pressable(
              key: const Key('copy-token'),
              semanticLabel: 'Copy token',
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: token.replaceAll('-', '')),
                );
                onCopied('Token');
              },
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Center(child: RexSvgIcon(RexSvg.copy, size: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
