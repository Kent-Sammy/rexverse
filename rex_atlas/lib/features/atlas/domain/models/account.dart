/// The signed-in Rex customer's account used as the transfer source.
class SourceAccount {
  const SourceAccount({
    required this.holderName,
    required this.firstName,
    required this.bankName,
    required this.accountNumber,
  });

  final String holderName;
  final String firstName;
  final String bankName;
  final String accountNumber;

  /// `REXMFB ******1921`
  String get maskedLabel =>
      '$bankName ******${accountNumber.substring(accountNumber.length - 4)}';
}

/// A bank supported by the (mock) name-enquiry service.
class Bank {
  const Bank({required this.code, required this.name, required this.shortName});

  final String code;
  final String name; // "GTBank Plc"
  final String shortName; // "GTBank"
}

/// A resolved transfer recipient (result of a name enquiry).
class Beneficiary {
  const Beneficiary({
    required this.accountName,
    required this.accountNumber,
    required this.bank,
  });

  final String accountName;
  final String accountNumber;
  final Bank bank;

  /// `GTBank **** 8716`
  String get maskedLabel =>
      '${bank.shortName} **** ${accountNumber.substring(accountNumber.length - 4)}';
}
