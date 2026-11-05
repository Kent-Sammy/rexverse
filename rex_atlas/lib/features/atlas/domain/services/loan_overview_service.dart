/// The customer's RexFlex loan as Atlas sees it: answers "what's my loan
/// status?" and lets Atlas take a loan application in the chat, without
/// depending on the RexFlex feature. The host app supplies the
/// implementation (an adapter over RexFlex). Everything is simulated in the
/// prototype.
abstract interface class LoanOverviewService {
  LoanSnapshot snapshot();

  /// Runs the RexFlex eligibility check.
  Future<LoanEligibility> checkEligibility();

  /// Submits an application. It is then reviewed in the background; watch
  /// [approvals] for the outcome.
  Future<void> apply({required int principalKobo, required int days});

  /// Fires with the new loan when an application is approved.
  Stream<LoanSnapshot> get approvals;
}

class LoanEligibility {
  const LoanEligibility({
    required this.eligible,
    required this.offerKobo,
    this.unmet = const [],
  });
  final bool eligible;
  final int offerKobo;

  /// Requirements not met (empty when eligible).
  final List<String> unmet;
}

enum LoanState { none, pending, active }

class LoanSnapshot {
  const LoanSnapshot({
    required this.state,
    required this.nextOfferKobo,
    this.principalKobo = 0,
    this.totalKobo = 0,
    this.outstandingKobo = 0,
    this.dueDate,
    this.step = 0,
    this.steps = 4,
    this.repaidLoans = 0,
  });

  /// No loan and no history: first offer ₦3,000.
  const LoanSnapshot.none({this.nextOfferKobo = 300000, this.repaidLoans = 0})
    : state = LoanState.none,
      principalKobo = 0,
      totalKobo = 0,
      outstandingKobo = 0,
      dueDate = null,
      step = 0,
      steps = 4;

  final LoanState state;
  final int nextOfferKobo;
  final int principalKobo;
  final int totalKobo;
  final int outstandingKobo;
  final DateTime? dueDate;

  /// Review step while pending ("Step 2 of 4").
  final int step;
  final int steps;
  final int repaidLoans;
}
