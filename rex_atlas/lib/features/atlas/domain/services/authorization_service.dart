/// Step-up authorisation for payments (biometrics / PIN).
///
/// The prototype's implementation is a simulation. It does not read
/// biometrics, never stores or transmits the PIN, and must not be used as a
/// security control. Production must plug in Rex's existing authorisation
/// stack (secure PIN entry, server-side verification, lockout policy).
abstract interface class AuthorizationService {
  Future<AuthorizationToken> authorizeWithBiometrics({required String purpose});

  /// Verifies a transaction PIN. Throws [IncorrectPinException] or
  /// [PinLockedException].
  Future<AuthorizationToken> authorizeWithPin({
    required String pin,
    required String purpose,
  });
}

class IncorrectPinException implements Exception {
  const IncorrectPinException(this.attemptsLeft);
  final int attemptsLeft;
}

class PinLockedException implements Exception {
  const PinLockedException();
}

class AuthorizationToken {
  const AuthorizationToken({required this.value, required this.isSimulated});
  final String value;
  final bool isSimulated;
}

class AuthorizationCancelledException implements Exception {
  const AuthorizationCancelledException();
}
