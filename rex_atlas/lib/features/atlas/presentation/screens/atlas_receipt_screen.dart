import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/naira.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/models/models.dart';
import '../../domain/services/services.dart';
import '../widgets/transaction_details_panel.dart';

/// Receipt opened from "View Receipt" or a transaction row.
///
/// No Figma frame exists for this screen; it reuses the "Transaction
/// Details" panel and existing tokens (see docs/ASSUMPTIONS.md).
class AtlasReceiptScreen extends StatelessWidget {
  const AtlasReceiptScreen({
    super.key,
    required this.reference,
    required this.receipts,
  });

  final String reference;
  final ReceiptService receipts;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: RexColors.appBackground,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, top + 12, 16, 14),
            child: Row(
              children: [
                Pressable(
                  key: const Key('receipt-back'),
                  semanticLabel: 'Back to Rex Atlas',
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 33,
                    height: 33,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: RexColors.navy,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text('Transaction Receipt', style: RexTypography.headerTitle),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Receipt>(
              future: receipts.receiptFor(reference),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: RexColors.primary),
                  );
                }
                if (snap.hasError || !snap.hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        "We couldn't load this receipt. Please try again later.",
                        style: RexTypography.sheetBody,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return _ReceiptBody(receipt: snap.data!);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptBody extends StatelessWidget {
  const _ReceiptBody({required this.receipt});
  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    final (statusText, statusColor) = switch (receipt.status) {
      TransactionStatus.successful => ('Successful', RexColors.success),
      TransactionStatus.pending => ('Pending', RexColors.accentOrange),
      TransactionStatus.failed => ('Failed', RexColors.error),
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (receipt.isSimulated)
          Container(
            key: const Key('receipt-demo-banner'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD8A8)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: RexColors.accentOrange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'DEMO RECEIPT: simulated data from the Rex Atlas prototype. '
                    'This is not a real bank record.',
                    style: RexTypography.caption.copyWith(
                      color: const Color(0xFF8A5300),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(RexDimens.cardRadius),
          ),
          child: Column(
            children: [
              Text(receipt.title, style: RexTypography.confirmCaption),
              const SizedBox(height: 6),
              Text(
                Naira.grouped(receipt.amountKobo),
                style: RexTypography.confirmAmount,
              ),
              const SizedBox(height: 6),
              Text(
                statusText,
                style: RexTypography.historyStatus.copyWith(
                  fontSize: 13,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 20),
              TransactionDetailsPanel(
                rows: receipt.rows,
                scale: 1.45,
                onCopied: (label) =>
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('$label copied'))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Pressable(
          semanticLabel: 'Done',
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RexColors.navy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Done',
              style: RexTypography.smallButton.copyWith(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
