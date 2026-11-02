enum TransactionCategory { cardPayment, transfer, airtime, businessTransfer }

enum TransactionStatus { successful, pending, failed }

class TransactionRecord {
  const TransactionRecord({
    required this.reference,
    required this.title,
    required this.category,
    required this.amountKobo,
    required this.timestamp,
    required this.status,
    this.channel,
    this.counterpartyName,
    this.counterpartyBankLabel,
    this.counterpartyMasked,
    this.isSimulated = true,
  });

  final String reference;
  final String title; // "Card Payment", "Transfer to K. Adewale"
  final TransactionCategory category;
  final int amountKobo;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? channel; // "POS 01", "Personal"
  final String? counterpartyName; // "Tunde Adeyemi"
  final String? counterpartyBankLabel; // "GTBank (0004218716)"
  final String? counterpartyMasked; // "GTBank **** 8716"
  final bool isSimulated;
}

/// Key/value receipt as shown in the "Transaction Details" panel.
class Receipt {
  const Receipt({
    required this.reference,
    required this.rows,
    required this.isSimulated,
    required this.title,
    required this.amountKobo,
    required this.status,
  });

  final String reference;
  final String title;
  final int amountKobo;
  final TransactionStatus status;
  final List<ReceiptRow> rows;
  final bool isSimulated;
}

class ReceiptRow {
  const ReceiptRow(this.label, this.value, {this.copyable = false});
  final String label;
  final String value;
  final bool copyable;
}
