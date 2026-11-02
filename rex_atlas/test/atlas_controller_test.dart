import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/features/atlas/atlas.dart';
import 'package:rex_atlas/features/atlas/domain/models/models.dart';
import 'package:rex_atlas/features/atlas/domain/services/services.dart';

AtlasController newController() =>
    AtlasController(AtlasDependencies.mock(latency: Duration.zero));

List<String> texts(AtlasController c) =>
    c.messages.whereType<TextMessage>().map((m) => m.text).toList();

Future<void> settle() =>
    Future<void>.delayed(const Duration(milliseconds: 400));

void main() {
  test(
    'designed transfer flow: review → confirm → authorise → result',
    () async {
      final c = newController();
      final events = <AtlasEvent>[];
      c.events.listen(events.add);

      await c.send('Send Money');
      expect(texts(c).last, 'Which account do you want to send money to?');
      expect(c.stage, ConversationStage.awaitingTransferDetails);

      await c.send('Send ₦3000 to GTB 0004218716');
      final review = c.messages.whereType<PaymentReviewMessage>().single;
      final draft = review.draft as TransferDraft;
      expect(draft.beneficiary.accountName, 'ODELEYE OLAYINKA ANTHONY');
      expect(draft.amountKobo, 300000);
      expect(draft.totalKobo, 300000);
      expect(
        texts(c),
        contains(
          'Got it. I found the account details please review and confirm.',
        ),
      );
      expect(texts(c).last, 'Shall I go ahead?');
      expect(c.stage, ConversationStage.awaitingPaymentConfirmation);

      await c.send('Yes, continue please');
      expect(c.messages.whereType<PaymentConfirmationMessage>(), hasLength(1));
      expect(c.stage, ConversationStage.awaitingAuthorization);
      await settle();
      expect(events.whereType<RequestAuthorizationEvent>(), hasLength(1));

      await c.authorizeWithBiometrics();
      await settle();
      final result = c.messages.whereType<PaymentResultMessage>().single;
      expect(result.result.isSuccessful, isTrue);
      expect(result.result.isSimulated, isTrue);
      expect(result.receipt, isNotNull);
      expect(result.receipt!.rows.first.label, 'Transaction No.');
      // Confirmation card is replaced by the result (frame 6).
      expect(c.messages.whereType<PaymentConfirmationMessage>(), isEmpty);
      expect(c.messages.last, isA<SuggestionsMessage>());
      expect(c.stage, ConversationStage.idle);

      // The completed transfer appears in history.
      final recent = await c.deps.history.recent();
      expect(recent.first.reference, result.result.reference);
    },
  );

  test('user can cancel at review and nothing is sent', () async {
    final c = newController();
    await c.send('Send ₦3000 to GTB 0004218716');
    await c.send('Cancel');
    expect(
      texts(c).last,
      "Okay, I've cancelled this transfer. No money was sent.",
    );
    expect(c.pendingPayment, isNull);
    expect(
      c.messages.whereType<PaymentReviewMessage>().single.isActive,
      isFalse,
    );
    final recent = await c.deps.history.recent();
    expect(recent.first.title, 'Card Payment');
  });

  test('user can correct the amount before confirming', () async {
    final c = newController();
    await c.send('Send ₦3000 to GTB 0004218716');
    await c.send('change the amount to 4500');
    final reviews = c.messages.whereType<PaymentReviewMessage>().toList();
    expect(reviews, hasLength(2));
    expect(reviews.first.isActive, isFalse);
    expect(reviews.last.draft.amountKobo, 450000);
  });

  test('missing details are collected one at a time', () async {
    final c = newController();
    await c.send('Send Money');
    await c.send('0004218716');
    expect(texts(c).last, 'Which bank is 0004218716 with?');
    await c.send('GTB');
    expect(
      texts(c).last,
      'How much would you like to send to ODELEYE OLAYINKA ANTHONY?',
    );
    await c.send('3000');
    expect(c.messages.whereType<PaymentReviewMessage>(), hasLength(1));
  });

  test('unknown account shows a recoverable error', () async {
    final c = newController();
    await c.send('Send ₦3000 to GTB 0000001234');
    expect(texts(c).last, contains("I couldn't find account 0000001234"));
    expect(c.messages.whereType<PaymentReviewMessage>(), isEmpty);
  });

  test('assistant outage shows an error with a retry action', () async {
    final c = newController();
    await c.send('simulate error');
    final err = c.messages.whereType<ErrorMessage>().single;
    expect(err.retryText, 'simulate error');
    expect(c.isBusy, isFalse);
  });

  test('dismissing biometrics keeps the transfer paused', () async {
    final c = newController();
    await c.send('Send ₦3000 to GTB 0004218716');
    await c.send('yes');
    c.authorizationDismissed();
    expect(c.stage, ConversationStage.awaitingPaymentConfirmation);
    expect(c.pendingPayment, isNotNull);
    final events = <AtlasEvent>[];
    c.events.listen(events.add);
    await c.send('Continue');
    await settle();
    expect(events.whereType<RequestAuthorizationEvent>(), hasLength(1));
    // No duplicate confirmation card.
    expect(c.messages.whereType<PaymentConfirmationMessage>(), hasLength(1));
  });

  test('transfers above the demo limit fail without moving money', () async {
    final c = newController();
    await c.send('Send ₦6,000,000 to GTB 0004218716');
    await c.send('yes');
    await c.authorizeWithBiometrics();
    await settle();
    final r = c.messages.whereType<PaymentResultMessage>().single;
    expect(r.result.isSuccessful, isFalse);
    expect(r.receipt, isNull);
  });

  test('airtime flow reuses review/confirm/result', () async {
    final c = newController();
    await c.send('Buy Airtime');
    expect(
      texts(c).last,
      'Which phone number should I top up, and how much airtime?',
    );
    await c.send('₦500 to 08031234567');
    final d =
        c.messages.whereType<PaymentReviewMessage>().single.draft
            as AirtimeDraft;
    expect(d.network, 'MTN');
    await c.send('yes');
    await c.authorizeWithBiometrics();
    await settle();
    expect(
      c.messages.whereType<PaymentResultMessage>().single.result.isSuccessful,
      isTrue,
    );
  });

  test('recent transactions come from the history service', () async {
    final c = newController();
    await c.send('Show my recent transactions');
    final t = c.messages.whereType<TransactionsMessage>().single;
    expect(t.transactions.map((e) => e.title), [
      'Card Payment',
      'Transfer to K. Adewale',
      'Airtime Purchase',
      'Business Transfer',
    ]);
  });
}
