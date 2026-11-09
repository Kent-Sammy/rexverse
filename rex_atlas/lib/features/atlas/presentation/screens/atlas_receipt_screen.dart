import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/naira.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/models/models.dart';
import '../../domain/services/services.dart';
import '../receipt/receipt_header_bar.dart';
import '../receipt/receipt_sharer.dart';
import '../receipt/report_transaction_sheet.dart';
import '../receipt/rex_logo.dart';
import '../receipt/share_receipt_screen.dart';
import '../widgets/transaction_details_panel.dart';

/// "Transaction Details" frame, opened from "View Receipt" or a transaction
/// row: summary card, the details panel, and Repeat / Share Receipt / Report.
class AtlasReceiptScreen extends StatelessWidget {
  const AtlasReceiptScreen({
    super.key,
    required this.reference,
    required this.receipts,
    this.onRepeat,
    this.sharer = const DeviceReceiptSharer(),
  });

  final String reference;
  final ReceiptService receipts;

  /// Sends the repeat request (e.g. "Send ₦3000 to GTBank …") to Atlas.
  /// The screen closes first. Null hides the action.
  final ValueChanged<String>? onRepeat;
  final ReceiptSharer sharer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RexColors.appBackground,
      body: Column(
        children: [
          const ReceiptHeaderBar(
            title: 'Transaction Details',
            backKey: Key('receipt-back'),
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
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: RexTypography.sheetBody,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return _ReceiptBody(
                  receipt: snap.data!,
                  onRepeat: onRepeat,
                  sharer: sharer,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptBody extends StatelessWidget {
  const _ReceiptBody({
    required this.receipt,
    required this.onRepeat,
    required this.sharer,
  });

  final Receipt receipt;
  final ValueChanged<String>? onRepeat;
  final ReceiptSharer sharer;

  void _notice(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _report(BuildContext context) async {
    final reason = await ReportTransactionSheet.show(context);
    if (reason == null || !context.mounted) return;
    _notice(
      context,
      receipt.isSimulated
          ? 'Demo: report noted, but nothing was sent. In the live app it '
                'goes to Rex support.'
          : 'Report received. Rex support will get back to you.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final (statusCaption, statusText, statusColor) = switch (receipt.status) {
      TransactionStatus.successful => (
        'Transaction Successful',
        'Successful',
        RexColors.success,
      ),
      TransactionStatus.pending => (
        'Transaction Pending',
        'Pending',
        RexColors.warning,
      ),
      TransactionStatus.failed => (
        'Transaction Failed',
        'Failed',
        RexColors.error,
      ),
    };
    final repeat = onRepeat == null ? null : receipt.repeat;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        // Summary card with the Rex badge sitting on its top edge.
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 22),
              padding: const EdgeInsets.fromLTRB(16, 34, 16, 18),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    statusCaption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RexTypography.host(
                      13,
                      weight: FontWeight.w500,
                      color: RexColors.textDetailLabel,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Naira.grouped(receipt.amountKobo),
                    style: RexTypography.host(22, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        receipt.status == TransactionStatus.failed
                            ? Icons.cancel_rounded
                            : receipt.status == TransactionStatus.pending
                            ? Icons.schedule_rounded
                            : Icons.check_circle_rounded,
                        size: 15,
                        color: statusColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RexTypography.host(
                          13,
                          weight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14002766),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const RexLogo(height: 10),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TransactionDetailsPanel(
            rows: receipt.rows,
            scale: 1.18,
            borderless: true,
            onCopied: (label) => _notice(context, '$label copied'),
          ),
        ),
        const SizedBox(height: 12),
        _ActionBar(
          children: [
            if (repeat != null)
              _ActionButton(
                key: const Key('receipt-repeat'),
                icon: Icons.sync_rounded,
                iconColor: RexColors.accentBlue,
                ringed: true,
                label: repeat.label,
                onTap: () {
                  Navigator.of(context).pop();
                  onRepeat!(repeat.utterance);
                },
              ),
            _ActionButton(
              key: const Key('receipt-share'),
              icon: Icons.share_outlined,
              iconColor: RexColors.iconGreen,
              label: 'Share Receipt',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ShareReceiptScreen(receipt: receipt, sharer: sharer),
                ),
              ),
            ),
            _ActionButton(
              key: const Key('receipt-report'),
              icon: Icons.outlined_flag_rounded,
              iconColor: RexColors.error,
              label: 'Report',
              onTap: () => _report(context),
            ),
          ],
        ),
        if (receipt.isSimulated) ...[
          const SizedBox(height: 14),
          Container(
            key: const Key('receipt-demo-banner'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(10),
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
                    'Demo receipt: simulated data from the Rex Atlas '
                    'prototype. Not a real bank record.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: RexTypography.caption.copyWith(
                      color: const Color(0xFF8A5300),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: RexColors.divider,
                  ),
                ),
              Expanded(child: children[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.ringed = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  /// Repeat sits in a thin circle, as in the frame.
  final bool ringed;

  @override
  Widget build(BuildContext context) {
    final glyph = ringed
        ? Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: iconColor, width: 1.4),
            ),
            child: Icon(icon, size: 13, color: iconColor),
          )
        : Icon(icon, size: 20, color: iconColor);
    return Pressable(
      semanticLabel: label,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  glyph,
                  const SizedBox(width: 6),
                  Text(
                    label,
                    maxLines: 1,
                    style: RexTypography.host(
                      12,
                      weight: FontWeight.w600,
                      color: RexColors.textStrong,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
