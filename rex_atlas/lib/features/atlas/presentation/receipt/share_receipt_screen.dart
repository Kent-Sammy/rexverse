import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/naira.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/models/models.dart';
import 'receipt_header_bar.dart';
import 'receipt_pdf.dart';
import 'receipt_sharer.dart';
import 'rex_logo.dart';

/// "Share Receipt" frame: a ticket-style receipt and two share actions.
///
/// "Share as image" captures the ticket exactly as shown, "Share as PDF"
/// builds a one-page document. Both carry the DEMO label for simulated data.
class ShareReceiptScreen extends StatefulWidget {
  const ShareReceiptScreen({
    super.key,
    required this.receipt,
    this.sharer = const DeviceReceiptSharer(),
  });

  final Receipt receipt;
  final ReceiptSharer sharer;

  @override
  State<ShareReceiptScreen> createState() => _ShareReceiptScreenState();
}

enum _Format { image, pdf }

class _ShareReceiptScreenState extends State<ShareReceiptScreen> {
  final _ticketKey = GlobalKey();
  _Format? _busy;

  Future<Uint8List> _captureTicket() async {
    final boundary =
        _ticketKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }

  Future<void> _share(_Format f) async {
    if (_busy != null) return;
    setState(() => _busy = f);
    final stem = receiptFileStem(widget.receipt);
    try {
      if (f == _Format.image) {
        await widget.sharer.shareImage(await _captureTicket(), '$stem.png');
      } else {
        await widget.sharer.sharePdf(
          await buildReceiptPdf(widget.receipt),
          '$stem.pdf',
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't share the receipt. Please try again."),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RexColors.appBackground,
      body: Column(
        children: [
          const ReceiptHeaderBar(
            title: 'Share Receipt',
            backKey: Key('share-receipt-back'),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                4,
                16,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                RepaintBoundary(
                  key: _ticketKey,
                  child: ReceiptTicket(receipt: widget.receipt),
                ),
                const SizedBox(height: 14),
                _ShareBar(busy: _busy, onShare: _share),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The receipt itself, with scalloped top and bottom edges.
class ReceiptTicket extends StatelessWidget {
  const ReceiptTicket({super.key, required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    final (statusText, statusColor) = switch (receipt.status) {
      TransactionStatus.successful => ('Successful', RexColors.success),
      TransactionStatus.pending => ('Pending', RexColors.warning),
      TransactionStatus.failed => ('Failed', RexColors.error),
    };
    final rows = receipt.shareRows.isEmpty ? receipt.rows : receipt.shareRows;
    return ClipPath(
      clipper: const _ScallopClipper(),
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const RexLogo(height: 22),
                        const SizedBox(height: 6),
                        Text(
                          'Transaction Receipt',
                          style: RexTypography.host(
                            12,
                            color: RexColors.textDetailLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Naira.grouped(receipt.amountKobo),
                        style: RexTypography.host(
                          18,
                          weight: FontWeight.w700,
                          color: RexColors.textStrong,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _StatusLabel(text: statusText, color: statusColor),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const DashedRule(),
              const SizedBox(height: 18),
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                _TicketRow(row: rows[i]),
              ],
              if (receipt.isSimulated) ...[
                const SizedBox(height: 22),
                const DashedRule(),
                const SizedBox(height: 12),
                Text(
                  'DEMO RECEIPT · simulated by the Rex Atlas prototype. '
                  'Not a real bank record or proof of payment.',
                  key: const Key('share-receipt-demo-note'),
                  textAlign: TextAlign.center,
                  style: RexTypography.host(
                    10.5,
                    weight: FontWeight.w500,
                    color: const Color(0xFF8A5300),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: RexTypography.host(12, weight: FontWeight.w500, color: color),
        ),
      ],
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.row});
  final ReceiptRow row;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 118,
          child: Text(
            row.label,
            style: RexTypography.host(12, color: RexColors.textDetailLabel),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  row.value,
                  style: RexTypography.host(
                    12,
                    weight: FontWeight.w500,
                    color: RexColors.textStrong,
                  ).copyWith(height: 1.5),
                ),
              ),
              if (row.copyable) ...[
                const SizedBox(width: 4),
                Pressable(
                  semanticLabel: 'Copy ${row.label}',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: row.value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${row.label} copied')),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: RexSvgIcon(RexSvg.copy, size: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ShareBar extends StatelessWidget {
  const _ShareBar({required this.busy, required this.onShare});
  final _Format? busy;
  final ValueChanged<_Format> onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ShareButton(
              key: const Key('share-as-image'),
              label: 'Share as image',
              icon: const _FileGlyph(
                icon: Icons.image_rounded,
                color: Color(0xFF16A34A),
                background: Color(0xFFE3F7EA),
              ),
              busy: busy == _Format.image,
              onTap: () => onShare(_Format.image),
            ),
          ),
          Container(width: 1, height: 26, color: RexColors.divider),
          Expanded(
            child: _ShareButton(
              key: const Key('share-as-pdf'),
              label: 'Share as PDF',
              icon: const _FileGlyph(
                icon: Icons.picture_as_pdf_rounded,
                color: Color(0xFFD92D20),
                background: Color(0xFFFDECEA),
              ),
              busy: busy == _Format.pdf,
              onTap: () => onShare(_Format.pdf),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileGlyph extends StatelessWidget {
  const _FileGlyph({
    required this.icon,
    required this.color,
    required this.background,
  });
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: 17, color: color),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    super.key,
    required this.label,
    required this.icon,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      semanticLabel: label,
      onTap: onTap,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            busy
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: RexColors.accentBlue,
                      ),
                    ),
                  )
                : icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RexTypography.host(
                  14,
                  weight: FontWeight.w600,
                  color: RexColors.accentBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dotted divider used on receipts.
class DashedRule extends StatelessWidget {
  const DashedRule({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const dash = 3.0, gap = 3.0;
        final n = (c.maxWidth / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            n,
            (_) => Container(
              width: dash,
              height: 1,
              color: const Color(0xFFD5D9E2),
            ),
          ),
        );
      },
    );
  }
}

/// Paper-receipt edge: a row of small round bites along the top and bottom.
class _ScallopClipper extends CustomClipper<Path> {
  const _ScallopClipper();

  static const _r = 5.0;
  static const _pitch = 16.0;

  @override
  Path getClip(Size size) {
    final n = (size.width / _pitch).floor();
    final step = size.width / n;
    final path = Path()..moveTo(0, 0);
    for (var i = 0; i < n; i++) {
      final cx = step * (i + 0.5);
      path
        ..lineTo(cx - _r, 0)
        ..arcToPoint(
          Offset(cx + _r, 0),
          radius: const Radius.circular(_r),
          clockwise: false,
        );
    }
    path
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height);
    for (var i = n - 1; i >= 0; i--) {
      final cx = step * (i + 0.5);
      path
        ..lineTo(cx + _r, size.height)
        ..arcToPoint(
          Offset(cx - _r, size.height),
          radius: const Radius.circular(_r),
          clockwise: false,
        );
    }
    return path
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
