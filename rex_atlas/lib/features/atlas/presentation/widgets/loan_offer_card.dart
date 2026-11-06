import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/formatting/naira.dart';
import '../../domain/models/models.dart';
import 'payment_parties.dart';

/// RexFlex offer in the chat, styled like the payment review card: a white
/// header (product + tenor), detail rows and a white "Total to repay" bar.
class LoanOfferCard extends StatelessWidget {
  const LoanOfferCard({super.key, required this.offer});
  final LoanOfferMessage offer;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: offer.isActive ? 1 : 0.5,
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
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: RexColors.tileGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const RexSvgIcon(RexSvg.ticket, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RexFlex Loan', style: RexTypography.cardName),
                        Text(
                          '${offer.days}-day loan',
                          style: RexTypography.cardSub,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            DetailRow(
              label: 'Loan amount',
              value: Naira.grouped(offer.principalKobo),
            ),
            DetailRow(
              label: 'Interest',
              value: Naira.grouped(offer.interestKobo),
            ),
            DetailRow(
              label: 'Due date',
              value: RexDates.dayMonthYear(offer.dueDate),
            ),
            const CardDivider(color: Colors.white),
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
                label: 'Total to repay',
                value: Naira.grouped(offer.totalKobo),
                isTotal: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
