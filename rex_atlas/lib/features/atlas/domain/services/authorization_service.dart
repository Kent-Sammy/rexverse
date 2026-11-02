/// Step-up authorisation for payments (biometrics / PIN).
///
/// The prototype's implementation is a simulation. It does not read
/// biometrics, does not collect PINs and must not be used as a security
/// control. Production must plug in Rex's existing authorisation stack.
abstract interface class AuthorizationService {
  Future<AuthorizationToken> authorizeWithBiometrics({required String purpose});
}

class AuthorizationToken {
  const AuthorizationToken({required this.value, required this.isSimulated});
  final String value;
  final bool isSimulated;
}

class AuthorizationCancelledException implements Exception {
  const AuthorizationCancelledException();
}
