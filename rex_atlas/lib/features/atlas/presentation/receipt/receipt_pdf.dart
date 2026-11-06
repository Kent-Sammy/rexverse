import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/formatting/naira.dart';
import '../../domain/models/models.dart';
import '../widgets/atlas_brand.dart';

/// File name used for both the image and the PDF, e.g.
/// `Rex-Receipt-7065142730002`.
String receiptFileStem(Receipt r) => 'Rex-Receipt-${r.reference}';

/// The "Share Receipt" card as a one-page PDF. Simulated receipts are
/// stamped DEMO so a shared copy can't pass as a real bank record.
Future<Uint8List> buildReceiptPdf(
  Receipt receipt, {
  PdfPageFormat format = PdfPageFormat.a5,
  bool compress = true,
}) async {
  Future<pw.Font> font(String file) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/$file'));
  final regular = await font('Inter-Regular.ttf');
  final medium = await font('Inter-Medium.ttf');
  final bold = await font('Inter-Bold.ttf');
  final mark = await rootBundle.loadString(AtlasAssets.mark);

  const navy = PdfColor.fromInt(0xFF002D93);
  const ink = PdfColor.fromInt(0xFF1B1B1B);
  const label = PdfColor.fromInt(0xFF6B6B6B);
  const line = PdfColor.fromInt(0xFFDADADA);
  const amber = PdfColor.fromInt(0xFFFFF1DC);
  const amberText = PdfColor.fromInt(0xFF5B4A1F);

  final (statusText, statusColor) = switch (receipt.status) {
    TransactionStatus.successful => (
      'Successful',
      const PdfColor.fromInt(0xFF008000),
    ),
    TransactionStatus.pending => (
      'Pending',
      const PdfColor.fromInt(0xFFA66600),
    ),
    TransactionStatus.failed => ('Failed', const PdfColor.fromInt(0xFFD92D20)),
  };

  pw.TextStyle st(double size, pw.Font f, PdfColor c) =>
      pw.TextStyle(font: f, fontSize: size, color: c, lineSpacing: 3);

  final rows = receipt.shareRows.isEmpty ? receipt.rows : receipt.shareRows;

  final doc = pw.Document(
    compress: compress,
    title: 'Rex receipt ${receipt.reference}',
    author: 'Rex',
    subject: receipt.isSimulated ? 'Demo transaction receipt' : 'Receipt',
  );

  doc.addPage(
    pw.Page(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(32),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          if (receipt.isSimulated) ...[
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 8,
              ),
              decoration: const pw.BoxDecoration(
                color: amber,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                'DEMO RECEIPT · simulated by the Rex prototype · '
                'not a real bank record',
                style: st(7.5, medium, amberText),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 18),
          ],
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('re', style: st(26, bold, navy)),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.SvgImage(svg: mark, height: 18),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text('Transaction Receipt', style: st(9, regular, label)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    Naira.grouped(receipt.amountKobo),
                    style: st(17, bold, ink),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(statusText, style: st(9, medium, statusColor)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Divider(
            color: line,
            thickness: 0.8,
            borderStyle: pw.BorderStyle.dashed,
          ),
          pw.SizedBox(height: 10),
          for (final r in rows)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(
                    width: 120,
                    child: pw.Text(r.label, style: st(9, regular, label)),
                  ),
                  pw.Expanded(
                    child: pw.Text(r.value, style: st(9, medium, ink)),
                  ),
                ],
              ),
            ),
          pw.Spacer(),
          pw.Divider(
            color: line,
            thickness: 0.8,
            borderStyle: pw.BorderStyle.dashed,
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            receipt.isSimulated
                ? 'Generated by the Rex Atlas prototype. This receipt shows '
                      'simulated data and is not proof of payment.'
                : 'Thank you for banking with Rex.',
            style: st(7.5, regular, label),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
  );
  return doc.save();
}
