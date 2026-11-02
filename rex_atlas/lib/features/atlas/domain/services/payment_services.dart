import '../models/models.dart';
import 'authorization_service.dart';

/// Fee calculation, validation and execution for bank transfers.
abstract interface class TransferService {
  Future<int> quoteFeeKobo({required int amountKobo, required Bank bank});

  /// Must only be called with a token from [AuthorizationService].
  Future<PaymentResult> execute(TransferDraft draft, AuthorizationToken token);
}

abstract interface class AirtimeService {
  /// Detects the mobile network for a Nigerian number, e.g. "MTN".
  Future<String> detectNetwork(String phoneNumber);

  Future<PaymentResult> purchase(AirtimeDraft draft, AuthorizationToken token);
}

class PaymentValidationException implements Exception {
  const PaymentValidationException(this.message);
  final String message;
}
