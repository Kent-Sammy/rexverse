import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/app/app.dart';
import 'package:rex_atlas/features/atlas/atlas.dart';
import 'package:rex_atlas/features/atlas/data/mock/mock_atlas_assistant_service.dart';
import 'package:rex_atlas/features/atlas/domain/models/models.dart';
import 'package:rex_atlas/features/atlas/domain/services/services.dart';
import 'package:rex_atlas/features/rexflex/rexflex.dart';

class _FakeLoans implements LoanOverviewService {
  LoanSnapshot value = const LoanSnapshot.none();
  final applied = <(int, int)>[];
  @override
  LoanSnapshot snapshot() => value;
  @override
  Future<LoanEligibility> checkEligibility() async =>
      const LoanEligibility(eligible: true, offerKobo: 300000);
  @override
  Future<void> apply({required int principalKobo, required int days}) async =>
      applied.add((principalKobo, days));
  @override
  Stream<LoanSnapshot> get approvals => const Stream.empty();
}

Future<void> pumpFor(WidgetTester t, [int ms = 1500]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

String lastText(AtlasController c) => c.messages
    .whereType<TextMessage>()
    .lastWhere((m) => m.author == ChatAuthor.assistant)
    .text;

List<SuggestionAction> lastCard(AtlasController c) =>
    (c.messages.last as SuggestionsMessage).suggestions
        .map((s) => s.action)
        .toList();

void main() {
  group('Atlas understands RexFlex questions', () {
    final ai = MockAtlasAssistantService(latency: Duration.zero);
    Future<RexFlexTopic?> topic(String t) async {
      final i = await ai.interpret(
        AssistantRequest(utterance: t, stage: ConversationStage.idle),
      );
      return i is RexFlexIntent ? i.topic : null;
    }

    test('topics', () async {
      expect(await topic('What is RexFlex?'), RexFlexTopic.overview);
      expect(await topic('Tell me about RexFlex'), RexFlexTopic.overview);
      expect(await topic('Get a RexFlex loan'), RexFlexTopic.getStarted);
      expect(await topic('I want to borrow money'), RexFlexTopic.getStarted);
      expect(
        await topic('Am I eligible for a loan?'),
        RexFlexTopic.eligibility,
      );
      expect(
        await topic('What is the interest on RexFlex?'),
        RexFlexTopic.pricing,
      );
      expect(await topic('How much can I borrow?'), RexFlexTopic.limits);
      expect(await topic('How do I repay my loan?'), RexFlexTopic.repay);
      expect(await topic('Is my loan approved?'), RexFlexTopic.status);
      // Follow-ups right after a RexFlex answer stay on RexFlex…
      Future<RexFlexTopic?> follow(String t) async {
        final i = await ai.interpret(
          AssistantRequest(
            utterance: t,
            stage: ConversationStage.discussingRexFlex,
          ),
        );
        return i is RexFlexIntent ? i.topic : null;
      }

      expect(await follow('How much does it cost?'), RexFlexTopic.pricing);
      expect(await follow('Am I eligible?'), RexFlexTopic.eligibility);
      expect(await follow('How do I repay?'), RexFlexTopic.repay);
      // …but other requests still work.
      expect(await follow('I want to send money'), isNull);
      expect(await follow('Buy airtime'), isNull);
      // Not about loans: unchanged behaviour.
      expect(await topic('Buy airtime'), isNull);
      expect(await topic('Send ₦3000 to GTB 0004218716'), isNull);
    });
  });

  group('Atlas answers from the real loan state', () {
    late AtlasController c;
    late _FakeLoans loans;
    setUp(() {
      c = AtlasController(AtlasDependencies.mock(latency: Duration.zero));
      loans = _FakeLoans();
      c.loans = loans;
    });
    tearDown(() => c.dispose());

    test('in-chat loan: eligibility → term → offer → apply', () async {
      await c.send('Get a RexFlex loan');
      final offerMsg = c.messages.whereType<TextMessage>().last;
      expect(
        offerMsg.text,
        contains("You're eligible! Your RexFlex offer is ₦3,000"),
      );
      expect(offerMsg.quickReplies, [
        '14 days · repay ₦3,112',
        '30 days · repay ₦3,240',
      ]);
      expect(c.stage, ConversationStage.awaitingLoanTerm);

      await c.send('14 days · repay ₦3,112');
      final offer = c.messages.whereType<LoanOfferMessage>().single;
      expect(offer.principalKobo, 300000);
      expect(offer.interestKobo, 11200);
      expect(offer.totalKobo, 311200);
      expect(c.stage, ConversationStage.awaitingLoanConsent);
      expect(c.messages.whereType<TextMessage>().last.quickReplies, [
        'Yes, apply',
        'Change term',
        'Cancel',
      ]);

      await c.send('Yes, apply');
      await Future<void>.delayed(Duration.zero);
      expect(loans.applied, [(300000, 14)]);
      expect(lastText(c), contains('Application received'));
      expect(lastCard(c), [SuggestionAction.rexflexViewLoan]);
      expect(offer.isActive, isFalse);
    });

    test('in-chat loan: change term, then cancel submits nothing', () async {
      await c.send('Get a RexFlex loan');
      await c.send('two weeks');
      await c.send('Change term');
      expect(c.stage, ConversationStage.awaitingLoanTerm);
      await c.send('a month');
      expect(c.messages.whereType<LoanOfferMessage>().last.interestKobo, 24000);
      await c.send('Cancel');
      expect(loans.applied, isEmpty);
      expect(lastText(c), contains("haven't submitted anything"));
      expect(c.stage, ConversationStage.idle);
    });

    test('without a loan link Atlas sends them to RexFlex', () async {
      c.loans = null;
      await c.send('Get a RexFlex loan');
      expect(lastCard(c), [SuggestionAction.rexflexStart]);
    });

    test('pricing uses 8% per 30 days, also as a follow-up', () async {
      await c.send('What is RexFlex?');
      await c.send('How much does it cost?');
      final reply = c.messages
          .whereType<TextMessage>()
          .lastWhere((m) => m.author == ChatAuthor.assistant)
          .text;
      expect(reply, contains('14 days: ₦112 interest, repay ₦3,112'));
      expect(reply, contains('30 days: ₦240 interest, repay ₦3,240'));
    });

    test('pending: reports the review step and offers to view', () async {
      loans.value = LoanSnapshot(
        state: LoanState.pending,
        nextOfferKobo: 300000,
        principalKobo: 300000,
        totalKobo: 311200,
        step: 2,
      );
      await c.send('Is my loan approved?');
      expect(lastText(c), contains('under review: step 2 of 4'));
      expect(lastCard(c), [SuggestionAction.rexflexViewLoan]);
    });

    test('active: repay reply gives balance and due date', () async {
      loans.value = LoanSnapshot(
        state: LoanState.active,
        nextOfferKobo: 300000,
        principalKobo: 300000,
        totalKobo: 311200,
        outstandingKobo: 161200,
        dueDate: DateTime(2026, 12, 4),
      );
      await c.send('How do I repay my loan?');
      expect(lastText(c), contains('₦1,612 left to repay by 04 Dec 2026'));
      await c.send('Get a RexFlex loan');
      expect(lastText(c), contains('already have an active RexFlex loan'));
    });

    test('the card asks the host to open RexFlex', () async {
      final events = <AtlasEvent>[];
      final sub = c.events.listen(events.add);
      await c.send('What is RexFlex?');
      final card = (c.messages.last as SuggestionsMessage).suggestions.single;
      await c.sendSuggestion(card);
      await Future<void>.delayed(Duration.zero);
      expect(
        events.whereType<OpenRexFlexEvent>().single.destination,
        RexFlexDestination.start,
      );
      await sub.cancel();
    });
  });

  Future<void> openApp(WidgetTester t) async {
    t.view.physicalSize = const Size(402, 874);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      RexAtlasDemoApp(
        dependencies: AtlasDependencies.mock(latency: Duration.zero),
        now: DateTime(2026, 11, 20, 9),
        rexflexService: MockRexFlexService(
          stageDelay: const Duration(milliseconds: 1100),
        ),
      ),
    );
    await t.pump();
    await t.tap(find.byKey(const Key('home-ask-atlas')));
    await pumpFor(t, 600);
  }

  testWidgets('get a RexFlex loan entirely in Atlas, then approval in chat', (
    t,
  ) async {
    await openApp(t);
    final pill = find.byKey(const Key('welcome-action-Get a Loan'));
    await t.ensureVisible(pill);
    await pumpFor(t, 300);
    await t.tap(pill);
    await pumpFor(t, 2500);
    expect(find.textContaining("You're eligible!"), findsOneWidget);

    await t.tap(find.text('14 days · repay ₦3,112'));
    await pumpFor(t);
    expect(find.text('RexFlex Loan'), findsOneWidget);
    expect(find.text('Total to repay'), findsOneWidget);
    expect(find.text('₦3,112.00'), findsOneWidget);

    await t.tap(find.text('Yes, apply'));
    await pumpFor(t, 1500);
    expect(find.textContaining('Application received'), findsOneWidget);

    // Background review (shortened here) → approval posted in the chat,
    // not as a separate notice while Atlas is open.
    await pumpFor(t, 4000);
    expect(
      find.textContaining('was approved and sent to your Rex account'),
      findsOneWidget,
    );
    expect(find.text('Your RexFlex loan of ₦3,000 was approved'), findsNothing);

    // "View my loan" closes Atlas and opens the loan in RexFlex.
    await t.tap(find.text('View my loan').last);
    await pumpFor(t, 1500);
    expect(find.byKey(const Key('flex-repay-loan')), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('RexFlex card from an answer opens the intro', (t) async {
    await openApp(t);
    await t.enterText(
      find.byKey(const Key('atlas-composer-field')),
      'What is RexFlex?',
    );
    await t.pump();
    await t.tap(find.byKey(const Key('atlas-send-button')));
    await pumpFor(t);
    expect(find.text('Get started with RexFlex'), findsOneWidget);
    await t.tap(find.text('Get started with RexFlex'));
    await pumpFor(t, 1200);
    expect(find.text('Earn your flex'), findsOneWidget);
  });
}
