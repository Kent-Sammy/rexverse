import 'rexflex_models.dart';

/// Lending backend for RexFlex.
///
/// The prototype only ships [MockRexFlexService]. A production version must
/// call Rex's real lending APIs (eligibility, credit decisioning,
/// disbursement and repayment). No endpoints are assumed here.
abstract interface class RexFlexService {
  /// Checks the eligibility rules shown on the "Check Your Eligibility"
  /// sheet. [nextOfferKobo] is the amount earned through progression.
  Future<EligibilityResult> checkEligibility({required int nextOfferKobo});

  /// Submits an application and reports each review stage as it completes.
  Stream<ApplicationStage> apply(LoanTerm term);

  /// Repays [amountKobo] from the customer's Rex account.
  Future<RepaymentResult> repay({
    required String loanId,
    required int amountKobo,
    required int outstandingKobo,
    required String authorizationToken,
  });
}
