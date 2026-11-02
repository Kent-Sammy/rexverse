import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/formatting/naira.dart';
import '../domain/models/models.dart';
import '../domain/services/services.dart';
import 'atlas_dependencies.dart';
import 'atlas_events.dart';

export 'atlas_events.dart';

/// Conversation + task-flow state for Rex Atlas.
///
/// Flow for payments (mirrors the Figma sequence):
/// collect details → review card → "Shall I go ahead?" → confirmation card +
/// biometric prompt → processing → result card → follow-up suggestions.
///
/// The assistant service only interprets text. Payment outcomes always come
/// from [TransferService] / [AirtimeService].
class AtlasController extends ChangeNotifier {
  AtlasController(this.deps) {
    unawaited(_loadAccount());
  }

  final AtlasDependencies deps;

  final List<ChatMessage> _messages = [];

  /// Design-review only: replaces the visible transcript (state is kept)
  /// so a Figma frame can be reproduced exactly. See `lib/app/design_scenes.dart`.
  @visibleForTesting
  void debugSetMessages(List<ChatMessage> messages) {
    _messages
      ..clear()
      ..addAll(messages);
    _notify();
  }

  /// Design-review only: initial scroll offset for the chat list instead of
  /// scrolling to the newest message. Leave null in production.
  double? debugInitialScrollOffset;
  final _events = StreamController<AtlasEvent>.broadcast();
  int _ids = 0;
  bool _busy = false;
  bool _disposed = false;
  ConversationStage _stage = ConversationStage.idle;
  SourceAccount? _account;

  _TransferSlots _transfer = _TransferSlots();
  _AirtimeSlots _airtime = _AirtimeSlots();
  PaymentDraft? _pending;
  PaymentConfirmationMessage? _confirmation;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// When the first message was sent (shown as "Today 9:41 AM").
  DateTime? get conversationStartedAt => _startedAt;
  DateTime? _startedAt;
  bool get hasConversation => _messages.isNotEmpty;
  bool get isBusy => _busy;
  ConversationStage get stage => _stage;
  PaymentDraft? get pendingPayment => _pending;
  SourceAccount? get account => _account;
  Stream<AtlasEvent> get events => _events.stream;
  TransactionRecord? get latestTransfer => deps.history.latestTransfer;

  static const defaultSuggestions = <Suggestion>[
    Suggestion(
      action: SuggestionAction.save,
      title: 'Save ',
      boldSuffix: '₦50,000',
      subtitle: 'Grow  your money with RexSave',
    ),
    Suggestion(
      action: SuggestionAction.payBill,
      title: 'Pay A Bill',
      subtitle: 'Electricity, TV, Internet and more',
    ),
    Suggestion(
      action: SuggestionAction.rexyDecember,
      title: 'Get Started With Rexy December',
      subtitle: 'Get 5% upfront on deposits',
    ),
  ];

  // ---------------------------------------------------------------- inputs

  /// Sends a user message and lets the assistant respond.
  Future<void> send(String text) async {
    final t = text.trim();
    if (t.isEmpty || _busy) return;
    _add(TextMessage(id: _id(), author: ChatAuthor.user, text: t));
    await _respondTo(t);
  }

  Future<void> sendSuggestion(Suggestion s) => send(switch (s.action) {
    SuggestionAction.save => 'Save ${s.boldSuffix ?? ''}'.trim(),
    _ => s.title,
  });

  /// Re-runs the request behind an [ErrorMessage].
  Future<void> retry(ErrorMessage error) async {
    if (_busy || error.retryText == null) return;
    _messages.remove(error);
    _notify();
    await _respondTo(error.retryText!);
  }

  /// Called by the biometric sheet. Returns when authorisation completes;
  /// the payment then executes in the background.
  Future<void> authorizeWithBiometrics() async {
    final draft = _pending;
    if (draft == null) return;
    final token = await deps.authorization.authorizeWithBiometrics(
      purpose: draft.kind == PaymentKind.transfer ? 'transfer' : 'airtime',
    );
    unawaited(_execute(draft, token));
  }

