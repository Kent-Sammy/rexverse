import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/app/app.dart';
import 'package:rex_atlas/features/atlas/atlas.dart';
import 'package:rex_atlas/features/atlas/domain/models/models.dart';
import 'package:rex_atlas/features/atlas/domain/services/services.dart';
import 'package:rex_atlas/features/atlas/presentation/bottom_sheet/atlas_sheet.dart';

AtlasController newController() =>
    AtlasController(AtlasDependencies.mock(latency: Duration.zero));

List<String> texts(AtlasController c) =>
    c.messages.whereType<TextMessage>().map((m) => m.text).toList();

TextMessage lastAsk(AtlasController c) => c.messages
    .whereType<TextMessage>()
    .where((m) => m.author == ChatAuthor.assistant)
    .last;

Future<void> settle() =>
    Future<void>.delayed(const Duration(milliseconds: 400));

Future<PaymentResultMessage> confirmAndAuthorise(AtlasController c) async {
  await c.send('Yes, continue please');
  await c.authorizeWithBiometrics();
  await settle();
  return c.messages.whereType<PaymentResultMessage>().last;
}

void main() {
  group('RexSave', () {
    test(
      'asks for an amount with suggestions, then reviews and saves',
      () async {
        final c = newController();
        await c.send('Save Money');
        expect(lastAsk(c).text, contains('RexSave earns 16% a year'));
        expect(lastAsk(c).quickReplies, contains('₦10,000'));
        await c.send('₦10,000');
        final d =
            c.messages.whereType<PaymentReviewMessage>().single.draft
                as SavingsDraft;
        expect(d.amountKobo, 1000000);
        expect(d.plan, SavingsPlan.rexSave);
        expect(d.annualRatePct, 16);
        final r = await confirmAndAuthorise(c);
        expect(r.result.isSuccessful, isTrue);
        expect(r.receipt!.rows.map((e) => e.label), contains('Savings Plan'));
        expect(
          (await c.deps.history.recent()).first.category,
          TransactionCategory.savings,
        );
      },
    );

    test('Rexy December adds a 5% upfront bonus and a lock date', () async {
      final c = newController();
      await c.send('Get Started With Rexy December');
      await c.send('20000');
      final d =
          c.messages.whereType<PaymentReviewMessage>().single.draft
              as SavingsDraft;
      expect(d.plan, SavingsPlan.rexyDecember);
      expect(d.bonusKobo, 100000); // 5% of ₦20,000
      expect(d.lockedUntil!.month, 12);
      expect(d.lockedUntil!.day, 31);
    });

    test('minimum deposit is enforced', () async {
      final c = newController();
      await c.send('Save ₦50');
      expect(texts(c).last, contains('minimum RexSave deposit is ₦100'));
    });
  });

  group('RexVault', () {
    test(
      'asks how much to save and works out earnings at 22% for each period',
      () async {
        final c = newController();
        await c.send('Save in RexVault');
        expect(
          lastAsk(c).text,
          contains('How much do you want to save in RexVault?'),
        );
        await c.send('₦100,000');
        expect(lastAsk(c).text, contains('At 22% a year'));
        expect(lastAsk(c).quickReplies, [
          '1 month · earn ₦1,808',
          '3 months · earn ₦5,425',
          '6 months · earn ₦10,849',
          '1 year · earn ₦22,000',
        ]);
        await c.send('3 months · earn ₦5,425');
        final d =
            c.messages.whereType<PaymentReviewMessage>().single.draft
                as VaultDraft;
        expect(
          d.amountKobo,
          10000000,
        ); // the earnings in the chip aren't the amount
        expect(d.tenorDays, 90);
        expect(d.annualRatePct, 22);
        expect(d.interestKobo, 542466); // ₦100,000 × 22% × 90/365
        expect(d.maturity.difference(DateTime.now()).inDays, closeTo(90, 1));
        final r = await confirmAndAuthorise(c);
        expect(r.result.isSuccessful, isTrue);
        expect(
          r.receipt!.rows.map((e) => e.label),
          containsAll([
            'Saving Period',
            'Interest Earned',
            'Total at Maturity',
            'Maturity Date',
          ]),
        );
      },
    );

    test('amounts below ₦10,000 are refused', () async {
      final c = newController();
      await c.send('save 5000 in my vault');
      expect(texts(c).last, contains('minimum RexVault savings is ₦10,000'));
    });
  });

  group('Bills', () {
    test('electricity: category → company → meter → amount → token', () async {
      final c = newController();
      await c.send('Pay A Bill');
      expect(lastAsk(c).quickReplies, ['Electricity', 'Cable TV', 'Internet']);
      await c.send('Electricity');
      expect(lastAsk(c).quickReplies, contains('IKEDC'));
      await c.send('IKEDC');
      expect(texts(c).last, 'What is your IKEDC meter number?');
      await c.send('45031234567');
      expect(texts(c).last, contains('How much electricity'));
      await c.send('₦5,000');
      final d =
          c.messages.whereType<PaymentReviewMessage>().single.draft
              as BillDraft;
      expect(d.biller.id, 'ikedc');
      expect(d.customer.name, 'OLOLADE MR. MONEY');
      expect(d.amountKobo, 500000);
      final r = await confirmAndAuthorise(c);
      expect(r.result.details['Token'], matches(RegExp(r'^\d{4}(-\d{4}){4}$')));
      expect(
        r.receipt!.rows.firstWhere((e) => e.label == 'Token').copyable,
        isTrue,
      );
    });

    test(
      'cable TV uses the package price and refuses amount changes',
      () async {
        final c = newController();
        await c.send('Renew my DStv');
        await c.send('1234567890');
        expect(lastAsk(c).quickReplies, contains('Compact · ₦19,000'));
        await c.send('Compact · ₦19,000');
        final d =
            c.messages.whereType<PaymentReviewMessage>().single.draft
                as BillDraft;
        expect(d.package!.name, 'Compact');
        expect(d.amountKobo, 1900000);
        await c.send('change the amount to 5000');
        expect(
          texts(c).last,
          contains('price is set by the DStv Compact package'),
        );
      },
    );

    test('an unknown meter number is re-asked', () async {
      final c = newController();
      await c.send('pay ekedc bill');
      await c.send('00001234567');
      expect(texts(c).last, contains("couldn't find meter number"));
      expect(c.stage, ConversationStage.awaitingBillDetails);
    });

    test('cancel while collecting bill details', () async {
      final c = newController();
      await c.send('pay electricity');
      await c.send('cancel');
      expect(
        texts(c).last,
        "Okay, I've cancelled the bill payment. Nothing was charged.",
      );
    });
  });

  group('PIN', () {
    test(
      'correct PIN authorises; 0000 is wrong; 3 wrong attempts lock',
      () async {
        final c = newController();
        await c.send('Send ₦3000 to GTB 0004218716');
        await c.send('yes');
        await expectLater(
          c.authorizeWithPin('0000'),
          throwsA(isA<IncorrectPinException>()),
        );
        await c.authorizeWithPin('2468');
        await settle();
        expect(
          c.messages
              .whereType<PaymentResultMessage>()
              .single
              .result
              .isSuccessful,
          isTrue,
        );

        final c2 = newController();
        await c2.send('Send ₦3000 to GTB 0004218716');
        await c2.send('yes');
        await expectLater(
          c2.authorizeWithPin('0000'),
          throwsA(isA<IncorrectPinException>()),
        );
        await expectLater(
          c2.authorizeWithPin('0000'),
          throwsA(isA<IncorrectPinException>()),
        );
        await expectLater(
          c2.authorizeWithPin('0000'),
          throwsA(isA<PinLockedException>()),
        );
      },
    );
  });

  group('UI', () {
    Future<void> pumpFor(WidgetTester t, [int ms = 1500]) async {
      for (var i = 0; i < ms ~/ 100; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> open(WidgetTester t) async {
      t.view.physicalSize = const Size(402, 874);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        RexAtlasDemoApp(
          dependencies: AtlasDependencies.mock(latency: Duration.zero),
        ),
      );
      await t.pump();
    }

    Future<void> send(WidgetTester t, String text) async {
      await t.enterText(find.byKey(const Key('atlas-composer-field')), text);
      await t.pump();
      await t.tap(find.byKey(const Key('atlas-send-button')));
      await pumpFor(t);
    }

    testWidgets('PIN pad: wrong PIN shows an error, the right one completes', (
      t,
    ) async {
      await open(t);
      await t.tap(find.byKey(const Key('home-ask-atlas')));
      await pumpFor(t, 600);
      await send(t, 'Send ₦3000 to GTB 0004218716');
      await send(t, 'yes');
      await t.tap(find.byKey(const Key('biometric-use-pin')));
      await t.pump();
      for (final d in ['0', '0', '0', '0']) {
        await t.tap(find.byKey(Key('pin-key-$d')));
        await t.pump();
      }
      await pumpFor(t, 800);
      expect(find.byKey(const Key('pin-error')), findsOneWidget);
      expect(
        find.textContaining('Incorrect PIN. 2 attempts left.'),
        findsOneWidget,
      );
      for (final d in ['1', '9', '7', '3']) {
        await t.tap(find.byKey(Key('pin-key-$d')));
        await t.pump();
      }
      await pumpFor(t, 3000);
      expect(find.byKey(const Key('pin-pad')), findsNothing);
      expect(find.text('Transfer Successful!'), findsOneWidget);
    });

    testWidgets('home tiles start their flows in Atlas', (t) async {
      await open(t);
      await t.tap(find.byKey(const Key('home-rexvault-tile')));
      await pumpFor(t, 1500);
      expect(find.byType(AtlasSheet), findsOneWidget);
      expect(
        find.textContaining('How much do you want to save in RexVault?'),
        findsOneWidget,
      );
    });

    testWidgets('electricity result shows the token with a copy button', (
      t,
    ) async {
      await open(t);
      await t.tap(find.byKey(const Key('home-electricity-tile')));
      await pumpFor(t, 1500);
      await send(t, 'IKEDC');
      await send(t, '45031234567');
      await send(t, '5000');
      expect(find.text('Pay Bill'), findsNothing);
      await send(t, 'yes');
      await t.tap(find.byKey(const Key('biometric-fingerprint')));
      await pumpFor(t, 3000);
      expect(find.text('Payment Successful!'), findsOneWidget);
      expect(find.byKey(const Key('electricity-token')), findsOneWidget);
      expect(find.byKey(const Key('copy-token')), findsOneWidget);
    });
  });
}
