import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/formatting/dates.dart';
import '../../../../core/formatting/naira.dart';
import '../../domain/rexflex_models.dart';

/// Builds the RexFlex loan agreement as a PDF from the loan's real details.
///
/// The legal wording is prototype copy and every page carries a DEMO
/// watermark and banner: the binding agreement text must come from Rex Legal.
Future<Uint8List> buildLoanAgreementPdf({
  required FlexLoan loan,
  required String borrowerName,
  required String accountLabel,
  PdfPageFormat format = PdfPageFormat.a4,
  bool compress = true,
}) async {
  Future<pw.Font> font(String file) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/$file'));
  final regular = await font('Inter-Regular.ttf');
  final medium = await font('Inter-Medium.ttf');
  final semibold = await font('Inter-SemiBold.ttf');
  final bold = await font('Inter-Bold.ttf');
  final mark = await rootBundle.loadString('assets/images/rex_atlas_mark.svg');

  // Palette, taken from the app.
  const navy = PdfColor.fromInt(0xFF002766);
  const brand = PdfColor.fromInt(0xFF002D93);
  const blue = PdfColor.fromInt(0xFF004ECC);
  const ink = PdfColor.fromInt(0xFF141A2E);
  const body = PdfColor.fromInt(0xFF3D4457);
  const muted = PdfColor.fromInt(0xFF6B7385);
  const hairline = PdfColor.fromInt(0xFFE3E7F0);
  const wash = PdfColor.fromInt(0xFFF4F7FD);
  const onNavyMuted = PdfColor.fromInt(0xFFB9C8EA);
  const green = PdfColor.fromInt(0xFF0E8A4B);
  const greenWash = PdfColor.fromInt(0xFFE6F6EC);
  const amber = PdfColor.fromInt(0xFFFFF3E0);
  const amberText = PdfColor.fromInt(0xFF7A4A00);

  final start = loan.startDate ?? loan.appliedAt;
  final due = loan.dueDate ?? loan.proposedDueDate;
  final accepted = loan.appliedAt;

  pw.TextStyle st(
    double size, {
    pw.Font? f,
    PdfColor color = body,
    double spacing = 0,
    double line = 2.5,
  }) => pw.TextStyle(
    font: f ?? regular,
    fontSize: size,
    color: color,
    letterSpacing: spacing,
    lineSpacing: line,
  );

  pw.Widget eyebrow(String text, {PdfColor color = muted}) => pw.Text(
    text.toUpperCase(),
    style: st(7, f: semibold, color: color, spacing: 1.2),
  );

  pw.Widget logo({double height = 22}) => pw.Row(
    mainAxisSize: pw.MainAxisSize.min,
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Text(
        're',
        style: pw.TextStyle(
          font: bold,
          fontSize: height * 1.25,
          color: brand,
          letterSpacing: -1,
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.only(bottom: height * 0.12),
        child: pw.SvgImage(svg: mark, height: height * 0.86),
      ),
    ],
  );

  // ------------------------------------------------------------------ parts

  pw.Widget summaryCard() {
    pw.Widget stat(String label, String value) => pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: const pw.BoxDecoration(
          color: PdfColor.fromInt(0xFF1C4AA6),
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            eyebrow(label, color: onNavyMuted),
            pw.SizedBox(height: 5),
            pw.Text(
              value,
              style: st(12, f: semibold, color: PdfColors.white),
            ),
          ],
        ),
      ),
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: const pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [navy, blue],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(14)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    eyebrow('Loan amount', color: onNavyMuted),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      Naira.grouped(loan.principalKobo),
                      style: st(28, f: bold, color: PdfColors.white),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF2B5CC0),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(9)),
                ),
                child: pw.Text(
                  '${loan.term.days}-day loan',
                  style: st(9, f: semibold, color: PdfColors.white),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              stat('Interest', Naira.grouped(loan.interestKobo)),
              pw.SizedBox(width: 8),
              stat('Total to repay', Naira.grouped(loan.totalKobo)),
              pw.SizedBox(width: 8),
              stat('Due date', RexDates.dayMonthYear(due)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget party(String role, String name, List<String> lines) => pw.Expanded(
    child: pw.Container(
      height: 74,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: wash,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: hairline, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          eyebrow(role),
          pw.SizedBox(height: 6),
          pw.Text(
            name,
            style: st(11, f: semibold, color: ink),
          ),
          for (final l in lines) ...[
            pw.SizedBox(height: 2),
            pw.Text(l, style: st(8.5, color: muted)),
          ],
        ],
      ),
    ),
  );

  pw.Widget sectionTitle(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 22, bottom: 10),
    child: pw.Row(
      children: [
        pw.Container(
          width: 3,
          height: 12,
          decoration: const pw.BoxDecoration(
            color: blue,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          text,
          style: st(12, f: bold, color: ink),
        ),
      ],
    ),
  );

  final details = <(String, String)>[
    ('Agreement reference', loan.id),
    ('Loan amount (principal)', Naira.grouped(loan.principalKobo)),
    ('Interest', Naira.grouped(loan.interestKobo)),
    ('Total amount repayable', Naira.grouped(loan.totalKobo)),
    ('Loan period', '${loan.term.days} days'),
    ('Disbursement date', RexDates.dayMonthYear(start)),
    ('Due date', RexDates.dayMonthYear(due)),
    ('Repayment account', accountLabel),
  ];

  pw.Widget detailsTable() => pw.Container(
    decoration: pw.BoxDecoration(
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      border: pw.Border.all(color: hairline, width: 0.8),
    ),
    child: pw.Column(
      children: [
        for (var i = 0; i < details.length; i++)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: pw.BoxDecoration(
              color: i.isOdd ? wash : null,
              borderRadius: i == 0
                  ? const pw.BorderRadius.vertical(top: pw.Radius.circular(10))
                  : i == details.length - 1
                  ? const pw.BorderRadius.vertical(
                      bottom: pw.Radius.circular(10),
                    )
                  : null,
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(details[i].$1, style: st(9, color: muted)),
                ),
                pw.Text(
                  details[i].$2,
                  style: st(
                    9,
                    f: i == 3 ? bold : medium,
                    color: i == 3 ? navy : ink,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  final clauses = <(String, String)>[
    (
      'The loan',
      'The Lender agrees to lend the Borrower the principal stated in this '
          'agreement, paid into the Borrower\'s Rex account on the '
          'disbursement date.',
    ),
    (
      'Interest and charges',
      'The Borrower will pay the interest stated in this agreement for the '
          'loan period chosen. The total amount repayable was shown before '
          'the Borrower accepted. No other fees apply to this loan.',
    ),
    (
      'Repayment',
      'The Borrower will repay the total amount repayable on or before the '
          'due date from the Rex account above. The Borrower may repay in '
          'full or in parts at any time before the due date, with no early '
          'repayment charge.',
    ),
    (
      'Late or missed repayment',
      'If the loan is not repaid by the due date, the Lender may contact the '
          'Borrower and apply the measures set out in the RexFlex Credit '
          'Policy in force at the time.',
    ),
    (
      'Credit assessment and data',
      'The Borrower consents to the Lender using their Rex account data to '
          'assess eligibility for this and future loans. Each new loan needs '
          'a fresh eligibility and risk assessment.',
    ),
    (
      'Future offers',
      'Repaying on time may increase future offers, ordinarily up to twice '
          'the highest fully repaid principal. Future offers are not '
          'guaranteed.',
    ),
    (
      'Acceptance',
      'The Borrower accepted this agreement electronically in the Rex app on '
          '${RexDates.dateTime(accepted)}.',
    ),
  ];

  pw.Widget clause(int n, String title, String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 12),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 20,
          height: 20,
          alignment: pw.Alignment.center,
          decoration: const pw.BoxDecoration(
            color: wash,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Text(
            '$n',
            style: st(8.5, f: bold, color: blue),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 3),
              pw.Text(
                title,
                style: st(10, f: semibold, color: ink),
              ),
              pw.SizedBox(height: 3),
              pw.Text(text, style: st(9, line: 3.2)),
            ],
          ),
        ),
      ],
    ),
  );

  pw.Widget signature(String role, String name, String note) => pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: hairline, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          eyebrow(role),
          pw.SizedBox(height: 8),
          pw.Text(
            name,
            style: st(11, f: semibold, color: ink),
          ),
          pw.SizedBox(height: 10),
          pw.Container(height: 0.8, color: hairline),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: const pw.BoxDecoration(
              color: greenWash,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Text(
              'Accepted electronically',
              style: st(7.5, f: semibold, color: green),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(note, style: st(8, color: muted)),
        ],
      ),
    ),
  );

  // ------------------------------------------------------------- document

  final doc = pw.Document(
    compress: compress,
    title: 'RexFlex Loan Agreement ${loan.id}',
    author: 'Rex',
    subject: 'Demo loan agreement',
  );

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: format,
        margin: const pw.EdgeInsets.fromLTRB(44, 40, 44, 36),
        buildBackground: (ctx) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Stack(
            children: [
              // Brand strip along the top edge.
              pw.Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: pw.Container(
                  height: 6,
                  decoration: const pw.BoxDecoration(
                    gradient: pw.LinearGradient(colors: [navy, blue]),
                  ),
                ),
              ),
              // DEMO watermark.
              pw.Center(
                child: pw.Transform.rotate(
                  angle: math.pi / 6,
                  child: pw.Text(
                    'DEMO',
                    style: pw.TextStyle(
                      font: bold,
                      fontSize: 140,
                      color: const PdfColor.fromInt(0xFFF3F5FA),
                      letterSpacing: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      header: (ctx) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 18),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                logo(height: ctx.pageNumber == 1 ? 24 : 16),
                pw.Spacer(),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    eyebrow('RexFlex · Loan agreement', color: blue),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Ref ${loan.id}',
                      style: st(9, f: semibold, color: ink),
                    ),
                    pw.Text(
                      RexDates.dayMonthYear(accepted),
                      style: st(8.5, color: muted),
                    ),
                  ],
                ),
              ],
            ),
            if (ctx.pageNumber == 1) ...[
              pw.SizedBox(height: 14),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 10,
                ),
                decoration: const pw.BoxDecoration(
                  color: amber,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Text(
                  'Demo document from the Rex prototype. Not a binding '
                  'agreement, and no money has moved.',
                  style: st(8, f: medium, color: amberText),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
      footer: (ctx) => pw.Column(
        children: [
          pw.Container(height: 0.8, color: hairline),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Text(
                'RexFlex Loan Agreement · ${loan.id}',
                style: st(7.5, color: muted),
              ),
              pw.Spacer(),
              pw.Text(
                'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                style: st(7.5, f: medium, color: muted),
              ),
            ],
          ),
        ],
      ),
      build: (_) => [
        pw.Text(
          'Loan Agreement',
          style: st(22, f: bold, color: ink),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'This agreement is made on ${RexDates.dayMonthYear(accepted)} '
          'between Rex ("the Lender") and $borrowerName ("the Borrower"). '
          'It sets out the terms of the RexFlex loan below.',
          style: st(9.5, line: 3.2),
        ),
        pw.SizedBox(height: 16),
        summaryCard(),
        sectionTitle('Parties'),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            party('Lender', 'Rex', ['RexFlex short-term loans']),
            pw.SizedBox(width: 10),
            party('Borrower', borrowerName, [accountLabel]),
          ],
        ),
        sectionTitle('Loan details'),
        detailsTable(),
        pw.NewPage(),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            sectionTitle('Terms and conditions'),
            clause(1, clauses[0].$1, clauses[0].$2),
          ],
        ),
        for (var i = 1; i < clauses.length; i++)
          clause(i + 1, clauses[i].$1, clauses[i].$2),
        pw.Column(
          children: [
            sectionTitle('Signatures'),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                signature(
                  'Borrower',
                  borrowerName,
                  RexDates.dateTime(accepted),
                ),
                pw.SizedBox(width: 10),
                signature('Lender', 'Rex', 'On behalf of RexFlex'),
              ],
            ),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}
