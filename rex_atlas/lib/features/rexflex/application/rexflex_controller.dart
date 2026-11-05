import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../atlas/domain/models/models.dart';
import '../../atlas/domain/services/services.dart';
import '../domain/rexflex_models.dart';
import '../domain/rexflex_service.dart';

/// State for the RexFlex screens: the customer's loans, the offer they have
/// earned and the in-flight application/repayment.
///
/// Every loan here is simulated. The UI labels results as demo data and the
/// PIN goes through the (simulated) [AuthorizationService]; it is never
/// stored.
class RexFlexController extends ChangeNotifier {
  RexFlexController({
    required this.service,
    required this.authorization,
    required this.accounts,
    this.isDemo = true,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final RexFlexService service;
  final AuthorizationService authorization;
  final AccountService accounts;
  final bool isDemo;
  final DateTime Function() _clock;

  /// Mock balance of the Rex account repayments come from (matches the
  /// home screen's demo balance).
  static const demoAccountBalanceKobo = 50056367000;

  final List<FlexLoan> _loans = [];
  SourceAccount? _account;
  int _seq = 0;

  DateTime get now => _clock();
  List<FlexLoan> get loans => List.unmodifiable(_loans.reversed);
  bool get hasHistory => _loans.isNotEmpty;
  SourceAccount? get account => _account;

  /// The loan that still needs action (pending review or being repaid).
  FlexLoan? get currentLoan {
    for (final l in _loans.reversed) {
      if (l.status != LoanStatus.settled) return l;
    }
    return null;
  }

  int get outstandingKobo => currentLoan?.outstandingKobo ?? 0;

  List<FlexLoan> get settledLoans =>
      loans.where((l) => l.status == LoanStatus.settled).toList();

  /// Highest principal the customer has fully repaid.
  int get highestRepaidKobo =>
      settledLoans.fold(0, (m, l) => math.max(m, l.principalKobo));

  /// "Increases are ordinarily capped at 2× your highest fully repaid
  /// principal", never below the first offer or above the RexFlex maximum.
  int get nextOfferKobo => math.min(
    RexFlexPricing.maxOfferKobo,
    math.max(RexFlexPricing.firstOfferKobo, highestRepaidKobo * 2),
  );

  /// Index into [flexTiers] for the Flex Journey timeline.
  int get tierIndex {
    if (highestRepaidKobo >= flexTiers[2].minKobo) return 2;
    if (settledLoans.isNotEmpty) return 1;
    return 0;
  }

  Future<SourceAccount> loadAccount() async =>
      _account ??= await accounts.primaryAccount();

  Future<EligibilityResult> checkEligibility() {
    unawaited(loadAccount());
    return service.checkEligibility(nextOfferKobo: nextOfferKobo);
  }

  List<LoanTerm> offersFor(int principalKobo) => [
    for (final d in RexFlexPricing.termDays) LoanTerm.priced(principalKobo, d),
  ];

  /// Submits [term]. The returned loan is pending; [onStage] reports each
  /// review step and the loan becomes active (and is "disbursed") after the
  /// last one. The application keeps going if the sheet is closed.
  FlexLoan apply(LoanTerm term, {void Function(ApplicationStage)? onStage}) {
    final loan = FlexLoan(
      id: 'RF${(++_seq).toString().padLeft(4, '0')}',
      term: term,
      appliedAt: now,
    );
    _loans.add(loan);
    notifyListeners();
    service
        .apply(term)
        .listen(
          (stage) {
            loan.stage = stage;
            onStage?.call(stage);
            notifyListeners();
          },
          onDone: () {
            final start = now;
            loan
              ..status = LoanStatus.active
              ..stage = null
              ..startDate = start
              ..dueDate = start.add(Duration(days: term.days))
              ..transactions.add(
                LoanTxn(
                  kind: LoanTxnKind.disbursement,
                  amountKobo: term.principalKobo,
                  at: start,
                  reference: 'DEMO-${loan.id}-D',
                ),
              );
            notifyListeners();
          },
        );
    return loan;
  }

  /// Checks the transaction PIN (simulated). Throws
  /// [IncorrectPinException] / [PinLockedException].
  Future<String> authorizePin(String pin) async {
    final token = await authorization.authorizeWithPin(
      pin: pin,
      purpose: 'loan repayment',
    );
    return token.value;
  }

  Future<RepaymentResult> repay(
    FlexLoan loan,
    int amountKobo,
    String token,
  ) async {
    final result = await service.repay(
      loanId: loan.id,
      amountKobo: amountKobo,
      outstandingKobo: loan.outstandingKobo,
      authorizationToken: token,
    );
    loan
      ..repaidKobo += result.paidKobo
      ..transactions.insert(
        0,
        LoanTxn(
          kind: result.settled
              ? LoanTxnKind.fullRepayment
              : LoanTxnKind.partialRepayment,
          amountKobo: result.paidKobo,
          at: now,
          reference: result.reference,
        ),
      );
    if (result.settled) {
      loan
        ..status = LoanStatus.settled
        ..settledAt = now;
    }
    notifyListeners();
    return result;
  }
}
