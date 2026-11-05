import 'dart:math' as math;

import '../domain/rexflex_models.dart';
import '../domain/rexflex_service.dart';

/// Simulated lender: always eligible, approves every application after a
/// realistic background review (3 steps × [stageDelay], about a minute by
/// default), and accepts any repayment up to the balance. Nothing leaves the
/// device and no money moves.
class MockRexFlexService implements RexFlexService {
  MockRexFlexService({
    this.latency = const Duration(milliseconds: 900),
    this.stageDelay = const Duration(seconds: 20),
  });

  final Duration latency;
  final Duration stageDelay;
  final _random = math.Random();

  @override
  Future<EligibilityResult> checkEligibility({
    required int nextOfferKobo,
  }) async {
    await Future<void>.delayed(latency);
    return EligibilityResult(
      offerKobo: nextOfferKobo,
      criteria: const [
        EligibilityCriterion(
          'Active Rex Account',
          'For at least 30 days',
          met: true,
        ),
        EligibilityCriterion(
          'At least 2 external inflows',
          'On different days',
          met: true,
        ),
        EligibilityCriterion(
          'Total inflows of ₦10,000+',
          'In the last 30 days',
          met: true,
        ),
      ],
    );
  }

  @override
  Stream<ApplicationStage> apply(LoanTerm term) async* {
    for (final stage in ApplicationStage.values.skip(1)) {
      yield stage;
      await Future<void>.delayed(stageDelay);
    }
  }

  @override
  Future<RepaymentResult> repay({
    required String loanId,
    required int amountKobo,
    required int outstandingKobo,
    required String authorizationToken,
  }) async {
    await Future<void>.delayed(latency * 2);
    if (amountKobo <= 0 || amountKobo > outstandingKobo) {
      throw ArgumentError.value(amountKobo, 'amountKobo');
    }
    final left = outstandingKobo - amountKobo;
    return RepaymentResult(
      paidKobo: amountKobo,
      outstandingKobo: left,
      settled: left == 0,
      reference: 'DEMO-RF-${_random.nextInt(900000) + 100000}',
      at: DateTime.now(),
    );
  }
}
