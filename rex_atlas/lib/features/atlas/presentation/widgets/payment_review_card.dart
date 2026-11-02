import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/naira.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../domain/models/models.dart';
import 'payment_parties.dart';

/// Frame 3 review card: recipient row + Amount / Transfer Fee / Total Debit.
class PaymentReviewCard extends StatelessWidget {
  const PaymentReviewCard({
    super.key,
    required this.draft,
    this.isActive = true,
  });

  final PaymentDraft draft;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final r = RecipientInfo.of(draft);
    final feeLabel = draft.kind == PaymentKind.transfer
        ? 'Transfer Fee'
        : 'Service Fee';
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isActive ? 1 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: RexColors.softBlue,
          borderRadius: BorderRadius.circular(RexDimens.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(RexDimens.innerCardRadius),
              ),
              child: Row(
                children: [
                  InitialsAvatar(initials: r.initials, size: 35),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          style: RexTypography.cardName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          r.subtitle,
                          style: RexTypography.cardSub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  r.logo,
                ],
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 29),
              child: Align(
                alignment: Alignment.topCenter,
                child: AmountRow(
                  label: 'Amount',
                  value: Naira.plain(draft.amountKobo),
                ),
              ),
            ),
            const CardDivider(color: Colors.white),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 29),
              child: Align(
                alignment: Alignment.topCenter,
                child: AmountRow(
                  label: feeLabel,
                  value: Naira.fixed(draft.feeKobo),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(RexDimens.innerCardRadius),
              ),
              alignment: Alignment.center,
              child: AmountRow(
                label: 'Total Debit',
                value: Naira.fixed(draft.totalKobo),
                isTotal: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
