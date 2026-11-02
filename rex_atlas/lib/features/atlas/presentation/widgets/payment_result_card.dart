import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/naira.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/models/models.dart';
import 'atlas_brand.dart';
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
    final isTransfer = d.kind == PaymentKind.transfer;
    final ok = result.isSuccessful;
    final title = ok
        ? (isTransfer ? 'Transfer Successful!' : 'Airtime Purchase Successful!')
        : (isTransfer ? 'Transfer Failed' : 'Airtime Purchase Failed');
    final repeatLabel = isTransfer
        ? 'Make another transfer'
        : 'Buy more airtime';

    return WashCard(
      padding: const EdgeInsets.fromLTRB(28, 21, 28, 12),
      child: Column(
        children: [
          _StatusBadge(success: ok),
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
                        TextSpan(
                          text: isTransfer
                              ? ' has been sent to ${r.name} at ${r.institution}.'
                              : ' airtime has been sent to ${r.name} (${r.institution}).',
                        ),
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
          const SizedBox(height: 17),
          Row(
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.success});
  final bool success;

  @override
  Widget build(BuildContext context) {
    if (success) {
      // Figma layer "https://lottiefiles.com/95088-success" (62.8 × 59.1).
      return Image.asset(AtlasAssets.successBadge, width: 62.8, height: 59.1);
    }
    // Failure state is not designed; mirrors the success badge's shape.
    final fg = success ? RexColors.successTeal : RexColors.error;
    final halo = success ? RexColors.successHalo : RexColors.errorSoft;
    return Container(
      width: 59,
      height: 59,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: halo, shape: BoxShape.circle),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
        child: Icon(
          success ? Icons.check_rounded : Icons.close_rounded,
          color: Colors.white,
          size: 24,
        ),
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
        height: 29.2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: RexTypography.smallButton.copyWith(color: foreground),
        ),
      ),
    );
  }
}
