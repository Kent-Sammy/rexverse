import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/app/app.dart';
import 'package:rex_atlas/features/atlas/atlas.dart';
import 'package:rex_atlas/features/atlas/presentation/screens/atlas_receipt_screen.dart';
import 'package:rex_atlas/features/transactions/presentation/all_transactions_screen.dart';

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
    // Today: ₦150,000 + ₦82,600 + ₦1,250 in.
    expect(find.text('₦233,850'), findsOneWidget);

    await scrollTo(t, inList('RexVault Deposit'));
    await scrollTo(t, inList('RexSave Withdrawal'));
    expect(t.takeException(), isNull);
  });

  testWidgets('account chips and the type filter narrow the list', (t) async {
    await openTransactions(t);
    await t.tap(find.byKey(const Key('txns-chip-pos')));
    await t.pump();
    expect(inList('POS Settlement'), findsWidgets);
    expect(inList('RexSave Interest'), findsNothing);
    expect(find.text('POS terminals'), findsOneWidget);

    await t.tap(find.byKey(const Key('txns-chip-all')));
    await t.tap(find.byKey(const Key('txns-filter')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('txns-type-rexvault')));
    await t.pumpAndSettle();
    expect(inList('RexVault Deposit'), findsOneWidget);
    expect(inList('RexVault Interest'), findsOneWidget);
    expect(inList('POS Settlement'), findsNothing);
    await t.tap(find.byKey(const Key('txns-clear-type')));
    await t.pump();
    expect(inList('POS Settlement'), findsWidgets);
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
    await scrollTo(t, inList('RexSave Withdrawal'));
    expect(t.takeException(), isNull);
  });
}
