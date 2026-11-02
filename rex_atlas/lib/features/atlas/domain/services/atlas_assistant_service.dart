import '../models/models.dart';

/// Conversation stage passed to the assistant so it can resolve short
/// replies like "yes" or "change it to 5000".
enum ConversationStage {
  idle,
  awaitingTransferDetails,
  awaitingAirtimeDetails,
  awaitingPaymentConfirmation,
  awaitingAuthorization,
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
