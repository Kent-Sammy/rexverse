import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/features/atlas/presentation/screens/atlas_receipt_screen.dart';
import 'package:rex_atlas/app/app.dart';
import 'package:rex_atlas/features/atlas/atlas.dart';
import 'package:rex_atlas/features/atlas/presentation/bottom_sheet/atlas_sheet.dart';

Future<void> pumpFor(WidgetTester t, [int ms = 1500]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> sendText(WidgetTester t, String text) async {
  await t.enterText(find.byKey(const Key('atlas-composer-field')), text);
  await t.pump();
  await t.tap(find.byKey(const Key('atlas-send-button')));
  await pumpFor(t);
}

void setPhone(WidgetTester t, Size size) {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

void main() {
  testWidgets('bottom nav: RexAtlas button in the centre opens Atlas', (
    t,
  ) async {
    setPhone(t, const Size(402, 874));
    await t.pumpWidget(
      RexAtlasDemoApp(
        dependencies: AtlasDependencies.mock(latency: Duration.zero),
        now: DateTime(2026, 11, 2, 9),
      ),
    );
    await t.pump();
    for (final key in ['home', 'rexsave', 'rexatlas', 'rexinvest', 'more']) {
      expect(find.byKey(Key('nav-$key')), findsOneWidget);
    }
    expect(find.byKey(const Key('nav-borrow')), findsNothing);
    // Tap the raised button itself (above the bar).
    final ring = t.getRect(find.byKey(const Key('nav-rexatlas')));
    await t.tapAt(Offset(ring.center.dx, ring.top - 4));
    await pumpFor(t, 600);
    expect(find.byType(AtlasSheet), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('home dashboard: RexPlay strip, coins, promos, Do more', (
    t,
  ) async {
    setPhone(t, const Size(402, 874));
    await t.pumpWidget(
      RexAtlasDemoApp(
        dependencies: AtlasDependencies.mock(latency: Duration.zero),
        now: DateTime(2026, 11, 2, 9),
      ),
    );
    await t.pump();
    expect(find.byKey(const Key('home-rexplay')), findsOneWidget);
    expect(find.byKey(const Key('home-coins')), findsOneWidget);
    expect(find.byKey(const Key('home-borrow')), findsOneWidget);
    expect(
      find.textContaining('Get 5% upfront!', findRichText: true),
      findsWidgets,
    );

    // Swipe the promo carousel to the next banner.
    await t.drag(find.byKey(const Key('home-promos')), const Offset(-300, 0));
    await pumpFor(t, 800);
    expect(find.text('Capital Market Investments'), findsOneWidget);

    // Do more with Rex starts on RexShop and swipes to the savings plan.
    await t.scrollUntilVisible(
      find.byKey(const Key('home-do-more')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('RexShop'), findsOneWidget);
    await t.drag(find.byKey(const Key('home-do-more')), const Offset(-300, 0));
    await pumpFor(t, 800);
    expect(find.text('Detty December'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('end-to-end designed transfer through the UI', (t) async {
    setPhone(t, const Size(402, 874));
    await t.pumpWidget(
      RexAtlasDemoApp(
        dependencies: AtlasDependencies.mock(latency: Duration.zero),
        now: DateTime(2026, 11, 2, 9),
      ),
    );
    await t.pump();

    // Entry point: "Ask RexAtlas....." pill.
    await t.tap(find.byKey(const Key('home-ask-atlas')));
    await pumpFor(t, 600);
    expect(find.text('Good morning,'), findsOneWidget);
    expect(find.text('How can I help you today?'), findsOneWidget);
    final sheet = t.state<AtlasSheetState>(find.byType(AtlasSheet));
    expect(sheet.mode, AtlasSheetMode.collapsed);

    // Quick action → chat expands.
    await t.tap(find.text('Send Money'));
    await pumpFor(t);
    expect(
      find.text('Which account do you want to send money to?'),
      findsOneWidget,
    );
    expect(sheet.mode, AtlasSheetMode.expanded);

    await sendText(t, 'Send ₦3000 to GTB 0004218716');
    expect(find.text('ODELEYE OLAYINKA ANTHONY'), findsOneWidget);
    expect(find.text('Total Debit'), findsOneWidget);
    expect(find.text('Shall I go ahead?'), findsOneWidget);

    await t.tap(find.byKey(const Key('quick-reply-Yes, continue please')));
    await pumpFor(t);
    expect(find.text('Confirm with your fingerprint'), findsOneWidget);
    expect(
      find.text('Demo: tap the fingerprint to simulate approval'),
      findsOneWidget,
    );

    await t.tap(find.byKey(const Key('biometric-fingerprint')));
    await pumpFor(t, 3000);
    expect(find.byKey(const Key('biometric-sheet')), findsNothing);
    expect(find.text('Transfer Successful!'), findsOneWidget);
    expect(
      find.text('Demo transaction · simulated, not a real bank record'),
      findsOneWidget,
    );

    await t.tap(find.text('View Receipt'));
    await pumpFor(t, 1200);
    expect(find.byType(AtlasReceiptScreen), findsOneWidget);
    expect(find.byKey(const Key('receipt-share')), findsOneWidget);
    expect(find.byKey(const Key('receipt-demo-banner')), findsOneWidget);
    await t.tap(find.byKey(const Key('receipt-back')));
    await pumpFor(t, 800);
    expect(find.byType(AtlasReceiptScreen), findsNothing);

    // Close and reopen: Atlas starts on the welcome screen again...
    await t.tap(find.bySemanticsLabel('Close Rex Atlas').last);
    await pumpFor(t, 600);
    expect(find.byType(AtlasSheet), findsNothing);
    await t.tap(find.byKey(const Key('home-atlas-tile')));
    await pumpFor(t, 600);
    expect(find.text('How can I help you today?'), findsOneWidget);
    expect(find.text('Transfer Successful!'), findsNothing);
    expect(
      t.state<AtlasSheetState>(find.byType(AtlasSheet)).mode,
      AtlasSheetMode.collapsed,
    );

    // ...and the first action brings back the chat with the full history.
    await t.ensureVisible(find.text('Buy Airtime'));
    await pumpFor(t, 600);
    await t.tap(find.text('Buy Airtime'));
    await pumpFor(t);
    expect(
      find.text('Which phone number should I top up, and how much airtime?'),
      findsOneWidget,
    );
    await t.drag(
      find.byKey(const Key('atlas-message-list')),
      const Offset(0, 3000),
    );
    await pumpFor(t, 600);
    expect(find.text('Send Money'), findsWidgets);
  });

  testWidgets('biometric cancel, PIN fallback and fullscreen toggle', (
    t,
  ) async {
    setPhone(t, const Size(402, 874));
    await t.pumpWidget(
      RexAtlasDemoApp(
        dependencies: AtlasDependencies.mock(latency: Duration.zero),
      ),
    );
    await t.pump();
    await t.tap(find.byKey(const Key('home-ask-atlas')));
    await pumpFor(t, 600);
    await sendText(t, 'Send ₦3000 to GTB 0004218716');
    await sendText(t, 'yes');
    expect(find.text('Confirm with your fingerprint'), findsOneWidget);

    await t.tap(find.byKey(const Key('biometric-use-pin')));
    await t.pump();
    expect(find.text('Enter your transaction PIN'), findsOneWidget);
    // On-screen keypad only: the PIN never goes through a text field / IME.
    expect(find.byType(TextField), findsOneWidget); // the composer
    await t.tap(find.byKey(const Key('biometric-back')));
    await t.pump();

    await t.tap(find.byKey(const Key('biometric-close')));
    await pumpFor(t, 800);
    expect(find.textContaining("I haven't sent anything"), findsOneWidget);

    final sheet = t.state<AtlasSheetState>(find.byType(AtlasSheet));
    await t.tap(find.bySemanticsLabel('Expand to full screen'));
    await pumpFor(t, 500);
    expect(sheet.mode, AtlasSheetMode.fullscreen);
    await t.tap(find.bySemanticsLabel('Exit full screen'));
    await pumpFor(t, 500);
    expect(sheet.mode, AtlasSheetMode.expanded);
  });

  testWidgets('dragging the welcome sheet down closes Atlas', (t) async {
    setPhone(t, const Size(402, 874));
    await t.pumpWidget(
      RexAtlasDemoApp(
        dependencies: AtlasDependencies.mock(latency: Duration.zero),
      ),
    );
    await t.pump();
    await t.tap(find.byKey(const Key('home-ask-atlas')));
    await pumpFor(t, 600);
    await t.fling(
      find.byKey(const Key('atlas-drag-zone')),
      const Offset(0, 400),
      2000,
    );
    await pumpFor(t, 800);
    expect(find.byType(AtlasSheet), findsNothing);
  });

  testWidgets('keyboard: collapsed sheet expands and composer stays above it', (
    t,
  ) async {
    setPhone(t, const Size(402, 874));
    await t.pumpWidget(
      RexAtlasDemoApp(
        dependencies: AtlasDependencies.mock(latency: Duration.zero),
      ),
    );
    await t.pump();
    await t.tap(find.byKey(const Key('home-ask-atlas')));
    await pumpFor(t, 600);
    final sheet = t.state<AtlasSheetState>(find.byType(AtlasSheet));
    expect(sheet.mode, AtlasSheetMode.collapsed);

    t.view.viewInsets = const FakeViewPadding(bottom: 336);
    addTearDown(t.view.resetViewInsets);
    await pumpFor(t, 600);
    expect(sheet.mode, AtlasSheetMode.expanded);
    final composer = t.getRect(find.byKey(const Key('atlas-composer-field')));
    expect(composer.bottom, lessThanOrEqualTo(874 - 336));
    expect(t.takeException(), isNull);
  });

  for (final size in const [Size(360, 640), Size(320, 568), Size(430, 932)]) {
    testWidgets(
      'no layout overflow at ${size.width.toInt()}x${size.height.toInt()}',
      (t) async {
        setPhone(t, size);
        await t.pumpWidget(
          RexAtlasDemoApp(
            dependencies: AtlasDependencies.mock(latency: Duration.zero),
          ),
        );
        await t.pump();
        await t.tap(find.byKey(const Key('home-ask-atlas')));
        await pumpFor(t, 600);
        await sendText(t, 'Send ₦3000 to GTB 0004218716');
        await sendText(t, 'yes');
        await t.tap(find.byKey(const Key('biometric-fingerprint')));
        await pumpFor(t, 3000);
        await sendText(t, 'Show my recent transactions');
        expect(t.takeException(), isNull);
      },
    );
  }

  // Android three-button navigation reports a tall bottom inset (48 dp);
  // the message bar must sit fully above it on the welcome and chat views.
  testWidgets('message bar clears the Android navigation bar', (t) async {
    setPhone(t, const Size(402, 874));
    t.view.padding = const FakeViewPadding(top: 24, bottom: 48);
    t.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
    await t.pumpWidget(
      RexAtlasDemoApp(
        dependencies: AtlasDependencies.mock(latency: Duration.zero),
        now: DateTime(2026, 11, 2, 9),
      ),
    );
    await t.pump();
    await t.tap(find.byKey(const Key('home-ask-atlas')));
    await pumpFor(t, 600);
    final send = find.byKey(const Key('atlas-send-button'));
    expect(t.getRect(send.last).bottom, lessThanOrEqualTo(874 - 48));

    await t.tap(find.text('Send Money'));
    await pumpFor(t);
    expect(t.getRect(send.last).bottom, lessThanOrEqualTo(874 - 48));
  });
}
