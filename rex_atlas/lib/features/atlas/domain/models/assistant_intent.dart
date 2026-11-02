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

/// Free-form reply (greetings, help, fallback).
class ReplyIntent extends AssistantIntent {
  const ReplyIntent(this.text);
  final String text;
}
