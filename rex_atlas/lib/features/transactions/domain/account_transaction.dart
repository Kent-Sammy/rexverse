import '../../atlas/domain/models/models.dart';

/// Which of the customer's accounts a transaction belongs to.
enum TxnAccount { personal, business, pos }

/// What kind of transaction it is; drives the icon and the type filter.
enum TxnKind { transfer, airtime, data, bill, card, rexsave, rexvault, rexflex }

enum TxnDirection { credit, debit }

extension TxnKindLabel on TxnKind {
  /// Label in the type filter.
  String get filterLabel => switch (this) {
    TxnKind.transfer => 'Transfers',
    TxnKind.airtime => 'Airtime',
    TxnKind.data => 'Data',
    TxnKind.bill => 'Bills',
    TxnKind.card => 'Card & POS',
    TxnKind.rexsave => 'RexSave',
    TxnKind.rexvault => 'RexVault',
    TxnKind.rexflex => 'RexFlex',
  };

  /// "Transaction Type" on a receipt.
  String get typeLabel => switch (this) {
    TxnKind.transfer => 'Bank Transfer',
    TxnKind.airtime => 'Airtime',
    TxnKind.data => 'Data',
    TxnKind.bill => 'Bill Payment',
    TxnKind.card => 'Card Payment',
    TxnKind.rexsave => 'RexSave',
    TxnKind.rexvault => 'RexVault',
    TxnKind.rexflex => 'RexFlex Loan',
  };
}

extension TxnAccountLabel on TxnAccount {
  String get label => switch (this) {
    TxnAccount.personal => 'Personal',
    TxnAccount.business => 'Business',
    TxnAccount.pos => 'POS',
  };
}

/// One row on the All Transactions page, from any product.
class AccountTransaction {
  const AccountTransaction({
    required this.reference,
    required this.title,
    required this.channel,
    required this.account,
    required this.kind,
    required this.direction,
    required this.amountKobo,
    required this.at,
    this.status = TransactionStatus.successful,
    this.description,
    this.counterparty,
    this.counterpartyLine,
    this.fromAtlasHistory = false,
    this.isSimulated = true,
  });

  final String reference;
  final String title;

  /// "Personal", "POS 01", "Rex Ventures": shown under the title.
  final String channel;
  final TxnAccount account;
  final TxnKind kind;
  final TxnDirection direction;
  final int amountKobo;
  final DateTime at;
  final TransactionStatus status;
  final String? description;

  /// The other party, e.g. "CHIDINMA OKAFOR".
  final String? counterparty;

  /// Their bank line, e.g. "GTBank | 000****716".
  final String? counterpartyLine;

  /// True when Atlas recorded it, so its own receipt service has the
  /// details (including "Repeat Transfer").
  final bool fromAtlasHistory;
  final bool isSimulated;

  bool get isCredit => direction == TxnDirection.credit;
}
