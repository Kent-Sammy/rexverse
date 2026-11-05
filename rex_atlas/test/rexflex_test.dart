import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/app/app.dart';
import 'package:rex_atlas/features/atlas/atlas.dart';
import 'package:rex_atlas/features/atlas/domain/services/services.dart';
import 'package:rex_atlas/features/rexflex/presentation/widgets/flex_ui.dart';
import 'package:rex_atlas/features/rexflex/rexflex.dart';

Future<void> pumpFor(WidgetTester t, [int ms = 1500]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

RexFlexController controller({DateTime? now}) {
  final deps = AtlasDependencies.mock(latency: Duration.zero);
  return RexFlexController(
    service: MockRexFlexService(
      latency: Duration.zero,
      stageDelay: Duration.zero,
    ),
    authorization: deps.authorization,
    accounts: deps.accounts,
    clock: () => now ?? DateTime(2026, 11, 20, 9),
  );
}

/// [realistic] keeps the app's default one-minute background review;
/// otherwise the review is shortened to ~3 s to keep flow tests quick.
Future<void> openHome(
  WidgetTester t, {
  double textScale = 1,
  bool realistic = false,
}) async {
  t.view.physicalSize = const Size(402, 874);
  t.view.devicePixelRatio = 1;
  t.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(t.view.reset);
  addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  await t.pumpWidget(
    RexAtlasDemoApp(
      dependencies: AtlasDependencies.mock(latency: Duration.zero),
      now: DateTime(2026, 11, 20, 9),
      rexflexService: realistic
          ? null
          : MockRexFlexService(stageDelay: const Duration(milliseconds: 1100)),
    ),
  );
  await t.pump();
}

Future<void> pumpSeconds(WidgetTester t, int seconds) async {
  for (var i = 0; i < seconds * 4; i++) {
    await t.pump(const Duration(milliseconds: 250));
  }
}

Future<void> applyForLoan(WidgetTester t) async {
  await tapKey(t, 'home-rexflex-tile');
  await tapKey(t, 'flex-get-started');
  await tapKey(t, 'flex-check-eligibility', ms: 1500);
  await tapKey(t, 'flex-eligible-continue');
  await tapKey(t, 'flex-term-continue');
  await tapKey(t, 'flex-consent');
  await tapKey(t, 'flex-confirm-application', ms: 600);
}

Future<void> tapKey(WidgetTester t, String key, {int ms = 600}) async {
  final f = find.byKey(Key(key));
  if (f.evaluate().isEmpty) {
    // Long pages (large text) build lazily: scroll the top screen's list.
    await t.scrollUntilVisible(
      f,
      300,
      scrollable: find
          .descendant(
            of: find.byType(FlexScaffold).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  await t.ensureVisible(f.last);
  await t.pump();
  await t.tap(f.last);
  await pumpFor(t, ms);
}

Future<void> enterPin(WidgetTester t, String pin) async {
  for (final d in pin.split('')) {
    await t.tap(find.byKey(Key('flex-pin-key-$d')));
    await t.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  group('pricing', () {
    test('8% per 30 days, pro-rated: ₦3,000 → ₦112 (14d) / ₦240 (30d)', () {
      expect(LoanTerm.priced(300000, 14).interestKobo, 11200);
      expect(LoanTerm.priced(300000, 14).totalKobo, 311200);
      expect(LoanTerm.priced(300000, 30).interestKobo, 24000);
      expect(LoanTerm.priced(300000, 30).totalKobo, 324000);
    });
  });

  group('controller', () {
    test('application goes through every stage, then disburses', () async {
      final c = controller();
      final stages = <ApplicationStage>[];
      final loan = c.apply(LoanTerm.priced(300000, 14), onStage: stages.add);
      expect(loan.status, LoanStatus.pending);
      expect(c.outstandingKobo, 0);
      await pumpEventQueue();
      expect(stages, ApplicationStage.values.skip(1));
      expect(loan.stageDone.keys, ApplicationStage.values);
      expect(loan.approvedAt, isNotNull);
      expect(loan.status, LoanStatus.active);
      expect(loan.startDate, DateTime(2026, 11, 20, 9));
      expect(loan.dueDate, DateTime(2026, 12, 4, 9));
      expect(loan.transactions.single.kind, LoanTxnKind.disbursement);
      expect(c.outstandingKobo, 311200);
    });

    test(
      'partial then full repayment settles and doubles the next offer',
      () async {
        final c = controller();
        expect(c.nextOfferKobo, 300000);
        final loan = c.apply(LoanTerm.priced(300000, 14));
        await pumpEventQueue();
        final token = await c.authorizePin('1234');

        final part = await c.repay(loan, 150000, token);
        expect(part.settled, isFalse);
        expect(part.outstandingKobo, 161200);
        expect(loan.status, LoanStatus.active);

        final full = await c.repay(loan, loan.outstandingKobo, token);
        expect(full.settled, isTrue);
        expect(full.isSimulated, isTrue);
        expect(full.reference, startsWith('DEMO-'));
        expect(loan.status, LoanStatus.settled);
        expect(c.currentLoan, isNull);
        expect(loan.transactions.map((t) => t.kind), [
          LoanTxnKind.fullRepayment,
          LoanTxnKind.partialRepayment,
          LoanTxnKind.disbursement,
        ]);
        // "Capped at 2× your highest fully repaid principal".
        expect(c.nextOfferKobo, 600000);
        expect(c.tierIndex, 1);
      },
    );

    test('cannot overpay', () async {
      final c = controller();
      final loan = c.apply(LoanTerm.priced(300000, 14));
      await pumpEventQueue();
      final token = await c.authorizePin('1234');
      expect(() => c.repay(loan, 400000, token), throwsArgumentError);
    });

    test('demo PIN 0000 is rejected', () async {
      final c = controller();
      expect(
        () => c.authorizePin('0000'),
        throwsA(isA<IncorrectPinException>()),
      );
    });
  });

  testWidgets('end-to-end: apply, part-repay, repay in full, journey', (
    t,
  ) async {
    await openHome(t);

    // Home → RexFlex tile → "Earn your flex".
    await tapKey(t, 'home-rexflex-tile');
    expect(find.text('Earn your flex'), findsOneWidget);

    // Eligibility sheet → You're Eligible!
    await tapKey(t, 'flex-get-started');
    expect(find.text('Check Your Eligibility'), findsOneWidget);
    await tapKey(t, 'flex-check-eligibility', ms: 1500);
    expect(find.text("You're Eligible!"), findsOneWidget);
    expect(find.text('₦3,000'), findsOneWidget);
    expect(find.text('Repay ₦3,112.00'), findsOneWidget);
    expect(find.text('Repay ₦3,240.00'), findsOneWidget);
    await tapKey(t, 'flex-eligible-continue');

    // Choose a term → Review → consent gates Confirm.
    expect(find.text('Choose a Repayment Term'), findsOneWidget);
    expect(find.text('+₦112 interest'), findsOneWidget);
    expect(find.text('Repay ₦3,112.00 by 04 Dec 2026'), findsOneWidget);
    await tapKey(t, 'flex-term-continue');
    expect(find.text('Review Your Offer'), findsOneWidget);
    expect(find.text('04 Dec 2026'), findsOneWidget); // due date
    await tapKey(t, 'flex-confirm-application'); // disabled
    expect(find.text('Application Received'), findsNothing);
    await tapKey(t, 'flex-consent');
    await tapKey(t, 'flex-confirm-application', ms: 300);
    expect(find.text('Application Received'), findsWidgets);

    // Review stages finish → Loan Approved!
    await pumpFor(t, 5000);
    expect(find.text('Loan Approved!'), findsOneWidget);
    await tapKey(t, 'flex-view-loan');
    expect(find.text('RexFlex Loan'), findsWidgets);
    expect(find.text('₦ 3,112.00'), findsOneWidget);
    expect(find.text('14 days remaining'), findsOneWidget);
    expect(find.text('Loan Disbursement'), findsOneWidget);

    // Partial repayment of ₦1,500 with the PIN pad.
    await tapKey(t, 'flex-repay-loan');
    await tapKey(t, 'flex-repay-partial');
    await tapKey(t, 'flex-repay-continue');
    await t.enterText(find.byKey(const Key('flex-partial-amount')), '1500');
    await t.pump();
    await tapKey(t, 'flex-partial-continue');
    expect(find.text('Pay ₦1,500.00'), findsOneWidget);
    expect(
      find.text(
        'Your loan will remain active with a new outstanding balance of '
        '₦1,612.00',
      ),
      findsOneWidget,
    );
    await tapKey(t, 'flex-pay');
    expect(find.text('Confirm Payment'), findsOneWidget);
    await enterPin(t, '0000');
    await pumpFor(t, 300);
    expect(find.byKey(const Key('flex-pin-error')), findsOneWidget);
    await enterPin(t, '1234');
    await pumpFor(t, 300);
    expect(find.text('Processing Payment'), findsOneWidget);
    await pumpFor(t, 2500);
    expect(find.text('Payment Successful!'), findsOneWidget);
    await tapKey(t, 'flex-view-loan-details');
    expect(find.text('₦ 1,612.00'), findsOneWidget);

    // Full repayment settles the loan → Well done! → Flex Journey.
    await tapKey(t, 'flex-repay-loan');
    await tapKey(t, 'flex-repay-continue');
    expect(
      find.text('This payment will fully settle your loan and close it'),
      findsOneWidget,
    );
    await tapKey(t, 'flex-pay');
    await enterPin(t, '1234');
    await pumpFor(t, 2800);
    expect(find.text('Repayment Successful!'), findsOneWidget);
    await tapKey(t, 'flex-view-loan-details');
    expect(find.text('Well done!'), findsOneWidget);

    // "Take Another Loan" pops the eligibility check straight up (no intro)
    // and the doubled ₦6,000 offer appears.
    await tapKey(t, 'flex-take-another');
    expect(find.text('Earn your flex'), findsNothing);
    expect(find.text('Check Your Eligibility'), findsOneWidget);
    await tapKey(t, 'flex-check-eligibility', ms: 1500);
    expect(find.text('Your next loan offer'), findsOneWidget);
    expect(find.text('₦6,000'), findsOneWidget);
    await tapKey(t, 'flex-sheet-close');

    // Flex Journey from the settled loan; the "You're on track!" card is gone.
    await tapKey(t, 'flex-loan-journey');
    expect(find.text('Your Flex Journey'), findsOneWidget);
    expect(find.text('₦3,000 repaid on time'), findsOneWidget);
    expect(find.text('LEVEL 2 OF 3'), findsOneWidget);
    expect(find.text("You're on track!"), findsNothing);
    await tapKey(t, 'flex-how-progression');
    expect(find.text('How Progression Works'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('returning customers land on the dashboard', (t) async {
    await openHome(t);
    await tapKey(t, 'home-rexflex-tile');
    await tapKey(t, 'flex-get-started');
    await tapKey(t, 'flex-check-eligibility', ms: 1500);
    await tapKey(t, 'flex-eligible-continue');
    await tapKey(t, 'flex-term-continue');
    await tapKey(t, 'flex-consent');
    await tapKey(t, 'flex-confirm-application', ms: 300);
    // Close the review sheet early: the dashboard shows it as Pending.
    await tapKey(t, 'flex-sheet-close');
    expect(find.text('RexFlex'), findsOneWidget);
    expect(find.text('Pending'), findsWidgets);
    expect(find.text('Application under review'), findsOneWidget);
    await pumpFor(t, 5000);
    expect(find.text('Active'), findsOneWidget);
    // Approved off-screen → the in-app notice; let it time out.
    expect(
      find.text('Your RexFlex loan of ₦3,000 was approved'),
      findsOneWidget,
    );
    await pumpSeconds(t, 7);

    // Back home; the Borrow tab now opens the dashboard directly.
    await tapKey(t, 'flex-back');
    await t.tap(find.text('Borrow'));
    await pumpFor(t, 600);
    expect(find.text('Outstanding Loan Amount'), findsOneWidget);
    expect(find.text('Earn your flex'), findsNothing);
  });

  testWidgets('RexFlex screens: text contrast and labelled buttons', (t) async {
    final handle = t.ensureSemantics();
    await openHome(t);
    await tapKey(t, 'home-rexflex-tile', ms: 1200);
    await expectLater(t, meetsGuideline(textContrastGuideline));
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    await tapKey(t, 'flex-get-started');
    await tapKey(t, 'flex-check-eligibility', ms: 1500);
    await tapKey(t, 'flex-eligible-continue', ms: 1200);
    await expectLater(t, meetsGuideline(textContrastGuideline));
    await tapKey(t, 'flex-term-continue');
    await tapKey(t, 'flex-consent');
    await tapKey(t, 'flex-confirm-application', ms: 5500);
    await tapKey(t, 'flex-view-loan', ms: 1200);
    await expectLater(t, meetsGuideline(textContrastGuideline));
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  for (final scale in const [1.5, 2.0]) {
    testWidgets('RexFlex: no overflow with system text at ${scale}x', (
      t,
    ) async {
      await openHome(t, textScale: scale);
      await tapKey(t, 'home-rexflex-tile');
      await tapKey(t, 'flex-get-started');
      await tapKey(t, 'flex-check-eligibility', ms: 1500);
      await tapKey(t, 'flex-eligible-continue');
      await tapKey(t, 'flex-term-continue');
      await tapKey(t, 'flex-consent');
      await tapKey(t, 'flex-confirm-application', ms: 5500);
      await tapKey(t, 'flex-view-loan');
      await tapKey(t, 'flex-repay-loan');
      await tapKey(t, 'flex-repay-continue');
      expect(t.takeException(), isNull);
    });
  }

  group('pending loan (realistic one-minute review)', () {
    testWidgets('leave, come back, follow progress, then approval notice', (
      t,
    ) async {
      await openHome(t, realistic: true);
      await applyForLoan(t);
      expect(find.text('Application Received'), findsWidgets);
      expect(find.text('In progress'), findsOneWidget);

      // "Got it" → dashboard shows the pending application.
      await tapKey(t, 'flex-application-got-it', ms: 800);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Under review · Step 2 of 4'), findsOneWidget);
      expect(find.text('Application under review'), findsOneWidget);

      // Open it: Loan Status with the live timeline.
      await tapKey(t, 'flex-loan-RF0001', ms: 800);
      expect(find.text('Loan Status'), findsOneWidget);
      expect(
        find.text('Step 2 of 4 · Eligibility & Risk Checks'),
        findsOneWidget,
      );
      await pumpSeconds(t, 21);
      expect(find.text('Step 3 of 4 · Final Decisions'), findsOneWidget);

      // Leave RexFlex entirely; the review keeps running.
      await tapKey(t, 'flex-back');
      await tapKey(t, 'flex-back');
      expect(find.text('Loan Status'), findsNothing);
      await pumpSeconds(t, 41);

      // Approved while on the home screen → notice with "View".
      expect(
        find.text('Your RexFlex loan of ₦3,000 was approved'),
        findsOneWidget,
      );
      await t.tap(find.text('View'));
      await pumpFor(t, 1200);
      expect(find.text('RexFlex Loan'), findsOneWidget);
      expect(find.byKey(const Key('flex-repay-loan')), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('approval while watching switches the status page in place', (
      t,
    ) async {
      await openHome(t, realistic: true);
      await applyForLoan(t);
      await tapKey(t, 'flex-application-got-it', ms: 800);
      await tapKey(t, 'flex-loan-RF0001', ms: 800);
      await pumpSeconds(t, 61);
      expect(find.text('Loan Approved!'), findsOneWidget);
      // No duplicate notice for the loan already on screen.
      expect(
        find.text('Your RexFlex loan of ₦3,000 was approved'),
        findsNothing,
      );
      await tapKey(t, 'flex-view-loan', ms: 1000);
      expect(find.byKey(const Key('flex-repay-loan')), findsOneWidget);
    });
  });
}
