import 'products.dart';

/// What the AI service understood from a user utterance.
///
/// The AI layer only *interprets*; it never executes payments or reports
/// their outcome. The controller turns intents into service calls.
sealed class AssistantIntent {
  const AssistantIntent();
}

class StartTransferIntent extends AssistantIntent {
  const StartTransferIntent({
    this.amountKobo,
    this.bankQuery,
    this.accountNumber,
  });
  final int? amountKobo;
  final String? bankQuery;
  final String? accountNumber;
  bool get isComplete =>
      amountKobo != null && bankQuery != null && accountNumber != null;
}

class StartAirtimeIntent extends AssistantIntent {
  const StartAirtimeIntent({this.amountKobo, this.phoneNumber, this.network});
  final int? amountKobo;
  final String? phoneNumber;
  final String? network;
  bool get isComplete => amountKobo != null && phoneNumber != null;
}

class StartSavingsIntent extends AssistantIntent {
  const StartSavingsIntent({this.amountKobo, this.plan});
  final int? amountKobo;
  final SavingsPlan? plan;
}

class StartVaultIntent extends AssistantIntent {
  const StartVaultIntent({this.amountKobo, this.tenorDays});
  final int? amountKobo;
  final int? tenorDays;
}

class StartBillIntent extends AssistantIntent {
  const StartBillIntent({
    this.category,
    this.billerQuery,
    this.customerId,
    this.amountKobo,
    this.packageQuery,
  });
  final BillCategory? category;
  final String? billerQuery;
  final String? customerId;
  final int? amountKobo;

  /// Raw text to match against the biller's package names.
  final String? packageQuery;
}

class ChangeAmountIntent extends AssistantIntent {
  const ChangeAmountIntent(this.amountKobo);
  final int amountKobo;
}

class ConfirmIntent extends AssistantIntent {
  const ConfirmIntent();
}

class CancelIntent extends AssistantIntent {
  const CancelIntent();
}

class ShowTransactionsIntent extends AssistantIntent {
  const ShowTransactionsIntent();
}

class ShowSuggestionsIntent extends AssistantIntent {
  const ShowSuggestionsIntent();
}

/// A capability that appears in the designs but has no designed flow yet
/// (Save, Pay Bills, Rexy December).
class UnsupportedFeatureIntent extends AssistantIntent {
  const UnsupportedFeatureIntent(this.featureName);
  final String featureName;
}

/// What the customer asked about RexFlex (short-term loans).
enum RexFlexTopic {
  overview,
  getStarted,
  eligibility,
  pricing,
  limits,
  repay,
  status,
}

class RexFlexIntent extends AssistantIntent {
  const RexFlexIntent(this.topic);
  final RexFlexTopic topic;
}

/// The customer picked a RexFlex tenor in the chat ("14 days"). `0` means
/// "show me the options again".
class ChooseLoanTermIntent extends AssistantIntent {
  const ChooseLoanTermIntent(this.days);
  final int days;
}

/// Free-form reply (greetings, help, fallback).
class ReplyIntent extends AssistantIntent {
  const ReplyIntent(this.text);
  final String text;
}