  /// The user closed the biometric prompt without authorising.
  void authorizationDismissed() {
    if (_pending == null || _stage != ConversationStage.awaitingAuthorization) {
      return;
    }
    _stage = ConversationStage.awaitingPaymentConfirmation;
    _say(
      "No problem, I haven't sent anything. Tap continue when you're ready.",
      quickReplies: const ['Continue', 'Cancel'],
    );
  }

  void viewReceipt(String reference) =>
      _events.add(OpenReceiptEvent(reference));

  Future<void> makeAnotherTransfer() => send('Make another transfer');

  // ------------------------------------------------------------ assistant

  Future<void> _respondTo(String utterance) async {
    _setBusy(true);
    final typing = _showTyping();
    AssistantIntent intent;
    try {
      intent = await deps.assistant.interpret(
        AssistantRequest(utterance: utterance, stage: _stage),
      );
    } on AssistantUnavailableException {
      _remove(typing);
      _add(
        ErrorMessage(
          id: _id(),
          text: "I'm having trouble connecting right now. Please try again.",
          retryText: utterance,
        ),
      );
      _setBusy(false);
      return;
    }
    _remove(typing);
    try {
      await _handle(intent);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _handle(AssistantIntent intent) async {
    switch (intent) {
      case StartTransferIntent():
        await _handleTransfer(intent);
      case StartAirtimeIntent():
        await _handleAirtime(intent);
      case ChangeAmountIntent(:final amountKobo):
        await _changeAmount(amountKobo);
      case ConfirmIntent():
        _confirm();
      case CancelIntent():
        _cancel();
      case ShowTransactionsIntent():
        await _showTransactions();
      case ShowSuggestionsIntent():
        _showSuggestions();
      case UnsupportedFeatureIntent(:final featureName):
        _say(
          "$featureName through Atlas isn't available in this prototype yet. "
          'I can send money, buy airtime or show your recent transactions.',
        );
      case ReplyIntent(:final text):
        _say(text);
    }
  }

  // -------------------------------------------------------------- transfer

  Future<void> _handleTransfer(StartTransferIntent i) async {
    if (_stage != ConversationStage.awaitingTransferDetails) {
      _deactivatePending();
      _transfer = _TransferSlots();
    }
    _transfer.merge(i);
    _stage = ConversationStage.awaitingTransferDetails;

    final s = _transfer;
    if (s.accountNumber == null && s.bankQuery == null) {
      _say('Which account do you want to send money to?');
      return;
    }
    if (s.bankQuery == null) {
      _say('Which bank is ${s.accountNumber} with?');
      return;
    }
    final bank = await deps.beneficiaries.findBank(s.bankQuery!);
    if (bank == null) {
      s.bankQuery = null;
      _say("I don't recognise that bank. Which bank should I send to?");
      return;
    }
    if (s.accountNumber == null) {
      _say('What is the ${bank.shortName} account number?');
      return;
    }

    if (s.beneficiary == null ||
        s.beneficiary!.accountNumber != s.accountNumber ||
        s.beneficiary!.bank.code != bank.code) {
      final typing = _showTyping(label: 'Checking account details…');
      try {
        s.beneficiary = await deps.beneficiaries.resolveAccount(
          bank: bank,
          accountNumber: s.accountNumber!,
        );
      } on BeneficiaryNotFoundException catch (e) {
        _remove(typing);
        s.accountNumber = null;
        _say('${e.message} Please check the account number and try again.');
        return;
      }
      _remove(typing);
    }

    if (s.amountKobo == null) {
      _say('How much would you like to send to ${s.beneficiary!.accountName}?');
      return;
    }

    final fee = await deps.transfers.quoteFeeKobo(
      amountKobo: s.amountKobo!,
      bank: bank,
    );
    final draft = TransferDraft(
      amountKobo: s.amountKobo!,
      feeKobo: fee,
      beneficiary: s.beneficiary!,
      source: await _sourceAccount(),
    );
    _presentReview(
      draft,
      intro: 'Got it. I found the account details please review and confirm.',
    );
  }

  // --------------------------------------------------------------- airtime

  Future<void> _handleAirtime(StartAirtimeIntent i) async {
    if (_stage != ConversationStage.awaitingAirtimeDetails) {
      _deactivatePending();
      _airtime = _AirtimeSlots();
    }
    _airtime.merge(i);
    _stage = ConversationStage.awaitingAirtimeDetails;

    final s = _airtime;
    if (s.phoneNumber == null && s.amountKobo == null) {
      _say('Which phone number should I top up, and how much airtime?');
      return;
    }
    if (s.phoneNumber == null) {
      _say('Which phone number should I top up?');
      return;
    }
    if (s.amountKobo == null) {
      _say('How much airtime would you like to buy for ${s.phoneNumber}?');
      return;
    }
    if (s.amountKobo! < 5000 || s.amountKobo! > 5000000) {
      s.amountKobo = null;
      _say(
        'Airtime must be between ₦50 and ₦50,000. How much would you like to buy?',
      );
      return;
    }
    final network =
        s.network ?? await deps.airtime.detectNetwork(s.phoneNumber!);
    final draft = AirtimeDraft(
      amountKobo: s.amountKobo!,
      feeKobo: 0,
      phoneNumber: s.phoneNumber!,
      network: network,
      source: await _sourceAccount(),
    );
    _presentReview(
      draft,
      intro: 'Got it. Please review and confirm this airtime purchase.',
    );
  }

  // ------------------------------------------------------- shared payment

  void _presentReview(PaymentDraft draft, {required String intro}) {
    _deactivatePending();
    _pending = draft;
    _confirmation = null;
    _stage = ConversationStage.awaitingPaymentConfirmation;
    _say(intro);
    _add(PaymentReviewMessage(id: _id(), draft: draft));
    _say(
      'Shall I go ahead?',
      quickReplies: const ['Yes, continue please', 'Cancel'],
    );
  }

  Future<void> _changeAmount(int amountKobo) async {
    final p = _pending;
    if (p == null) {
      _say("There's no payment in progress to change.");
      return;
    }
    switch (p) {
      case TransferDraft():
        final fee = await deps.transfers.quoteFeeKobo(
          amountKobo: amountKobo,
          bank: p.beneficiary.bank,
        );
        _presentReview(
          p.copyWith(amountKobo: amountKobo, feeKobo: fee),
          intro: "Done. I've updated the amount to ${Naira.plain(amountKobo)}.",
        );
      case AirtimeDraft():
        _presentReview(
          p.copyWith(amountKobo: amountKobo),
          intro: "Done. I've updated the amount to ${Naira.plain(amountKobo)}.",
        );
    }
  }

  void _confirm() {
    final p = _pending;
    if (p == null) {
      _say("There's nothing waiting for your confirmation right now.");
      return;
    }
    _stage = ConversationStage.awaitingAuthorization;
    if (_confirmation == null) {
      _say(
        p.kind == PaymentKind.transfer
            ? 'Please confirm with your biometrics to complete this transfer'
            : 'Please confirm with your biometrics to complete this purchase',
      );
      _confirmation = PaymentConfirmationMessage(id: _id(), draft: p);
      _add(_confirmation!);
    }
    _events.add(RequestAuthorizationEvent(p));
  }

  void _cancel() {
    final p = _pending;
    final collecting =
        _stage == ConversationStage.awaitingTransferDetails ||
        _stage == ConversationStage.awaitingAirtimeDetails;
    _deactivatePending();
    if (_confirmation != null) {
      _messages.remove(_confirmation);
      _confirmation = null;
    }
    _pending = null;
    _transfer = _TransferSlots();
    _airtime = _AirtimeSlots();
    _stage = ConversationStage.idle;
    if (p != null || collecting) {
      _say(
        p?.kind == PaymentKind.airtime
            ? "Okay, I've cancelled the airtime purchase. Nothing was charged."
            : "Okay, I've cancelled this transfer. No money was sent.",
      );
    } else {
      _say('Okay. Anything else I can help with?');
    }
  }

  Future<void> _execute(PaymentDraft draft, AuthorizationToken token) async {
    _setBusy(true);
    if (_confirmation != null) {
      _messages.remove(_confirmation);
      _confirmation = null;
    }
    final typing = _showTyping(
      label: draft.kind == PaymentKind.transfer
          ? 'Processing your transfer…'
          : 'Processing your purchase…',
    );
    PaymentResult result;
    try {
      result = switch (draft) {
        TransferDraft() => await deps.transfers.execute(draft, token),
        AirtimeDraft() => await deps.airtime.purchase(draft, token),
      };
    } catch (_) {
      _remove(typing);
      _stage = ConversationStage.awaitingPaymentConfirmation;
      _add(
        ErrorMessage(
          id: _id(),
          text:
              "I couldn't reach the payment service, so nothing was sent. "
              'You can try again.',
        ),
      );
      _say(
        'Shall I try again?',
        quickReplies: const ['Yes, continue please', 'Cancel'],
      );
      _setBusy(false);
      return;
    }
    _pending = null;
    _transfer = _TransferSlots();
    _airtime = _AirtimeSlots();
    _stage = ConversationStage.idle;
    Receipt? receipt;
    if (result.isSuccessful) {
      try {
        receipt = await deps.receipts.receiptFor(result.reference);
      } on Object {
        receipt = null; // Card still shows the outcome; receipt can be retried.
      }
    }
    _remove(typing);
    _add(PaymentResultMessage(id: _id(), result: result, receipt: receipt));
    if (result.isSuccessful) {
      _showSuggestions();
    } else {
      _say(
        "The payment didn't go through, and no money left your account. "
        'You can try a smaller amount.',
      );
    }
    _setBusy(false);
  }

  // ---------------------------------------------------------------- other

  Future<void> _showTransactions() async {
    final typing = _showTyping();
    final records = await deps.history.recent(limit: 4);
    _remove(typing);
    if (records.isEmpty) {
      _say("You don't have any transactions yet.");
      return;
    }
    _say('Here are your recent transactions');
    _add(TransactionsMessage(id: _id(), transactions: records));
  }

  void _showSuggestions() {
    _say('Here are a few things you might want to do next.');
    _add(SuggestionsMessage(id: _id(), suggestions: defaultSuggestions));
  }

  // -------------------------------------------------------------- helpers

  Future<SourceAccount> _sourceAccount() async =>
      _account ??= await deps.accounts.primaryAccount();

  Future<void> _loadAccount() async {
    _account = await deps.accounts.primaryAccount();
    _notify();
  }

  void _deactivatePending() {
    for (final m in _messages.whereType<PaymentReviewMessage>()) {
      m.isActive = false;
    }
    _deactivateQuickReplies();
  }

  TypingMessage _showTyping({String? label}) {
    final t = TypingMessage(id: _id(), label: label);
    _add(t);
    return t;
  }

  void _say(String text, {List<String> quickReplies = const []}) {
    if (quickReplies.isEmpty) {
      // Older quick replies no longer apply once the conversation moves on.
      _deactivateQuickReplies();
    }
    _add(
      TextMessage(
        id: _id(),
        author: ChatAuthor.assistant,
        text: text,
        quickReplies: quickReplies,
      ),
    );
  }

  void _deactivateQuickReplies() {
    for (var i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      if (m is TextMessage && m.quickReplies.isNotEmpty) {
        _messages[i] = TextMessage(id: m.id, author: m.author, text: m.text);
      }
    }
  }

  void _add(ChatMessage m) {
    if (m.author == ChatAuthor.user) _deactivateQuickReplies();
    _startedAt ??= DateTime.now();
    _messages.add(m);
    _notify();
  }

  void _remove(ChatMessage m) {
    _messages.remove(m);
    _notify();
  }

  void _setBusy(bool v) {
    _busy = v;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String _id() => 'm${_ids++}';

  @override
  void dispose() {
    _disposed = true;
    _events.close();
    super.dispose();
  }
}

class _TransferSlots {
  int? amountKobo;
  String? bankQuery;
  String? accountNumber;
  Beneficiary? beneficiary;

  void merge(StartTransferIntent i) {
    amountKobo = i.amountKobo ?? amountKobo;
    bankQuery = i.bankQuery ?? bankQuery;
    accountNumber = i.accountNumber ?? accountNumber;
  }
}

class _AirtimeSlots {
  int? amountKobo;
  String? phoneNumber;
  String? network;

  void merge(StartAirtimeIntent i) {
    amountKobo = i.amountKobo ?? amountKobo;
    phoneNumber = i.phoneNumber ?? phoneNumber;
    network = i.network ?? network;
  }
}
