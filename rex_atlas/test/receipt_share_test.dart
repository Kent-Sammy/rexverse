import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/features/atlas/data/mock/mock_data.dart';
import 'package:rex_atlas/features/atlas/data/mock/mock_history_services.dart';
import 'package:rex_atlas/features/atlas/domain/models/models.dart';
import 'package:rex_atlas/features/atlas/presentation/receipt/receipt_pdf.dart';
import 'package:rex_atlas/features/atlas/presentation/receipt/receipt_sharer.dart';
import 'package:rex_atlas/features/atlas/presentation/receipt/share_receipt_screen.dart';
import 'package:rex_atlas/features/atlas/presentation/screens/atlas_receipt_screen.dart';

class FakeSharer implements ReceiptSharer {
  final shared = <(String, Uint8List)>[];

  @override
  Future<void> shareImage(Uint8List png, String fileName) async =>
      shared.add((fileName, png));

  @override
  Future<void> sharePdf(Uint8List pdf, String fileName) async =>
      shared.add((fileName, pdf));
}

const tunde = '7065142730000'; // seeded GTBank transfer to Tunde Adeyemi

Receipt tundeReceipt() =>
    MockReceiptBuilder.fromRecord(MockData.seedLatestTransfer(), MockData.user);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('receipt data', () {
    test('share rows follow the Figma order with masked accounts', () {
      final r = tundeReceipt();
      expect(r.shareRows.map((e) => e.label).toList(), [
        'Recipient Details',
        'Sender Details',
        'Transaction Type',
        'Transaction No.',
        'Transaction Date',
      ]);
      expect(r.shareRows[0].value, 'TUNDE ADEYEMI\nGTBank | 000****716');
      expect(r.shareRows[1].value, 'OLOLADE MR. MONEY\nREXMFB | 110****921');
      expect(r.shareRows[2].value, 'Bank Transfer');
    });

    test('transfers can be repeated through Atlas', () {
      final r = tundeReceipt();
      expect(r.repeat?.label, 'Repeat Transfer');
      expect(r.repeat?.utterance, startsWith('Send ₦'));
      expect(r.repeat?.utterance, endsWith('to GTBank 0004218716'));
    });

    test('the PDF is a real, demo-labelled document', () async {
      final bytes = await buildReceiptPdf(tundeReceipt(), compress: false);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(String.fromCharCodes(bytes), contains('Demo transaction receipt'));
    });
  });

  Widget host(Widget child) => MaterialApp(home: child);

  Future<void> openDetails(
    WidgetTester t, {
    FakeSharer? sharer,
    ValueChanged<String>? onRepeat,
  }) async {
    final history = MockTransactionHistoryService(latency: Duration.zero);
    await t.pumpWidget(
      host(
        AtlasReceiptScreen(
          reference: tunde,
          receipts: MockReceiptService(history: history, sender: MockData.user),
          sharer: sharer ?? FakeSharer(),
          onRepeat: onRepeat,
        ),
      ),
    );
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
  }

  testWidgets('Transaction Details shows the three actions', (t) async {
    await openDetails(t, onRepeat: (_) {});
    expect(find.text('Transaction Details'), findsWidgets);
    expect(find.text('Transaction Successful'), findsOneWidget);
    expect(find.text('Repeat Transfer'), findsOneWidget);
    expect(find.text('Share Receipt'), findsOneWidget);
    expect(find.text('Report'), findsOneWidget);
    expect(find.byKey(const Key('receipt-demo-banner')), findsOneWidget);
  });

  testWidgets('Repeat hands the transfer back to Atlas', (t) async {
    String? sent;
    await openDetails(t, onRepeat: (u) => sent = u);
    await t.tap(find.byKey(const Key('receipt-repeat')));
    await t.pumpAndSettle();
    expect(sent, endsWith('to GTBank 0004218716'));
  });

  testWidgets('Repeat is hidden when there is no Atlas to send to', (t) async {
    await openDetails(t);
    expect(find.byKey(const Key('receipt-repeat')), findsNothing);
  });

  testWidgets('Report collects a reason and says it is a demo', (t) async {
    await openDetails(t);
    await t.tap(find.byKey(const Key('receipt-report')));
    await t.pumpAndSettle();
    expect(find.text('Report this transaction'), findsOneWidget);
    await t.tap(find.byKey(const Key('report-submit')));
    await t.pumpAndSettle();
    expect(find.text('Report this transaction'), findsOneWidget);
    await t.tap(find.text('I was debited twice'));
    await t.pump();
    await t.tap(find.byKey(const Key('report-submit')));
    await t.pumpAndSettle();
    expect(find.text('Report this transaction'), findsNothing);
    expect(find.textContaining('nothing was sent'), findsOneWidget);
  });

  testWidgets('Share Receipt shares a PDF and an image', (t) async {
    final sharer = FakeSharer();
    await openDetails(t, sharer: sharer);
    await t.tap(find.byKey(const Key('receipt-share')));
    await t.pumpAndSettle();

    expect(find.byType(ShareReceiptScreen), findsOneWidget);
    expect(find.text('Recipient Details'), findsOneWidget);
    expect(find.text('Sender Details'), findsOneWidget);
    expect(find.byKey(const Key('share-receipt-demo-note')), findsOneWidget);

    await t.runAsync(() async {
      await t.tap(find.byKey(const Key('share-as-pdf')));
      await Future<void>.delayed(const Duration(seconds: 2));
    });
    await t.pump();
    expect(sharer.shared.single.$1, 'Rex-Receipt-$tunde.pdf');

    await t.runAsync(() async {
      await t.tap(find.byKey(const Key('share-as-image')));
      await Future<void>.delayed(const Duration(seconds: 2));
    });
    await t.pump();
    expect(sharer.shared.last.$1, 'Rex-Receipt-$tunde.png');
    final png = sharer.shared.last.$2;
    expect(png.sublist(1, 4), 'PNG'.codeUnits);
  });

  testWidgets('receipt screens meet contrast and tap-target guidelines', (
    t,
  ) async {
    final handle = t.ensureSemantics();
    await openDetails(t, onRepeat: (_) {});
    await expectLater(t, meetsGuideline(textContrastGuideline));
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    await t.tap(find.byKey(const Key('receipt-share')));
    await t.pumpAndSettle();
    await expectLater(t, meetsGuideline(textContrastGuideline));
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
