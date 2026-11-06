import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';

/// "Report" action on Transaction Details: pick what went wrong.
///
/// Prototype only: nothing is sent anywhere. Resolves to the chosen reason,
/// or null if dismissed.
abstract final class ReportTransactionSheet {
  static const reasons = [
    'Recipient didn’t receive the money',
    'I was debited twice',
    'Wrong amount or recipient',
    'I don’t recognise this transaction',
    'Something else',
  ];

  static Future<String?> show(BuildContext context) =>
      showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const _ReportBody(),
      );
}

class _ReportBody extends StatefulWidget {
  const _ReportBody();

  @override
  State<_ReportBody> createState() => _ReportBodyState();
}

class _ReportBodyState extends State<_ReportBody> {
  String? _reason;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + (bottom > 0 ? 0 : 4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: RexColors.sheetHandle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Report this transaction',
              style: RexTypography.host(18, weight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Tell us what went wrong and we’ll look into it.',
              style: RexTypography.host(13, color: RexColors.textBody),
            ),
            const SizedBox(height: 14),
            for (final r in ReportTransactionSheet.reasons)
              Pressable(
                semanticLabel: r,
                onTap: () => setState(() => _reason = r),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: _reason == r
                        ? RexColors.softBlue
                        : const Color(0xFFF7F8FB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _reason == r
                          ? RexColors.accentBlue
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          r,
                          style: RexTypography.host(
                            14,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        _reason == r
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        size: 20,
                        color: _reason == r
                            ? RexColors.accentBlue
                            : RexColors.textDetailLabel,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Pressable(
              key: const Key('report-submit'),
              semanticLabel: 'Submit report',
              onTap: _reason == null
                  ? null
                  : () => Navigator.of(context).pop(_reason),
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _reason == null
                      ? RexColors.navy.withValues(alpha: 0.35)
                      : RexColors.navy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Submit report',
                  style: RexTypography.host(
                    15,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
