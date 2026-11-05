import '../../atlas/domain/services/services.dart';
import '../domain/rexflex_models.dart';
import 'rexflex_controller.dart';

/// Lets Atlas see the customer's RexFlex loan and take applications in the
/// chat, through the same (simulated) RexFlex controller as the screens, so
/// a loan taken in Atlas appears on the RexFlex dashboard too.
class RexFlexLoanOverview implements LoanOverviewService {
  RexFlexLoanOverview(this.controller);
  final RexFlexController controller;

  @override
  Future<LoanEligibility> checkEligibility() async {
    final r = await controller.checkEligibility();
    return LoanEligibility(
      eligible: r.eligible,
      offerKobo: r.offerKobo,
      unmet: [
        for (final c in r.criteria)
          if (!c.met) '${c.title} (${c.detail.toLowerCase()})',
      ],
    );
  }

  @override
  Future<void> apply({required int principalKobo, required int days}) async {
    controller.apply(LoanTerm.priced(principalKobo, days));
  }

  @override
  Stream<LoanSnapshot> get approvals => controller.approvals.map(_snapshotOf);

  @override
  LoanSnapshot snapshot() => _snapshotOf(controller.currentLoan);

  LoanSnapshot _snapshotOf(FlexLoan? loan) {
    final c = controller;
    final repaid = c.settledLoans.length;
    if (loan == null) {
      return LoanSnapshot.none(
        nextOfferKobo: c.nextOfferKobo,
        repaidLoans: repaid,
      );
    }
    final pending = loan.status == LoanStatus.pending;
    return LoanSnapshot(
      state: pending ? LoanState.pending : LoanState.active,
      nextOfferKobo: c.nextOfferKobo,
      principalKobo: loan.principalKobo,
      totalKobo: loan.totalKobo,
      outstandingKobo: loan.outstandingKobo,
      dueDate: loan.dueDate ?? loan.proposedDueDate,
      step: loan.stepNumber,
      steps: ApplicationStage.values.length,
      repaidLoans: repaid,
    );
  }
}
