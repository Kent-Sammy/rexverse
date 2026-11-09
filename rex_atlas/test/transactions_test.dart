import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/app/app.dart';
import 'package:rex_atlas/features/atlas/atlas.dart';
import 'package:rex_atlas/features/atlas/presentation/screens/atlas_receipt_screen.dart';
import 'package:rex_atlas/features/transactions/domain/account_transaction.dart';
import 'package:rex_atlas/features/transactions/presentation/all_transactions_screen.dart';
import 'package:rex_atlas/features/transactions/presentation/transaction_filter.dart';

Future<void> pumpFor(WidgetTester t, [int ms = 1500]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> openTransactions(WidgetTester t, {double textScale = 1}) async {
  t.view.physicalSize = const Size(402, 874);
  t.view.devicePixelRatio = 1;
  t.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(t.view.reset);
  addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  await t.pumpWidget(
    RexAtlasDemoApp(
      dependencies: AtlasDependencies.mock(latency: Duration.zero),
      now: DateTime(2026, 11, 9, 14, 30),
    ),
  );
  await t.pump();
  await t.tap(find.byKey(const Key('home-transactions')));
  await pumpFor(t, 1200);
}

Finder inList(String text) => find.descendant(
  of: find.byKey(const Key('txns-list')),
  matching: find.text(text),
);

Future<void> scrollTo(WidgetTester t, Finder f) => t.scrollUntilVisible(
  f,
  200,
  scrollable: find
      .descendant(
        of: find.byKey(const Key('txns-list')),
        matching: find.byType(Scrollable),
      )
      .first,
);

void main() {
  testWidgets('opens from Home with every product, grouped by day', (t) async {
    await openTransactions(t);
    expect(find.byType(AllTransactionsScreen), findsOneWidget);
    expect(find.text('All Transactions'), findsOneWidget);
    expect(find.text('Today, Nov 9'), findsNWidgets(2)); // summary + header
    expect(find.text('Received'), findsOneWidget);
    expect(find.text('Spent'), findsOneWidget);
    // Today: ₦150,000 + ₦82,600 top up + ₦1,250 interest in.
    expect(find.text('₦233,850'), findsOneWidget);

    expect(find.textContaining('business'), findsNothing);
    expect(find.text('Your Rex wallet'), findsOneWidget);
    await scrollTo(t, inList('RexVault Deposit'));
    await scrollTo(t, inList('RexSave Withdrawal'));
    expect(t.takeException(), isNull);
  });

  testWidgets('product tabs and the filter sheet narrow the list', (t) async {
    await openTransactions(t);
    expect(find.byKey(const Key('txns-tab-all')), findsOneWidget);
    await t.tap(find.byKey(const Key('txns-tab-rexvault')));
    await t.pump();
    expect(inList('RexVault Deposit'), findsOneWidget);
    expect(inList('RexVault Interest'), findsOneWidget);
    expect(inList('POS Settlement'), findsNothing);

    await t.tap(find.byKey(const Key('txns-tab-rexsave')));
    await t.pump();
    expect(inList('RexSave Interest'), findsOneWidget);
    expect(inList('RexVault Deposit'), findsNothing);

    // Quick filter: physical card debits only.
    await t.tap(find.byKey(const Key('txns-tab-all')));
    await t.tap(find.byKey(const Key('txns-filter')));
    await t.pumpAndSettle();
    expect(find.text('Transaction filter'), findsOneWidget);
    expect(find.text('Personal'), findsNothing); // single wallet: no Source
    await t.tap(find.byKey(const Key('txns-quick-virtualCard')));
    await t.tap(find.byKey(const Key('txns-apply')));
    await t.pumpAndSettle();
    expect(inList('Online Card Payment'), findsWidgets);
    expect(inList('Card Payment'), findsNothing);
    expect(inList('RexSave Interest'), findsNothing);
    await t.tap(find.byKey(const Key('txns-clear-type')));
    await t.pump();

    // Bill payments: education.
    await t.tap(find.byKey(const Key('txns-filter')));
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(const Key('txns-quick-education')));
    await t.tap(find.byKey(const Key('txns-quick-education')));
    await t.ensureVisible(find.byKey(const Key('txns-apply')));
    await t.tap(find.byKey(const Key('txns-apply')));
    await t.pumpAndSettle();
    expect(inList('School Fees Payment'), findsOneWidget);
    expect(inList('Electricity Token'), findsNothing);
    await t.tap(find.byKey(const Key('txns-clear-type')));
    await t.pump();
    expect(inList('RexSave Interest'), findsOneWidget);
  });

  test('amount range and quick filters match the right rows', () {
    final big = AccountTransaction(
      reference: 'a',
      title: 'Big',
      channel: 'Transfer',
      kind: TxnKind.transfer,
      direction: TxnDirection.credit,
      amountKobo: 50000000, // ₦500,000
      at: DateTime(2026, 11, 9),
    );
    expect(const TxnFilter(maxNaira: 450000).matches(big), isFalse);
    expect(
      const TxnFilter(minNaira: 40000, maxNaira: 450000).amountLabel,
      '₦40k - ₦450k',
    );
    expect(const TxnFilter(quick: QuickFilter.topUp).matches(big), isTrue);
    expect(const TxnFilter(quick: QuickFilter.cardDebit).matches(big), isFalse);
    expect(TxnFilter(from: DateTime(2026, 11, 10)).matches(big), isFalse);
    expect(
      TxnFilter(
        from: DateTime(2026, 11, 9),
        to: DateTime(2026, 11, 9),
      ).matches(big),
      isTrue,
    );
  });

  testWidgets('search finds by name, and no match shows a message', (t) async {
    await openTransactions(t);
    await t.enterText(find.byKey(const Key('txns-search')), 'chidinma');
    await t.pump();
    expect(inList('Transfer from Chidinma Okafor'), findsOneWidget);
    expect(inList('POS Settlement'), findsNothing);
    await t.enterText(find.byKey(const Key('txns-search')), 'zzzz');
    await t.pump();
    expect(find.byKey(const Key('txns-empty')), findsOneWidget);
    expect(find.text('No transactions found'), findsOneWidget);
    await t.tap(find.text('Clear filters'));
    await t.pump();
    expect(find.byKey(const Key('txns-empty')), findsNothing);
    expect(inList('POS Settlement'), findsNothing); // single wallet
    expect(inList('Wallet Top Up'), findsOneWidget);
  });

  testWidgets('RexFlex tab with no loans shows an empty state that opens '
      'RexFlex', (t) async {
    await openTransactions(t);
    await t.tap(find.byKey(const Key('txns-tab-rexflex')));
    await t.pump();
    expect(find.text('No RexFlex transactions yet'), findsOneWidget);
    await t.tap(find.text('Get a RexFlex loan'));
    await pumpFor(t, 1500);
    expect(find.byType(AllTransactionsScreen), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('a row opens its Transaction Details with share', (t) async {
    await openTransactions(t);
    await t.tap(inList('Transfer from Chidinma Okafor'));
    await pumpFor(t, 1000);
    expect(find.byType(AtlasReceiptScreen), findsOneWidget);
    expect(find.text('CHIDINMA OKAFOR'), findsOneWidget);
    expect(find.byKey(const Key('receipt-share')), findsOneWidget);
    expect(find.byKey(const Key('receipt-demo-banner')), findsOneWidget);
    await t.tap(find.byKey(const Key('receipt-share')));
    await t.pumpAndSettle();
    expect(find.text('Sender Details'), findsOneWidget);
    expect(find.text('Recipient Details'), findsOneWidget);
  });

  testWidgets('text contrast and labelled buttons', (t) async {
    final handle = t.ensureSemantics();
    await openTransactions(t);
    await expectLater(t, meetsGuideline(textContrastGuideline));
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('no overflow with system text at 2x', (t) async {
    await openTransactions(t, textScale: 2);
    await t.tap(find.byKey(const Key('txns-filter')));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    await t.tap(find.byKey(const Key('txns-filter-close')));
    await t.pumpAndSettle();
    await scrollTo(t, inList('RexSave Withdrawal'));
    expect(t.takeException(), isNull);
  });
}
