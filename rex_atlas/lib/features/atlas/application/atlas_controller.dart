import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/formatting/dates.dart';
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
  _SavingsSlots _savings = _SavingsSlots();
  _VaultSlots _vault = _VaultSlots();
  _BillSlots _bill = _BillSlots();
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
      subtitle: 'Grow your money with RexSave',
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

  /// Adds a user attachment. Reading documents needs a real document /
  /// vision backend, so the mock assistant says so rather than pretending.
  Future<void> sendAttachment({
    required String fileName,
    required int sizeBytes,
    required bool isImage,
    Uint8List? imageBytes,
  }) async {
    if (_busy) return;
    _add(
      AttachmentMessage(
        id: _id(),
        fileName: fileName,
        sizeBytes: sizeBytes,
        isImage: isImage,
        imageBytes: imageBytes,
      ),
    );
    _setBusy(true);
    final typing = _showTyping();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _remove(typing);
    _say(
      "Thanks, I've received ${isImage ? 'your image' : '“$fileName”'}. "
      "Reading ${isImage ? 'images' : 'documents'} isn't available in this "
      "prototype yet, so nothing was processed. Tell me what you'd like to do "
      'and I can help.',
    );
    _setBusy(false);
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
      purpose: _noun(draft.kind),
    );
    unawaited(_execute(draft, token));
  }

  /// Called by the PIN pad. Rethrows [IncorrectPinException] /
  /// [PinLockedException] so the pad can show the error.
  Future<void> authorizeWithPin(String pin) async {
    final draft = _pending;
    if (draft == null) return;
    final token = await deps.authorization.authorizeWithPin(
      pin: pin,
      purpose: _noun(draft.kind),
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
      case StartSavingsIntent():
        await _handleSavings(intent);
      case StartVaultIntent():
        await _handleVault(intent);
      case StartBillIntent():
        await _handleBill(intent);
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
          'I can send money, buy airtime, pay bills, save with RexSave or '
          'RexVault, or show your recent transactions.',
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

  // --------------------------------------------------------------- savings

  Future<void> _handleSavings(StartSavingsIntent i) async {
    if (_stage != ConversationStage.awaitingSavingsDetails) {
      _deactivatePending();
      _savings = _SavingsSlots();
    }
    _savings.merge(i);
    _stage = ConversationStage.awaitingSavingsDetails;
    final s = _savings;
    final plan = s.plan ?? SavingsPlan.rexSave;
    if (s.amountKobo == null) {
      final sample = await deps.savings.quote(plan, 10000);
      _say(
        plan == SavingsPlan.rexyDecember
            ? 'Rexy December gives you ${(sample.bonusKobo / 100).toStringAsFixed(0)}% '
                  'upfront on deposits, locked until December 31. How much would you like to save?'
            : 'RexSave earns ${sample.annualRatePct.toStringAsFixed(0)}% a year and you can '
                  'withdraw any time. How much would you like to save?',
        quickReplies: const ['₦5,000', '₦10,000', '₦50,000'],
      );
      return;
    }
    final min = deps.savings.minDepositKobo(plan);
    if (s.amountKobo! < min) {
      s.amountKobo = null;
      _say(
        'The minimum ${plan.displayName} deposit is ${Naira.groupedWhole(min)}. '
        'How much would you like to save?',
      );
      return;
    }
    final q = await deps.savings.quote(plan, s.amountKobo!);
    _presentReview(
      SavingsDraft(
        amountKobo: s.amountKobo!,
        feeKobo: 0,
        plan: plan,
        source: await _sourceAccount(),
        annualRatePct: q.annualRatePct,
        bonusKobo: q.bonusKobo,
        lockedUntil: q.lockedUntil,
      ),
      intro: 'Great. Please review your ${plan.displayName} deposit.',
    );
  }

  // ----------------------------------------------------------------- vault

  static String _tenorLabel(int days) => switch (days) {
    365 => '1 year',
    30 => '1 month',
    _ => '${days ~/ 30} months',
  };

  Future<void> _handleVault(StartVaultIntent i) async {
    if (_stage != ConversationStage.awaitingVaultDetails) {
      _deactivatePending();
      _vault = _VaultSlots();
    }
    _vault.merge(i);
    _stage = ConversationStage.awaitingVaultDetails;
    final s = _vault;
    final v = deps.vault;
    final rate = v.rates.values.first.toStringAsFixed(0);
    if (s.amountKobo == null) {
      _say(
        'How much do you want to save in RexVault? Your savings earn $rate% '
        'a year and stay locked until the date you choose. The minimum is '
        '${Naira.groupedWhole(v.minLockKobo)}.',
        quickReplies: const ['₦50,000', '₦100,000', '₦500,000'],
      );
      return;
    }
    if (s.amountKobo! < v.minLockKobo) {
      s.amountKobo = null;
      _say(
        'The minimum RexVault savings is ${Naira.groupedWhole(v.minLockKobo)}. '
        'How much do you want to save?',
      );
      return;
    }
    if (s.tenorDays != null && !v.rates.containsKey(s.tenorDays)) {
      s.tenorDays = null;
      _say('You can save in RexVault for 1, 3 or 6 months, or 1 year.');
    }
    if (s.tenorDays == null) {
      // Work out the earnings for every period so the user can compare.
      final options = <String>[];
      for (final days in v.rates.keys) {
        final q = await v.quote(amountKobo: s.amountKobo!, tenorDays: days);
        options.add(
          '${_tenorLabel(days)} · earn ${Naira.groupedWhole(q.interestKobo)}',
        );
      }
      _say(
        'At $rate% a year, here is what ${Naira.groupedWhole(s.amountKobo!)} '
        'would earn. How long do you want to save for?',
        quickReplies: options,
      );
      return;
    }
    final q = await v.quote(amountKobo: s.amountKobo!, tenorDays: s.tenorDays!);
    _presentReview(
      VaultDraft(
        amountKobo: s.amountKobo!,
        feeKobo: 0,
        tenorDays: s.tenorDays!,
        annualRatePct: q.annualRatePct,
        interestKobo: q.interestKobo,
        maturity: q.maturity,
        source: await _sourceAccount(),
      ),
      intro:
          "Here's your RexVault savings plan. You'll get back "
          '${Naira.grouped(s.amountKobo! + q.interestKobo)} on '
          '${RexDates.short(q.maturity)}. The money stays locked until then.',
    );
  }

  // ----------------------------------------------------------------- bills

  Future<void> _handleBill(StartBillIntent i) async {
    if (_stage != ConversationStage.awaitingBillDetails) {
      _deactivatePending();
      _bill = _BillSlots();
    }
    final s = _bill;
    s.merge(i);
    _stage = ConversationStage.awaitingBillDetails;
    final bills = deps.bills;

    if (s.billerQuery != null &&
        (s.biller == null ||
            s.biller!.shortName.toLowerCase() != s.billerQuery)) {
      final found = await bills.findBiller(s.billerQuery!);
      if (found != null && found.id != s.biller?.id) {
        s
          ..biller = found
          ..category = found.category
          ..customer = null
          ..package = null;
      }
    }
    if (s.category == null) {
      _say(
        'Which bill would you like to pay?',
        quickReplies: [for (final c in BillCategory.values) c.displayName],
      );
      return;
    }
    final biller = s.biller;
    if (biller == null) {
      final list = await bills.billers(s.category!);
      _say(
        s.category == BillCategory.electricity
            ? 'Which electricity company?'
            : 'Which ${s.category!.displayName.toLowerCase()} provider?',
        quickReplies: [for (final b in list) b.shortName],
      );
      return;
    }
    if (s.customerId == null) {
      _say('What is your ${biller.shortName} ${biller.customerIdLabel}?');
      return;
    }
    if (s.customer == null || s.checkedId != s.customerId) {
      final typing = _showTyping(label: 'Checking ${biller.customerIdLabel}…');
      try {
        s.customer = await bills.validateCustomer(biller, s.customerId!);
        s.checkedId = s.customerId;
      } on BillCustomerNotFoundException catch (e) {
        _remove(typing);
        s.customerId = null;
        _say('${e.message} Please check it and try again.');
        return;
      }
      _remove(typing);
    }

    int amount;
    BillPackage? package;
    if (biller.hasPackages) {
      final list = await bills.packages(biller);
      if (s.package == null && s.packageQuery != null) {
        final q = s.packageQuery!.toLowerCase();
        final sorted = [...list]
          ..sort((a, b) => b.name.length.compareTo(a.name.length));
        for (final p in sorted) {
          if (q.contains(p.name.toLowerCase())) {
            s.package = p;
            break;
          }
        }
      }
      if (s.package == null) {
        _say(
          'Which ${biller.shortName} package?',
          quickReplies: [
            for (final p in list)
              '${p.name} · ${Naira.groupedWhole(p.amountKobo)}',
          ],
        );
        return;
      }
      package = s.package;
      amount = package!.amountKobo;
    } else {
      if (s.amountKobo == null) {
        _say(
          'How much electricity would you like to buy? '
          '(${Naira.groupedWhole(biller.minAmountKobo)} to ${Naira.groupedWhole(biller.maxAmountKobo)})',
          quickReplies: const ['₦2,000', '₦5,000', '₦10,000'],
        );
        return;
      }
      if (s.amountKobo! < biller.minAmountKobo ||
          s.amountKobo! > biller.maxAmountKobo) {
        s.amountKobo = null;
        _say(
          '${biller.shortName} payments must be between '
          '${Naira.groupedWhole(biller.minAmountKobo)} and '
          '${Naira.groupedWhole(biller.maxAmountKobo)}. How much would you like to pay?',
        );
        return;
      }
      amount = s.amountKobo!;
    }
    _presentReview(
      BillDraft(
        amountKobo: amount,
        feeKobo: 0,
        biller: biller,
        customerId: s.customerId!,
        customer: s.customer!,
        source: await _sourceAccount(),
        package: package,
      ),
      intro:
          "Got it. I've verified the ${biller.customerIdLabel}. Please review and confirm.",
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
      case SavingsDraft():
        final q = await deps.savings.quote(p.plan, amountKobo);
        _presentReview(
          p.copyWith(amountKobo: amountKobo, bonusKobo: q.bonusKobo),
          intro: "Done. I've updated the amount to ${Naira.plain(amountKobo)}.",
        );
      case VaultDraft():
        final q = await deps.vault.quote(
          amountKobo: amountKobo,
          tenorDays: p.tenorDays,
        );
        _presentReview(
          VaultDraft(
            amountKobo: amountKobo,
            feeKobo: p.feeKobo,
            tenorDays: p.tenorDays,
            annualRatePct: q.annualRatePct,
            interestKobo: q.interestKobo,
            maturity: q.maturity,
            source: p.source,
          ),
          intro: "Done. I've updated the amount to ${Naira.plain(amountKobo)}.",
        );
      case BillDraft():
        if (p.package != null) {
          _say(
            'The price is set by the ${p.biller.shortName} ${p.package!.name} package. '
            'You can cancel and choose a different package.',
          );
          return;
        }
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
        'Please confirm with your biometrics to complete this ${_noun(p.kind)}',
      );
      _confirmation = PaymentConfirmationMessage(id: _id(), draft: p);
      _add(_confirmation!);
    }
    _events.add(RequestAuthorizationEvent(p));
  }

  void _cancel() {
    final p = _pending;
    final stage = _stage;
    final collecting = const {
      ConversationStage.awaitingTransferDetails,
      ConversationStage.awaitingAirtimeDetails,
      ConversationStage.awaitingSavingsDetails,
      ConversationStage.awaitingVaultDetails,
      ConversationStage.awaitingBillDetails,
    }.contains(stage);
    _deactivatePending();
    if (_confirmation != null) {
      _messages.remove(_confirmation);
      _confirmation = null;
    }
    _pending = null;
    _resetSlots();
    _stage = ConversationStage.idle;
    if (p != null || collecting) {
      final kind =
          p?.kind ??
          switch (stage) {
            ConversationStage.awaitingAirtimeDetails => PaymentKind.airtime,
            ConversationStage.awaitingSavingsDetails => PaymentKind.savings,
            ConversationStage.awaitingVaultDetails => PaymentKind.vault,
            ConversationStage.awaitingBillDetails => PaymentKind.bill,
            _ => PaymentKind.transfer,
          };
      _say(switch (kind) {
        PaymentKind.transfer =>
          "Okay, I've cancelled this transfer. No money was sent.",
        PaymentKind.airtime =>
          "Okay, I've cancelled the airtime purchase. Nothing was charged.",
        PaymentKind.savings =>
          "Okay, I've cancelled the deposit. Nothing was moved.",
        PaymentKind.vault =>
          "Okay, I've cancelled. Nothing was saved to RexVault.",
        PaymentKind.bill =>
          "Okay, I've cancelled the bill payment. Nothing was charged.",
      });
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
    final typing = _showTyping(label: 'Processing your ${_noun(draft.kind)}…');
    PaymentResult result;
    try {
      result = switch (draft) {
        TransferDraft() => await deps.transfers.execute(draft, token),
        AirtimeDraft() => await deps.airtime.purchase(draft, token),
        SavingsDraft() => await deps.savings.deposit(draft, token),
        VaultDraft() => await deps.vault.lock(draft, token),
        BillDraft() => await deps.bills.pay(draft, token),
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
    _resetSlots();
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

  static String _noun(PaymentKind k) => switch (k) {
    PaymentKind.transfer => 'transfer',
    PaymentKind.airtime => 'purchase',
    PaymentKind.savings => 'deposit',
    PaymentKind.vault => 'lock',
    PaymentKind.bill => 'payment',
  };

  void _resetSlots() {
    _transfer = _TransferSlots();
    _airtime = _AirtimeSlots();
    _savings = _SavingsSlots();
    _vault = _VaultSlots();
    _bill = _BillSlots();
  }

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

class _SavingsSlots {
  int? amountKobo;
  SavingsPlan? plan;

  void merge(StartSavingsIntent i) {
    amountKobo = i.amountKobo ?? amountKobo;
    plan = i.plan ?? plan;
  }
}

class _VaultSlots {
  int? amountKobo;
  int? tenorDays;

  void merge(StartVaultIntent i) {
    amountKobo = i.amountKobo ?? amountKobo;
    tenorDays = i.tenorDays ?? tenorDays;
  }
}

class _BillSlots {
  BillCategory? category;
  String? billerQuery;
  Biller? biller;
  String? customerId;
  String? checkedId;
  BillCustomer? customer;
  BillPackage? package;
  String? packageQuery;
  int? amountKobo;

  void merge(StartBillIntent i) {
    if (i.category != null && i.category != category) {
      category = i.category;
      if (biller != null && biller!.category != category) {
        biller = null;
        customer = null;
        package = null;
      }
    }
    billerQuery = i.billerQuery ?? billerQuery;
    if (i.customerId != null) customerId = i.customerId;
    amountKobo = i.amountKobo ?? amountKobo;
    packageQuery = i.packageQuery;
  }
}
