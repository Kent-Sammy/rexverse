// Savings, vault and bill-payment catalogue types.

enum SavingsPlan {
  /// Flexible savings: withdraw any time.
  rexSave('RexSave', 'Flexible savings'),

  /// Seasonal plan from the Figma suggestion "Get 5% upfront on deposits".
  rexyDecember('Rexy December', 'Locked until December 31');

  const SavingsPlan(this.displayName, this.tagline);
  final String displayName;
  final String tagline;
}

enum BillCategory {
  electricity('Electricity'),
  cableTv('Cable TV'),
  internet('Internet');

  const BillCategory(this.displayName);
  final String displayName;
}

/// A bill-payment provider (e.g. Ikeja Electric, DStv, Spectranet).
class Biller {
  const Biller({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.customerIdLabel,
    required this.minIdLength,
    required this.maxIdLength,
    this.minAmountKobo = 0,
    this.maxAmountKobo = 0,
  });

  final String id;
  final String name; // "Ikeja Electric (IKEDC)"
  final String shortName; // "IKEDC"
  final BillCategory category;
  final String customerIdLabel; // "meter number", "smartcard number"
  final int minIdLength;
  final int maxIdLength;

  /// Amount limits for open-amount bills (electricity). Package-based bills
  /// (TV, internet) take their price from the chosen package.
  final int minAmountKobo;
  final int maxAmountKobo;

  bool get hasPackages => category != BillCategory.electricity;
}

class BillPackage {
  const BillPackage({
    required this.id,
    required this.name,
    required this.amountKobo,
  });
  final String id;
  final String name; // "Compact"
  final int amountKobo;
}

/// Result of validating a meter/smartcard/account number with the biller.
class BillCustomer {
  const BillCustomer({required this.name, this.address});
  final String name;
  final String? address;
}
