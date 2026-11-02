import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/models/models.dart';

/// "Transaction Details" panel (frame 6). Rows come from a [Receipt] so the
/// result card and the receipt screen render identical data.
class TransactionDetailsPanel extends StatelessWidget {
  const TransactionDetailsPanel({
    super.key,
    required this.rows,
    this.scale = 1,
    this.onCopied,
  });

  final List<ReceiptRow> rows;

  /// 1.0 matches the in-chat card; the receipt screen uses a larger scale.
  final double scale;
  final ValueChanged<String>? onCopied;

  @override
  Widget build(BuildContext context) {
    TextStyle s(TextStyle t) => t.copyWith(fontSize: t.fontSize! * scale);
    return Container(
      padding: EdgeInsets.fromLTRB(
        13 * scale,
        18 * scale,
        13 * scale,
        18 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: RexColors.hairline),
        borderRadius: BorderRadius.circular(RexDimens.innerCardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Transaction Details', style: s(RexTypography.detailTitle)),
          SizedBox(height: 11 * scale),
          const _DashedLine(),
          SizedBox(height: 11 * scale),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: 10.5 * scale),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 92 * scale,
                  child: Text(
                    rows[i].label,
                    style: s(RexTypography.detailLabel),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          rows[i].value,
                          style: s(RexTypography.detailValue),
                        ),
                      ),
                      if (rows[i].copyable) ...[
                        SizedBox(width: 3 * scale),
                        Pressable(
                          semanticLabel: 'Copy ${rows[i].label}',
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: rows[i].value),
                            );
                            onCopied?.call(rows[i].label);
                          },
                          child: RexSvgIcon(RexSvg.copy, size: 9.6 * scale),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const dash = 3.0, gap = 2.0;
        final n = (c.maxWidth / (dash + gap)).floor();
        return Row(
          children: List.generate(
            n,
            (_) => Container(
              width: dash,
              height: 1,
              margin: const EdgeInsets.only(right: gap),
              color: const Color(0xFFDADADA),
            ),
          ),
        );
      },
    );
  }
}
