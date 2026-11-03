import '../../domain/models/models.dart';
import '../../domain/services/services.dart';
import 'mock_data.dart';

class MockAccountService implements AccountService {
  @override
  Future<SourceAccount> primaryAccount() async => MockData.user;
}

class MockBeneficiaryService implements BeneficiaryService {
  MockBeneficiaryService({this.latency = const Duration(milliseconds: 600)});
  final Duration latency;

  @override
  Future<Bank?> findBank(String query) async {
    final code = MockData.bankAliases[query.toLowerCase().trim()];
    if (code == null) return null;
    return MockData.banks.firstWhere((b) => b.code == code);
  }

  @override
  Future<Beneficiary> resolveAccount({
    required Bank bank,
    required String accountNumber,
  }) async {
    await Future<void>.delayed(latency);
    if (!RegExp(r'^\d{10}$').hasMatch(accountNumber)) {
      throw const BeneficiaryNotFoundException(
        'Account numbers must be 10 digits.',
      );
    }
    if (accountNumber.startsWith('000000')) {
      throw BeneficiaryNotFoundException(
        "I couldn't find account $accountNumber at ${bank.shortName}.",
      );
    }
    final name =
        MockData.knownAccounts['${bank.code}:$accountNumber'] ??
        MockData.fallbackNames[int.parse(accountNumber.substring(6)) %
            MockData.fallbackNames.length];
    return Beneficiary(
      accountName: name,
      accountNumber: accountNumber,
      bank: bank,
    );
  }
}

class MockAuthorizationService implements AuthorizationService {
  MockAuthorizationService({this.latency = const Duration(milliseconds: 500)});
  final Duration latency;

  @override
  Future<AuthorizationToken> authorizeWithBiometrics({
    required String purpose,
  }) async {
    await Future<void>.delayed(latency);
    return AuthorizationToken(
      value: 'demo-${DateTime.now().microsecondsSinceEpoch}',
      isSimulated: true,
    );
  }

  /// Demo rule: any 4 digits are accepted except "0000", which shows the
  /// wrong-PIN state. 3 wrong attempts lock PIN entry for the session.
  /// The PIN is only compared here and never stored or logged.
  static const maxAttempts = 3;
  int _failures = 0;

  @override
  Future<AuthorizationToken> authorizeWithPin({
    required String pin,
    required String purpose,
  }) async {
    await Future<void>.delayed(latency);
    if (_failures >= maxAttempts) throw const PinLockedException();
    if (pin.length != 4 || pin == '0000') {
      _failures++;
      if (_failures >= maxAttempts) throw const PinLockedException();
      throw IncorrectPinException(maxAttempts - _failures);
    }
    _failures = 0;
    return AuthorizationToken(
      value: 'demo-pin-${DateTime.now().microsecondsSinceEpoch}',
      isSimulated: true,
    );
  }
}
