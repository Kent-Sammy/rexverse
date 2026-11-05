import '../domain/models/models.dart';

/// One-off UI side effects emitted by [AtlasController].
sealed class AtlasEvent {
  const AtlasEvent();
}

/// Show the biometric prompt (frame "Confirm with your fingerprint").
class RequestAuthorizationEvent extends AtlasEvent {
  const RequestAuthorizationEvent(this.draft);
  final PaymentDraft draft;
}

class OpenReceiptEvent extends AtlasEvent {
  const OpenReceiptEvent(this.reference);
  final String reference;
}

/// Where an Atlas RexFlex card should take the customer.
enum RexFlexDestination { start, loan }

/// Close Atlas and open RexFlex (handled by the host app).
class OpenRexFlexEvent extends AtlasEvent {
  const OpenRexFlexEvent(this.destination);
  final RexFlexDestination destination;
}

class NoticeEvent extends AtlasEvent {
  const NoticeEvent(this.message);
  final String message;
}
