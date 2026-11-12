import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/formatting/naira.dart';
import '../../../core/widgets/pressable.dart';
import '../../atlas/domain/models/models.dart';
import '../../transactions/data/transactions_feed.dart';
import '../../transactions/domain/account_transaction.dart';
import '../../transactions/presentation/all_transactions_screen.dart';

/// "Recent Transactions" on Home (Figma 25461:79708): the latest wallet
/// transaction and a "See All" link to the All Transactions page.
class RecentTransactionsCard extends StatefulWidget {
  const RecentTransactionsCard({
    super.key,
    required this.feed,
    required this.onSeeAll,
    required this.onOpen,
    this.refresh = 0,
  });

  final TransactionsFeed feed;
  final VoidCallback onSeeAll;
  final ValueChanged<AccountTransaction> onOpen;

  /// Bump to reload (e.g. after a payment in Atlas).
  final int refresh;

  @override
  State<RecentTransactionsCard> createState() => _RecentTransactionsCardState();
}

class _RecentTransactionsCardState extends State<RecentTransactionsCard> {
  late Future<List<AccountTransaction>> _load = widget.feed.load();

  @override
  void didUpdateWidget(RecentTransactionsCard old) {
    super.didUpdateWidget(old);
    if (old.refresh != widget.refresh) _load = widget.feed.load();
  }

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    'Recent Transactions',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RexTypography.host(
                      12,
                      weight: FontWeight.w600,
                      color: RexColors.navy,
                    ),
                  ),
                ),
              ),
              Pressable(
                key: const Key('home-transactions'),
                semanticLabel: 'See all transactions',
                onTap: widget.onSeeAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'See All',
                        style: RexTypography.host(
                          12,
                          weight: FontWeight.w500,
                          color: const Color(0xFF3A4D7A),
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
              ),
              const SizedBox(width: 4),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<AccountTransaction>>(
            future: _load,
            builder: (context, snap) {
              final list = snap.data;
              if (list == null) {
                return const SizedBox(
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: RexColors.primary,
                      ),
                    ),
                  ),
                );
              }
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Your transactions will show here.',
                    textAlign: TextAlign.center,
                    style: RexTypography.host(
                      11,
                      weight: FontWeight.w500,
                      color: RexColors.textTxMeta,
                    ),
                  ),
                );
              }
              return _row(list.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _row(AccountTransaction t) {
    final title = t.counterparty != null && t.kind == TxnKind.transfer
        ? 'Transfer - ${t.counterparty}'
        : t.title;
    final (statusText, statusColor) = switch (t.status) {
      TransactionStatus.successful => ('Successful', RexColors.success),
      TransactionStatus.pending => ('Pending', RexColors.warning),
      TransactionStatus.failed => ('Failed', RexColors.error),
    };
    final amount = '${t.isCredit ? '+' : ''}${Naira.fixed(t.amountKobo)}';
    final date = '${_months[t.at.month - 1]} ${t.at.day}, ${t.at.year}';
    return Pressable(
      key: const Key('home-recent-txn'),
      semanticLabel: '$title, $date, $amount, $statusText',
      onTap: () => widget.onOpen(t),
      pressedScale: 0.99,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
        decoration: BoxDecoration(
          color: RexColors.appBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: t.kind == TxnKind.transfer
                  ? const RexSvgIcon(RexSvg.txnTransfer, size: 17)
                  : Icon(
                      txnKindStyle(t.kind).$1,
                      size: 17,
                      color: txnKindStyle(t.kind).$2,
                    ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RexTypography.host(12, weight: FontWeight.w500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RexTypography.host(
                      10,
                      weight: FontWeight.w500,
                      color: RexColors.textTxMeta,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: RexTypography.host(
                    12,
                    weight: FontWeight.w600,
                    color: t.isCredit
                        ? RexColors.success
                        : RexColors.textStrong,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  statusText,
                  style: RexTypography.host(
                    10,
                    weight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
