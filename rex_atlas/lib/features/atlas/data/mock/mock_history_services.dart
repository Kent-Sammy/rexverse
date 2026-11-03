import '../../../../core/formatting/dates.dart';
import '../../../../core/formatting/naira.dart';
import '../../domain/models/models.dart';
import '../../domain/services/services.dart';
import 'mock_data.dart';

class MockTransactionHistoryService implements TransactionHistoryService {
  MockTransactionHistoryService({
    this.latency = const Duration(milliseconds: 600),
  }) : _records = MockData.seedHistory(),
       _latestTransfer = MockData.seedLatestTransfer();

  final Duration latency;
  final List<TransactionRecord> _records;
  TransactionRecord _latestTransfer;

  @override
  TransactionRecord? get latestTransfer => _latestTransfer;

  @override
  Future<List<TransactionRecord>> recent({int limit = 4}) async {
    await Future<void>.delayed(latency);
    return List.unmodifiable(_records.take(limit));
  }

  TransactionRecord? find(String reference) {
    if (_latestTransfer.reference == reference) return _latestTransfer;
    for (final r in _records) {
      if (r.reference == reference) return r;
    }
    return null;
  }

  @override
  void record(TransactionRecord record) {
    _records.insert(0, record);
    if (record.category == TransactionCategory.transfer &&
        record.counterpartyName != null) {
      _latestTransfer = record;
    }
  }
}

class MockReceiptService implements ReceiptService {
  MockReceiptService({required this.history, required this.sender});

  final MockTransactionHistoryService history;
  final SourceAccount sender;

  @override
  Future<Receipt> receiptFor(String reference) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final r = history.find(reference);
    if (r == null) throw ReceiptNotFoundException(reference);
    return MockReceiptBuilder.fromRecord(r, sender);
  }
}

/// Builds receipts in the Figma "Transaction Details" row order.
abstract final class MockReceiptBuilder {
  static Receipt fromRecord(TransactionRecord r, SourceAccount sender) {
    final rows = <ReceiptRow>[
      ReceiptRow('Transaction No.', r.reference, copyable: true),
    ];
    if (r.counterpartyName != null) {
      rows.add(
        ReceiptRow('Recipient’s Name', r.counterpartyName!.toUpperCase()),
      );
    }
    if (r.counterpartyBankLabel != null) {
      rows.add(ReceiptRow('Recipient’s Bank', r.counterpartyBankLabel!));
    }
    for (final e in r.details.entries) {
      rows.add(ReceiptRow(e.key, e.value, copyable: e.key == 'Token'));
    }
    if (r.category == TransactionCategory.airtime && r.channel != null) {
      rows.add(ReceiptRow('Phone Number', r.channel!));
    }
    rows
      ..add(ReceiptRow('Amount', Naira.grouped(r.amountKobo)))
      ..add(
        ReceiptRow('Description', switch (r.category) {
          TransactionCategory.airtime =>
            'Airtime purchase | ${sender.accountNumber}',
          TransactionCategory.cardPayment =>
            'Card payment | ${r.channel ?? ''}',
          TransactionCategory.savings => 'Deposit from ${sender.holderName}',
          TransactionCategory.vault =>
            'RexVault savings from ${sender.holderName}',
          TransactionCategory.bill => '${r.title} | ${sender.holderName}',
          _ => 'Transfer from ${sender.holderName} | ${sender.accountNumber}',
        }),
      )
      ..add(ReceiptRow('Transaction Date', RexDates.receipt(r.timestamp)))
      ..add(const ReceiptRow('Transaction Fee', '₦0.00'));
    return Receipt(
      reference: r.reference,
      title: r.title,
      amountKobo: r.amountKobo,
      status: r.status,
      rows: rows,
      isSimulated: r.isSimulated,
    );
  }
}
