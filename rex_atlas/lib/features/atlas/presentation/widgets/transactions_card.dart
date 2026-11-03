import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/formatting/naira.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/models/models.dart';

/// Frame 9 recent-transactions list.
class TransactionsCard extends StatelessWidget {
  const TransactionsCard({
    super.key,
    required this.transactions,
    required this.onTap,
  });

  final List<TransactionRecord> transactions;
  final ValueChanged<TransactionRecord> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: RexColors.hairline),
        borderRadius: BorderRadius.circular(RexDimens.cardRadius),
      ),
      child: Column(
        children: [
          for (var i = 0; i < transactions.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 10.5, 8, 10.5),
                child: SizedBox(
                  height: 1,
                  child: ColoredBox(color: RexColors.hairline),
                ),
              ),
            _TransactionRow(
              record: transactions[i],
              onTap: () => onTap(transactions[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.record, required this.onTap});

  final TransactionRecord record;
  final VoidCallback onTap;

  (IconData, Color, Color) get _style => switch (record.category) {
    TransactionCategory.cardPayment => (
      Icons.credit_card_rounded,
      RexColors.historyGreen,
      RexColors.historyGreenBg,
    ),
    TransactionCategory.transfer => (
      Icons.currency_exchange_rounded,
      RexColors.accentBlue,
      RexColors.historyBlueBg,
    ),
    TransactionCategory.airtime => (
      Icons.phone_in_talk_outlined,
      RexColors.accentCyan,
      RexColors.historyCyanBg,
    ),
    TransactionCategory.businessTransfer => (
      Icons.account_balance_outlined,
      RexColors.accentOrange,
      RexColors.historyOrangeBg,
    ),
    TransactionCategory.savings => (
      Icons.savings_rounded,
      RexColors.accentOrange,
      RexColors.historyOrangeBg,
    ),
    TransactionCategory.vault => (
      Icons.lock_rounded,
      RexColors.accentCyan,
      RexColors.historyCyanBg,
    ),
    TransactionCategory.bill => (
      Icons.receipt_long_rounded,
      RexColors.accentBlue,
      RexColors.historyBlueBg,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, fg, bg) = _style;
    final status = switch (record.status) {
      TransactionStatus.successful => ('Successful', RexColors.success),
      TransactionStatus.pending => ('Pending', RexColors.warning),
      TransactionStatus.failed => ('Failed', RexColors.error),
    };
    return Pressable(
      semanticLabel: '${record.title}, ${Naira.plain(record.amountKobo)}',
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 33,
                height: 33,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, size: 17.4, color: fg),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: RexTypography.historyTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (record.channel != null) ...[
                          Flexible(
                            child: Text(
                              record.channel!,
                              style: RexTypography.historyMeta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: const BoxDecoration(
                              color: RexColors.textTxMeta,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        Flexible(
                          child: Text(
                            RexDates.short(record.timestamp),
                            style: RexTypography.historyMeta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Naira.plain(record.amountKobo),
                    style: RexTypography.historyAmount,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    status.$1,
                    style: RexTypography.historyStatus.copyWith(
                      color: status.$2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
