import 'dart:math';

import '../../domain/models/models.dart';
import '../../domain/services/services.dart';
import 'mock_data.dart';

String _ref(Random r) => '70${List.generate(11, (_) => r.nextInt(10)).join()}';

class MockSavingsService implements SavingsService {
  MockSavingsService({
    required this.history,
    this.latency = const Duration(milliseconds: 1200),
    Random? random,
    DateTime Function()? clock,
  }) : _random = random ?? Random(),
       _clock = clock ?? DateTime.now;

  final TransactionHistoryService history;
  final Duration latency;
  final Random _random;
  final DateTime Function() _clock;

  @override
  int minDepositKobo(SavingsPlan plan) =>
      plan == SavingsPlan.rexyDecember ? 100000 : 10000;

  @override
  Future<SavingsQuote> quote(SavingsPlan plan, int amountKobo) async {
    if (plan == SavingsPlan.rexSave) {
      return const SavingsQuote(annualRatePct: MockData.rexSaveRatePct);
    }
    final now = _clock();
    final lockEnd = DateTime(
      now.month == 12 && now.day == 31 ? now.year + 1 : now.year,
      12,
      31,
    );
    return SavingsQuote(
      annualRatePct: 0,
      bonusKobo: (amountKobo * MockData.rexyDecemberBonusPct / 100).round(),
      lockedUntil: lockEnd,
    );
  }

