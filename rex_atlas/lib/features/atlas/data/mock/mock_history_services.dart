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
      timestamp: r.timestamp,
      shareRows: _shareRows(r, sender),
      repeat: _repeat(r),
    );
  }

  /// "703****815": keeps the first and last three digits.
  static String maskAccount(String n) =>
      n.length < 7 ? n : '${n.substring(0, 3)}****${n.substring(n.length - 3)}';

  static List<ReceiptRow> _shareRows(TransactionRecord r, SourceAccount s) {
    final rows = <ReceiptRow>[];
    final recipient = _recipient(r);
    if (recipient != null) rows.add(ReceiptRow('Recipient Details', recipient));
    rows
      ..add(
        ReceiptRow(
          'Sender Details',
          '${s.holderName.toUpperCase()}\n'
              '${s.bankName} | ${maskAccount(s.accountNumber)}',
        ),
      )
      ..add(ReceiptRow('Transaction Type', typeLabel(r.category)));
    final token = r.details['Token'];
    if (token != null) rows.add(ReceiptRow('Token', token, copyable: true));
    rows
      ..add(ReceiptRow('Transaction No.', r.reference, copyable: true))
      ..add(ReceiptRow('Transaction Date', RexDates.receipt(r.timestamp)));
    return rows;
  }

  static String? _recipient(TransactionRecord r) {
    final (bank, acct) = _bankAndAccount(r.counterpartyBankLabel);
    final line = bank == null
        ? r.counterpartyMasked
        : acct == null
        ? bank
        : '$bank | ${maskAccount(acct)}';
    final lines = [?r.counterpartyName?.toUpperCase(), ?line];
    if (lines.isNotEmpty) return lines.join('\n');
    if (r.category == TransactionCategory.airtime) return r.channel;
    if (r.category == TransactionCategory.bill) return r.channel ?? r.title;
    return null;
  }

  /// "GTBank (0004218716)" → ("GTBank", "0004218716").
  static (String?, String?) _bankAndAccount(String? label) {
    if (label == null) return (null, null);
    final m = RegExp(r'^(.*?)\s*\((\d+)\)$').firstMatch(label);
    if (m == null) return (label, null);
    return (m.group(1), m.group(2));
  }

  static String typeLabel(TransactionCategory c) => switch (c) {
    TransactionCategory.transfer => 'Bank Transfer',
    TransactionCategory.businessTransfer => 'Business Transfer',
    TransactionCategory.airtime => 'Airtime',
    TransactionCategory.cardPayment => 'Card Payment',
    TransactionCategory.savings => 'Savings Deposit',
    TransactionCategory.vault => 'RexVault Savings',
    TransactionCategory.bill => 'Bill Payment',
  };

  static ReceiptRepeat? _repeat(TransactionRecord r) {
    final amount = Naira.plain(r.amountKobo);
    switch (r.category) {
      case TransactionCategory.transfer:
        final (bank, acct) = _bankAndAccount(r.counterpartyBankLabel);
        return ReceiptRepeat(
          label: 'Repeat Transfer',
          utterance: bank != null && acct != null
              ? 'Send $amount to $bank $acct'
              : 'Make another transfer',
        );
      case TransactionCategory.airtime:
        final phone = RegExp(r'0\d{10}').firstMatch(r.channel ?? '')?.group(0);
        return ReceiptRepeat(
          label: 'Buy Again',
          utterance: phone == null
              ? 'Buy Airtime'
              : 'Buy $amount airtime for $phone',
        );
      default:
        return null;
    }
  }
}
