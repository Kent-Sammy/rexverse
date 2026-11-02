import 'account.dart';

enum PaymentKind { transfer, airtime }

/// A payment the assistant has collected details for but not yet executed.
///
/// Amounts are integer kobo.
sealed class PaymentDraft {
  const PaymentDraft({required this.amountKobo, required this.feeKobo});

  final int amountKobo;
  final int feeKobo;
  int get totalKobo => amountKobo + feeKobo;
  PaymentKind get kind;
}

class TransferDraft extends PaymentDraft {
  const TransferDraft({
    required super.amountKobo,
    required super.feeKobo,
    required this.beneficiary,
    required this.source,
    this.narration,
  });

  final Beneficiary beneficiary;
  final SourceAccount source;
  final String? narration;

  @override
  PaymentKind get kind => PaymentKind.transfer;

  TransferDraft copyWith({int? amountKobo, int? feeKobo}) => TransferDraft(
    amountKobo: amountKobo ?? this.amountKobo,
    feeKobo: feeKobo ?? this.feeKobo,
    beneficiary: beneficiary,
    source: source,
    narration: narration,
  );
}

class AirtimeDraft extends PaymentDraft {
  const AirtimeDraft({
    required super.amountKobo,
    required super.feeKobo,
    required this.phoneNumber,
    required this.network,
    required this.source,
  });

  final String phoneNumber;
  final String network; // e.g. "MTN"
  final SourceAccount source;

  @override
  PaymentKind get kind => PaymentKind.airtime;

  AirtimeDraft copyWith({int? amountKobo}) => AirtimeDraft(
    amountKobo: amountKobo ?? this.amountKobo,
    feeKobo: feeKobo,
    phoneNumber: phoneNumber,
    network: network,
    source: source,
  );
}

enum PaymentStatus { successful, failed }

/// Outcome returned by the payment service – never by the AI service.
class PaymentResult {
  const PaymentResult({
    required this.status,
    required this.reference,
    required this.timestamp,
    required this.draft,
    this.failureReason,
    this.isSimulated = true,
  });

  final PaymentStatus status;
  final String reference;
  final DateTime timestamp;
  final PaymentDraft draft;
  final String? failureReason;

  /// True for every result produced by the mock services. Receipts and
  /// result cards show a "demo" label while this is set.
  final bool isSimulated;

  bool get isSuccessful => status == PaymentStatus.successful;
}
