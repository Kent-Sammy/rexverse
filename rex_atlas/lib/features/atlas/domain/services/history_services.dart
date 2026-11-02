import '../models/models.dart';

abstract interface class TransactionHistoryService {
  Future<List<TransactionRecord>> recent({int limit = 4});

  /// Most recent outgoing transfer, shown on the welcome sheet. Synchronous
  /// (cached) so the welcome sheet renders without a loading flash.
  TransactionRecord? get latestTransfer;

  /// Lets the payment layer record completed (simulated) payments so they
  /// show up in history. A real backend would do this server-side.
  void record(TransactionRecord record);
}

abstract interface class ReceiptService {
  Future<Receipt> receiptFor(String reference);
}

class ReceiptNotFoundException implements Exception {
  const ReceiptNotFoundException(this.reference);
  final String reference;
}