  @override
  Future<PaymentResult> deposit(
    SavingsDraft draft,
    AuthorizationToken token,
  ) async {
    await Future<void>.delayed(latency);
    final ref = _ref(_random);
    final now = _clock();
    history.record(
      TransactionRecord(
        reference: ref,
        title: '${draft.plan.displayName} deposit',
        category: TransactionCategory.savings,
        amountKobo: draft.amountKobo,
        timestamp: now,
        status: TransactionStatus.successful,
        channel: draft.plan.displayName,
        details: {
          'Savings Plan': draft.plan.displayName,
          if (draft.annualRatePct > 0)
            'Interest Rate': '${draft.annualRatePct.toStringAsFixed(0)}% p.a.',
          if (draft.bonusKobo > 0) 'Upfront Bonus': _naira(draft.bonusKobo),
          if (draft.lockedUntil != null)
            'Locked Until': _date(draft.lockedUntil!),
        },
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

class MockVaultService implements VaultService {
  MockVaultService({
    required this.history,
    this.latency = const Duration(milliseconds: 1200),
    Random? random,
    DateTime Function()? clock,
  }) : _random = random ?? Random(),
       _clock = clock ?? DateTime.now;

  final TransactionHistoryService history;
  final Duration latency;
  final Random _random;
  final DateTime Function() _clock;

  @override
  int get minLockKobo => 1000000; // ₦10,000

  @override
  Map<int, double> get rates => MockData.vaultRates;

  @override
  Future<VaultQuote> quote({
    required int amountKobo,
    required int tenorDays,
  }) async {
    final rate = rates[tenorDays] ?? rates.values.first;
    return VaultQuote(
      annualRatePct: rate,
      interestKobo: (amountKobo * rate / 100 * tenorDays / 365).round(),
      maturity: _clock().add(Duration(days: tenorDays)),
    );
  }

  @override
  Future<PaymentResult> lock(VaultDraft draft, AuthorizationToken token) async {
    await Future<void>.delayed(latency);
    final ref = _ref(_random);
    final now = _clock();
    history.record(
      TransactionRecord(
        reference: ref,
        title: 'RexVault savings (${_period(draft.tenorDays)})',
        category: TransactionCategory.vault,
        amountKobo: draft.amountKobo,
        timestamp: now,
        status: TransactionStatus.successful,
        channel: _period(draft.tenorDays),
        details: {
          'Saving Period': _period(draft.tenorDays),
          'Interest Rate': '${draft.annualRatePct.toStringAsFixed(0)}% p.a.',
          'Interest Earned': _naira(draft.interestKobo),
          'Total at Maturity': _naira(draft.amountKobo + draft.interestKobo),
          'Maturity Date': _date(draft.maturity),
        },
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

class MockBillsService implements BillsService {
  MockBillsService({
    required this.history,
    required this.customerName,
    this.latency = const Duration(milliseconds: 1200),
    Random? random,
  }) : _random = random ?? Random();

  final TransactionHistoryService history;
  final String customerName;
  final Duration latency;
  final Random _random;

  /// Demo tariff used to estimate units for prepaid electricity.
  static const _nairaPerKwh = 209.5;

  @override
  Future<List<Biller>> billers(BillCategory category) async =>
      MockData.billers.where((b) => b.category == category).toList();

  @override
  Future<Biller?> findBiller(String query) async {
    final id = MockData.billerAliases[query.toLowerCase().trim()];
    if (id == null) return null;
    return MockData.billers.firstWhere((b) => b.id == id);
  }

  @override
  Future<List<BillPackage>> packages(Biller biller) async =>
      MockData.packages[biller.id] ?? const [];

  @override
  Future<BillCustomer> validateCustomer(
    Biller biller,
    String customerId,
  ) async {
    await Future<void>.delayed(latency ~/ 2);
    final ok =
        RegExp(r'^\d+$').hasMatch(customerId) &&
        customerId.length >= biller.minIdLength &&
        customerId.length <= biller.maxIdLength;
    if (!ok) {
      final len = biller.minIdLength == biller.maxIdLength
          ? '${biller.minIdLength}'
          : '${biller.minIdLength}–${biller.maxIdLength}';
      throw BillCustomerNotFoundException(
        'A ${biller.shortName} ${biller.customerIdLabel} has $len digits.',
      );
    }
    if (customerId.startsWith('0000')) {
      throw BillCustomerNotFoundException(
        "I couldn't find ${biller.customerIdLabel} $customerId with ${biller.shortName}.",
      );
    }
    return BillCustomer(
      name: customerName,
      address: biller.category == BillCategory.electricity
          ? MockData.billCustomerAddress
          : null,
    );
  }

  @override
  Future<PaymentResult> pay(BillDraft draft, AuthorizationToken token) async {
    await Future<void>.delayed(latency);
    final ref = _ref(_random);
    final now = DateTime.now();
    final b = draft.biller;
    final details = <String, String>{
      'Biller': b.name,
      _cap(b.customerIdLabel): draft.customerId,
      'Customer Name': draft.customer.name,
      if (draft.package != null) 'Package': draft.package!.name,
    };
    if (b.category == BillCategory.electricity) {
      final token = List.generate(
        5,
        (_) => List.generate(4, (_) => _random.nextInt(10)).join(),
      ).join('-');
      details['Token'] = token;
      details['Units'] =
          '${(draft.amountKobo / 100 / _nairaPerKwh).toStringAsFixed(1)} kWh';
    }
    history.record(
      TransactionRecord(
        reference: ref,
        title: draft.package == null
            ? '${b.shortName} electricity'
            : '${b.shortName} ${draft.package!.name}',
        category: TransactionCategory.bill,
        amountKobo: draft.amountKobo,
        timestamp: now,
        status: TransactionStatus.successful,
        channel: b.category.displayName,
        details: details,
      ),
    );
    return PaymentResult(
      status: PaymentStatus.successful,
      reference: ref,
      timestamp: now,
      draft: draft,
      details: {
        if (details['Token'] != null) 'Token': details['Token']!,
        if (details['Units'] != null) 'Units': details['Units']!,
      },
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

String _naira(int kobo) {
  final s = (kobo ~/ 100).toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '₦$b.${(kobo % 100).toString().padLeft(2, '0')}';
}

String _date(DateTime t) {
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${m[t.month - 1]} ${t.day}, ${t.year}';
}

String _period(int days) => switch (days) {
  365 => '1 year',
  30 => '1 month',
  _ => '${days ~/ 30} months',
};
