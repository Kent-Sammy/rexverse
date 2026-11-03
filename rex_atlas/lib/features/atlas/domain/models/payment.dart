import 'account.dart';
import 'products.dart';

enum PaymentKind { transfer, airtime, savings, vault, bill }

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

/// Deposit into RexSave or a seasonal plan such as Rexy December.
class SavingsDraft extends PaymentDraft {
  const SavingsDraft({
    required super.amountKobo,
    required super.feeKobo,
    required this.plan,
    required this.source,
    required this.annualRatePct,
    this.bonusKobo = 0,
    this.lockedUntil,
  });

  final SavingsPlan plan;
  final SourceAccount source;
  final double annualRatePct;

  /// Upfront bonus credited on deposit (Rexy December: 5%).
  final int bonusKobo;

  /// Null for flexible savings.
  final DateTime? lockedUntil;

  @override
  PaymentKind get kind => PaymentKind.savings;

  SavingsDraft copyWith({int? amountKobo, int? bonusKobo}) => SavingsDraft(
    amountKobo: amountKobo ?? this.amountKobo,
    feeKobo: feeKobo,
    plan: plan,
    source: source,
    annualRatePct: annualRatePct,
    bonusKobo: bonusKobo ?? this.bonusKobo,
    lockedUntil: lockedUntil,
  );
}

/// Funds locked in RexVault for a fixed period.
class VaultDraft extends PaymentDraft {
  const VaultDraft({
    required super.amountKobo,
    required super.feeKobo,
    required this.tenorDays,
    required this.annualRatePct,
    required this.interestKobo,
    required this.maturity,
    required this.source,
  });

  final int tenorDays;
  final double annualRatePct;

  /// Expected interest paid at maturity.
  final int interestKobo;
  final DateTime maturity;
  final SourceAccount source;

  @override
  PaymentKind get kind => PaymentKind.vault;
}

/// Electricity, cable TV or internet payment.
class BillDraft extends PaymentDraft {
  const BillDraft({
    required super.amountKobo,
    required super.feeKobo,
    required this.biller,
    required this.customerId,
    required this.customer,
    required this.source,
    this.package,
  });

  final Biller biller;
  final String customerId;
  final BillCustomer customer;
  final SourceAccount source;
  final BillPackage? package;

  @override
  PaymentKind get kind => PaymentKind.bill;

  BillDraft copyWith({int? amountKobo}) => BillDraft(
    amountKobo: amountKobo ?? this.amountKobo,
    feeKobo: feeKobo,
    biller: biller,
    customerId: customerId,
    customer: customer,
    source: source,
    package: package,
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
    this.details = const {},
  });

  final PaymentStatus status;
  final String reference;
  final DateTime timestamp;
  final PaymentDraft draft;
  final String? failureReason;

  /// True for every result produced by the mock services. Receipts and
  /// result cards show a "demo" label while this is set.
  final bool isSimulated;

  /// Extra outcome data, e.g. {'Token': '1234 5678 …'} for prepaid
  /// electricity.
  final Map<String, String> details;

  bool get isSuccessful => status == PaymentStatus.successful;
}
