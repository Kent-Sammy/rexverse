import '../models/models.dart';
import 'authorization_service.dart';

class SavingsQuote {
  const SavingsQuote({
    required this.annualRatePct,
    this.bonusKobo = 0,
    this.lockedUntil,
  });
  final double annualRatePct;
  final int bonusKobo;
  final DateTime? lockedUntil;
}

/// RexSave deposits (flexible savings and seasonal plans).
abstract interface class SavingsService {
  int minDepositKobo(SavingsPlan plan);
  Future<SavingsQuote> quote(SavingsPlan plan, int amountKobo);
  Future<PaymentResult> deposit(SavingsDraft draft, AuthorizationToken token);
}

class VaultQuote {
  const VaultQuote({
    required this.annualRatePct,
    required this.interestKobo,
    required this.maturity,
  });
  final double annualRatePct;
  final int interestKobo;
  final DateTime maturity;
}

/// RexVault: funds locked for a fixed period at a fixed rate.
abstract interface class VaultService {
  int get minLockKobo;

  /// Available lock periods in days, with their annual rates.
  Map<int, double> get rates;
  Future<VaultQuote> quote({required int amountKobo, required int tenorDays});
  Future<PaymentResult> lock(VaultDraft draft, AuthorizationToken token);
}

/// Electricity, cable TV and internet bills.
abstract interface class BillsService {
  Future<List<Biller>> billers(BillCategory category);

  /// Matches free text like "ikedc", "dstv" or "eko electric".
  Future<Biller?> findBiller(String query);
  Future<List<BillPackage>> packages(Biller biller);

  /// Name enquiry for a meter/smartcard/account number. Throws
  /// [BillCustomerNotFoundException] if it cannot be validated.
  Future<BillCustomer> validateCustomer(Biller biller, String customerId);
  Future<PaymentResult> pay(BillDraft draft, AuthorizationToken token);
}

class BillCustomerNotFoundException implements Exception {
  const BillCustomerNotFoundException(this.message);
  final String message;
}
