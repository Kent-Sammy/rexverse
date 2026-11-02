import 'dart:math';

import '../../domain/models/models.dart';
import '../../domain/services/services.dart';

/// Demo rules (documented in docs/DEMO_SCRIPT.md):
/// * transfers above ₦5,000,000 fail with a limit error;
/// * airtime must be between ₦50 and ₦50,000.
class MockTransferService implements TransferService {
  MockTransferService({
    required this.history,
    this.latency = const Duration(milliseconds: 1500),
    Random? random,
  }) : _random = random ?? Random();

  final TransactionHistoryService history;
  final Duration latency;
  final Random _random;

  static const demoLimitKobo = 500000000; // ₦5,000,000

  @override
  Future<int> quoteFeeKobo({
    required int amountKobo,
    required Bank bank,
  }) async => 0;

  @override
  Future<PaymentResult> execute(
    TransferDraft draft,
    AuthorizationToken token,
  ) async {
    await Future<void>.delayed(latency);
    final now = DateTime.now();
    final ref = _reference(_random);
    if (draft.amountKobo > demoLimitKobo) {
      return PaymentResult(
        status: PaymentStatus.failed,
        reference: ref,
        timestamp: now,
        draft: draft,
        failureReason: 'This amount is above your daily transfer limit.',
      );
    }
    final b = draft.beneficiary;
    history.record(
      TransactionRecord(
        reference: ref,
        title: 'Transfer to ${_shortName(b.accountName)}',
        category: TransactionCategory.transfer,
        amountKobo: draft.amountKobo,
        timestamp: now,
        status: TransactionStatus.successful,
        counterpartyName: b.accountName,
        counterpartyMasked: b.maskedLabel,
        counterpartyBankLabel: '${b.bank.shortName} (${b.accountNumber})',
      ),
    );
    return PaymentResult(
      status: PaymentStatus.successful,
      reference: ref,
      timestamp: now,
      draft: draft,
    );
  }

  static String _shortName(String full) {
    final parts = full.split(' ');
    if (parts.length < 2) return full;
    String cap(String s) => s[0] + s.substring(1).toLowerCase();
    return '${parts[1][0]}. ${cap(parts[0])}';
  }
}

class MockAirtimeService implements AirtimeService {
  MockAirtimeService({
    required this.history,
    this.latency = const Duration(milliseconds: 1200),
    Random? random,
  }) : _random = random ?? Random();

  final TransactionHistoryService history;
  final Duration latency;
  final Random _random;

  static const minKobo = 5000;
  static const maxKobo = 5000000;

  static const _prefixes = <String, List<String>>{
    'MTN': [
      '0803',
      '0806',
      '0703',
      '0706',
      '0813',
      '0816',
      '0810',
      '0814',
      '0903',
      '0906',
      '0913',
      '0916',
    ],
    'Airtel': [
      '0802',
      '0808',
      '0708',
      '0812',
      '0701',
      '0902',
      '0907',
      '0901',
      '0912',
    ],
    'Glo': ['0805', '0807', '0705', '0815', '0811', '0905', '0915'],
    '9mobile': ['0809', '0818', '0817', '0909', '0908'],
  };

  @override
  Future<String> detectNetwork(String phoneNumber) async {
    final prefix = phoneNumber.substring(0, 4);
    for (final e in _prefixes.entries) {
      if (e.value.contains(prefix)) return e.key;
    }
    return 'MTN';
  }

  @override
  Future<PaymentResult> purchase(
    AirtimeDraft draft,
    AuthorizationToken token,
  ) async {
    await Future<void>.delayed(latency);
    final now = DateTime.now();
    final ref = _reference(_random);
    history.record(
      TransactionRecord(
        reference: ref,
        title: 'Airtime Purchase',
        category: TransactionCategory.airtime,
        amountKobo: draft.amountKobo,
        timestamp: now,
        status: TransactionStatus.successful,
        channel: '${draft.network} ${draft.phoneNumber}',
      ),
    );
    return PaymentResult(
      status: PaymentStatus.successful,
      reference: ref,
      timestamp: now,
      draft: draft,
    );
  }
}

String _reference(Random r) =>
    '70${List.generate(11, (_) => r.nextInt(10)).join()}';
