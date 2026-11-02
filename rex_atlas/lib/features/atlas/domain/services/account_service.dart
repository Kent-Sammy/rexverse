import '../models/models.dart';

/// Signed-in customer's own account(s).
abstract interface class AccountService {
  Future<SourceAccount> primaryAccount();
}

/// Bank directory + name enquiry for transfer recipients.
abstract interface class BeneficiaryService {
  /// Matches free text such as "GTB" or "access bank" to a [Bank].
  Future<Bank?> findBank(String query);

  /// Name enquiry. Throws [BeneficiaryNotFoundException] when the account
  /// cannot be resolved.
  Future<Beneficiary> resolveAccount({
    required Bank bank,
    required String accountNumber,
  });
}

class BeneficiaryNotFoundException implements Exception {
  const BeneficiaryNotFoundException(this.message);
  final String message;
}
