import '../models/models.dart';

/// Conversation stage passed to the assistant so it can resolve short
/// replies like "yes" or "change it to 5000".
enum ConversationStage {
  idle,
  awaitingTransferDetails,
  awaitingAirtimeDetails,
  awaitingSavingsDetails,
  awaitingVaultDetails,
  awaitingBillDetails,
  awaitingPaymentConfirmation,
  awaitingAuthorization,

  /// Getting a RexFlex loan in the chat: choosing 14 or 30 days, then
  /// accepting the offer.
  awaitingLoanTerm,
  awaitingLoanConsent,

  /// The last answer was about RexFlex, so short follow-ups ("How much does
  /// it cost?", "Am I eligible?") stay on that topic.
  discussingRexFlex,
}

class AssistantRequest {
  const AssistantRequest({required this.utterance, required this.stage});
  final String utterance;
  final ConversationStage stage;
}

/// Interprets user utterances. A production implementation would call the
/// Rex AI backend; the contract for that backend is not yet known.
///
/// Throws [AssistantUnavailableException] when the service cannot answer.
abstract interface class AtlasAssistantService {
  Future<AssistantIntent> interpret(AssistantRequest request);
}

class AssistantUnavailableException implements Exception {
  const AssistantUnavailableException([this.message = 'Assistant unavailable']);
  final String message;
  @override
  String toString() => 'AssistantUnavailableException: $message';
}
