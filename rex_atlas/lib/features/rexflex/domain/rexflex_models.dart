/// RexFlex short-term loan models. Amounts are integer kobo.
library;

/// One repayment option on an offer, e.g. ₦3,000 for 14 days.
class LoanTerm {
  const LoanTerm({
    required this.principalKobo,
    required this.days,
    required this.interestKobo,
  });

  /// RexFlex charges 8% per 30 days, pro-rated by day and rounded to the
  /// nearest kobo: ₦3,000 for 14 days → ₦112, for 30 days → ₦240.
  factory LoanTerm.priced(int principalKobo, int days) => LoanTerm(
    principalKobo: principalKobo,
    days: days,
    interestKobo:
        (principalKobo * RexFlexPricing.ratePer30DaysPct * days / (100 * 30))
            .round(),
  );

  final int principalKobo;
  final int days;
  final int interestKobo;

  int get totalKobo => principalKobo + interestKobo;
}

abstract final class RexFlexPricing {
  static const ratePer30DaysPct = 8;
  static const termDays = [14, 30];
  static const firstOfferKobo = 300000; // ₦3,000
  static const maxOfferKobo = 10000000; // ₦100,000
}

class EligibilityCriterion {
  const EligibilityCriterion(this.title, this.detail, {required this.met});
  final String title;
  final String detail;
  final bool met;
}

class EligibilityResult {
  const EligibilityResult({required this.criteria, required this.offerKobo});
  final List<EligibilityCriterion> criteria;
  final int offerKobo;
  bool get eligible => criteria.every((c) => c.met);
}

/// Steps shown on the "Application Received" sheet.
enum ApplicationStage {
  received(
    'Application Received',
    'Your application has been successfully submitted and is awaiting review.',
  ),
  riskChecks(
    'Eligibility & Risk Checks',
    "We're verifying your details and assessing your credit eligibility.",
  ),
  finalDecision(
    'Final Decisions',
    "Your application is undergoing final review. We'll notify you once a decision is made.",
  ),
  disbursement(
    'Disbursement',
    'Your approved loan is being processed and will be sent to your Rex account.',
  );

  const ApplicationStage(this.title, this.detail);
  final String title;
  final String detail;
}

enum LoanStatus { pending, active, settled }

enum LoanTxnKind { disbursement, partialRepayment, fullRepayment }

class LoanTxn {
  const LoanTxn({
    required this.kind,
    required this.amountKobo,
    required this.at,
    required this.reference,
  });
  final LoanTxnKind kind;
  final int amountKobo;
  final DateTime at;
  final String reference;

  bool get isCredit => kind == LoanTxnKind.disbursement;
  String get title => switch (kind) {
    LoanTxnKind.disbursement => 'Loan Disbursement',
    LoanTxnKind.partialRepayment => 'Loan Repayment (Partial)',
    LoanTxnKind.fullRepayment => 'Loan Repayment (Full)',
  };
}

class FlexLoan {
  FlexLoan({required this.id, required this.term, required this.appliedAt});

  final String id;
  final LoanTerm term;
  final DateTime appliedAt;
  LoanStatus status = LoanStatus.pending;

  /// Current review step while [status] is pending.
  ApplicationStage? stage;
  DateTime? startDate;
  DateTime? dueDate;
  DateTime? settledAt;
  int repaidKobo = 0;
  final List<LoanTxn> transactions = [];

  int get principalKobo => term.principalKobo;
  int get interestKobo => term.interestKobo;
  int get totalKobo => term.totalKobo;
  int get outstandingKobo =>
      status == LoanStatus.pending ? 0 : totalKobo - repaidKobo;
  double get progress => totalKobo == 0 ? 0 : repaidKobo / totalKobo;

  DateTime get proposedDueDate =>
      (startDate ?? appliedAt).add(Duration(days: term.days));
}

class RepaymentResult {
  const RepaymentResult({
    required this.paidKobo,
    required this.outstandingKobo,
    required this.settled,
    required this.reference,
    required this.at,
  });
  final int paidKobo;
  final int outstandingKobo;
  final bool settled;
  final String reference;
  final DateTime at;

  /// Every RexFlex result in this prototype is simulated.
  bool get isSimulated => true;
}

/// A tier on the Flex Journey.
class FlexTier {
  const FlexTier(this.name, this.minKobo, this.maxKobo, this.unlock, this.tint);
  final String name;
  final int minKobo;
  final int maxKobo;
  final String unlock;
  final int tint; // ARGB
}

const flexTiers = [
  FlexTier('Build Your Flex', 300000, 1000000, 'Start here', 0xFFEDF3FF),
  FlexTier(
    'Grow Your Flex',
    500000,
    1500000,
    'Unlock after 1–2 on-time loans',
    0xFFE6FBEA,
  ),
  FlexTier(
    'Max Your Flex',
    6000000,
    10000000,
    'Unlock after a stronger repayment history',
    0xFFF1EBFF,
  ),
];
