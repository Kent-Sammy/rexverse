import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/naira.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../domain/models/models.dart';
import 'atlas_brand.dart';
import 'payment_parties.dart';

/// Shared white card with the blue→pink wash used by the confirmation and
/// result cards (Figma ellipses 1592/1593 blurred behind the card).
class WashCard extends StatelessWidget {
  const WashCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RexDimens.cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1E2A5A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RexDimens.cardRadius),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.55],
                    colors: [Colors.white.withValues(alpha: 0), Colors.white],
                  ),
                ),
                position: DecorationPosition.foreground,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        RexColors.washBlue,
                        Color(0xFFF3EEFF),
                        RexColors.washPink,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// Frame 4 confirmation card shown together with the biometric prompt.
class PaymentConfirmationCard extends StatelessWidget {
  const PaymentConfirmationCard({super.key, required this.draft});

  final PaymentDraft draft;

  @override
  Widget build(BuildContext context) {
    final r = RecipientInfo.of(draft);
    final source = switch (draft) {
      TransferDraft(:final source) => source,
      AirtimeDraft(:final source) => source,
    };
    final caption = draft.kind == PaymentKind.transfer
        ? 'Send Money'
        : 'Buy Airtime';
    return WashCard(
      padding: const EdgeInsets.fromLTRB(10, 30, 10, 24),
      child: Column(
        children: [
          Text(caption, style: RexTypography.confirmCaption),
          const SizedBox(height: 5),
          Text(
            Naira.fixed(draft.amountKobo),
            style: RexTypography.confirmAmount,
          ),
          const SizedBox(height: 8),
          Text('to', style: RexTypography.confirmCaption),
          const SizedBox(height: 10),
          Text(
            r.name,
            style: RexTypography.confirmName,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(r.subtitle, style: RexTypography.confirmBank),
              const SizedBox(width: 7),
              r.smallLogo,
            ],
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CardDivider(),
          ),
          Padding(
            // Figma: 10 gap + 72 row (10 inner padding) + 10 gap.
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Row(
                children: [
                  InitialsAvatar(
                    initials: InitialsAvatar.fromName(source.holderName),
                    size: 35,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('from', style: RexTypography.cardSub, maxLines: 1),
                        Text(
                          source.holderName,
                          style: RexTypography.cardName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          source.maskedLabel,
                          style: RexTypography.cardSub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const AtlasMarkBadge(),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CardDivider(),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: RexColors.softBlue,
              borderRadius: BorderRadius.circular(RexDimens.innerCardRadius),
            ),
            // Figma fee box: 89 tall, fee row at +10, total row (40) at +46.
            child: Column(
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  height: 29,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AmountRow(
                      label: draft.kind == PaymentKind.transfer
                          ? 'Transfer Fee'
                          : 'Service Fee',
                      value: Naira.fixed(draft.feeKobo),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                const CardDivider(color: Colors.white),
                const SizedBox(height: 3),
                SizedBox(
                  height: 40,
                  child: AmountRow(
                    label: 'Total Debit',
                    value: Naira.fixed(draft.totalKobo),
                    isTotal: true,
                  ),
                ),
                const SizedBox(height: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
