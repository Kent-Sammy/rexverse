import '../../../core/formatting/dates.dart';
import '../../../core/formatting/naira.dart';
import '../../atlas/data/mock/mock_history_services.dart';
import '../../atlas/domain/models/models.dart';
import '../../atlas/domain/services/services.dart';
import '../../rexflex/rexflex.dart';
import '../domain/account_transaction.dart';

/// Everything that moved through the customer's accounts: payments made in
/// Atlas, RexFlex loans and repayments, and demo account activity
/// (incoming transfers, POS settlements, RexSave and RexVault, bills).
///
/// All entries are simulated demo data.
class TransactionsFeed implements ReceiptService {
  TransactionsFeed({
    required this.history,
    required this.receipts,
    required this.rexflex,
    required this.accounts,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final TransactionHistoryService history;
  final ReceiptService receipts;
  final RexFlexController rexflex;
  final AccountService accounts;
  late SourceAccount _account;
  final DateTime Function() _clock;

  final Map<String, AccountTransaction> _byRef = {};

  DateTime get now => _clock();

  /// Newest first.
  Future<List<AccountTransaction>> load() async {
    _account = await accounts.primaryAccount();
    final atlas = await history.recent(limit: 1000);
    final latest = history.latestTransfer;
    final records = [
      ...atlas,
      if (latest != null && atlas.every((r) => r.reference != latest.reference))
        latest,
    ];
    final all = <AccountTransaction>[
      for (final r in records) _fromAtlas(r),
      for (final loan in rexflex.loans)
        for (final t in loan.transactions) _fromFlex(loan, t),
      ..._demoActivity(now),
    ]..sort((a, b) => b.at.compareTo(a.at));
    _byRef
      ..clear()
      ..addEntries(all.map((t) => MapEntry(t.reference, t)));
    return all;
  }

  // -------------------------------------------------------------- sources

  AccountTransaction _fromAtlas(TransactionRecord r) {
    final (kind, account) = switch (r.category) {
      TransactionCategory.cardPayment => (TxnKind.card, TxnAccount.pos),
      TransactionCategory.transfer => (TxnKind.transfer, TxnAccount.personal),
      TransactionCategory.businessTransfer => (
        TxnKind.transfer,
        TxnAccount.business,
      ),
      TransactionCategory.airtime => (TxnKind.airtime, TxnAccount.personal),
      TransactionCategory.savings => (TxnKind.rexsave, TxnAccount.personal),
      TransactionCategory.vault => (TxnKind.rexvault, TxnAccount.personal),
      TransactionCategory.bill => (TxnKind.bill, TxnAccount.personal),
    };
    final title =
        r.category == TransactionCategory.transfer &&
            !r.title.startsWith('Transfer')
        ? 'Transfer to ${r.title}'
        : r.title;
    return AccountTransaction(
      reference: r.reference,
      title: title,
      channel: account == TxnAccount.pos ? (r.channel ?? 'POS') : account.label,
      account: account,
      kind: kind,
      direction: TxnDirection.debit,
      amountKobo: r.amountKobo,
      at: r.timestamp,
      status: r.status,
      counterparty: r.counterpartyName?.toUpperCase(),
      fromAtlasHistory: true,
      isSimulated: r.isSimulated,
    );
  }

  AccountTransaction _fromFlex(FlexLoan loan, LoanTxn t) => AccountTransaction(
    reference: t.reference,
    title: switch (t.kind) {
      LoanTxnKind.disbursement => 'RexFlex Loan Received',
      LoanTxnKind.partialRepayment => 'RexFlex Repayment',
      LoanTxnKind.fullRepayment => 'RexFlex Repayment (Full)',
    },
    channel: 'Personal',
    account: TxnAccount.personal,
    kind: TxnKind.rexflex,
    direction: t.isCredit ? TxnDirection.credit : TxnDirection.debit,
    amountKobo: t.amountKobo,
    at: t.at,
    description: 'RexFlex loan ${loan.id}',
    counterparty: 'REXFLEX LOAN',
    counterpartyLine: 'Loan ID ${loan.id}',
  );

  /// Demo activity relative to [now], so the page always looks current.
  static List<AccountTransaction> _demoActivity(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    DateTime at(int daysAgo, int h, int m) {
      final t = today
          .subtract(Duration(days: daysAgo))
          .add(Duration(hours: h, minutes: m));
      // Today's entries never sit in the future.
      return t.isAfter(now) ? now.subtract(Duration(minutes: 5 + m % 7)) : t;
    }

    AccountTransaction t(
      String ref,
      String title,
      String channel,
      TxnAccount account,
      TxnKind kind,
      TxnDirection dir,
      int naira,
      DateTime when, {
      TransactionStatus status = TransactionStatus.successful,
      String? who,
      String? whoLine,
      String? description,
    }) => AccountTransaction(
      reference: ref,
      title: title,
      channel: channel,
      account: account,
      kind: kind,
      direction: dir,
      amountKobo: naira * 100,
      at: when,
      status: status,
      counterparty: who,
      counterpartyLine: whoLine,
      description: description,
    );

    const cr = TxnDirection.credit, dr = TxnDirection.debit;
    const personal = TxnAccount.personal,
        business = TxnAccount.business,
        pos = TxnAccount.pos;
    return [
      // Today
      t(
        'DEMO-TX-1001',
        'Transfer from Chidinma Okafor',
        'Personal',
        personal,
        TxnKind.transfer,
        cr,
        150000,
        at(0, 8, 12),
        who: 'CHIDINMA OKAFOR',
        whoLine: 'Access | 012****789',
      ),
      t(
        'DEMO-TX-1002',
        'POS Settlement',
        'POS 01',
        pos,
        TxnKind.card,
        cr,
        82600,
        at(0, 7, 40),
        description: 'Daily POS settlement',
      ),
      t(
        'DEMO-TX-1003',
        'RexSave Interest',
        'Personal',
        personal,
        TxnKind.rexsave,
        cr,
        1250,
        at(0, 6, 5),
        description: 'Daily interest on RexSave',
      ),
      t(
        'DEMO-TX-1004',
        'Card Payment',
        'POS 02',
        pos,
        TxnKind.card,
        dr,
        12500,
        at(0, 9, 3),
        description: 'Card payment at POS 02',
      ),
      t(
        'DEMO-TX-1005',
        'Data Purchase',
        'Personal',
        personal,
        TxnKind.data,
        dr,
        3000,
        at(0, 7, 15),
        description: 'MTN 10GB monthly',
      ),
      // Yesterday
      t(
        'DEMO-TX-0901',
        'Transfer from Bello Aisha',
        'Rex Ventures',
        business,
        TxnKind.transfer,
        cr,
        250000,
        at(1, 16, 20),
        who: 'BELLO AISHA MARYAM',
        whoLine: 'Zenith | 221****004',
      ),
      t(
        'DEMO-TX-0902',
        'Business Transfer',
        'Rex Ventures',
        business,
        TxnKind.transfer,
        dr,
        45000,
        at(1, 14, 2),
        who: 'ADEYEMI SUPPLIES LTD',
        whoLine: 'UBA | 102****448',
      ),
      t(
        'DEMO-TX-0903',
        'RexVault Deposit',
        'Personal',
        personal,
        TxnKind.rexvault,
        dr,
        50000,
        at(1, 11, 30),
        description: 'Locked for 90 days',
      ),
      t(
        'DEMO-TX-0904',
        'Transfer to Musa Bello',
        'Personal',
        personal,
        TxnKind.transfer,
        dr,
        7500,
        at(1, 10, 45),
        status: TransactionStatus.pending,
        who: 'MUSA BELLO',
        whoLine: 'Opay | 813****552',
      ),
      // Earlier this week
      t(
        'DEMO-TX-0801',
        'Electricity Token',
        'Personal',
        personal,
        TxnKind.bill,
        dr,
        10000,
        at(2, 19, 10),
        description: 'Prepaid meter 4510****882',
      ),
      t(
        'DEMO-TX-0802',
        'RexVault Interest',
        'Personal',
        personal,
        TxnKind.rexvault,
        cr,
        3400,
        at(2, 6, 0),
        description: 'Interest on RexVault',
      ),
      t(
        'DEMO-TX-0803',
        'RexSave Deposit',
        'Personal',
        personal,
        TxnKind.rexsave,
        dr,
        20000,
        at(2, 9, 30),
        description: 'Rexy December plan',
      ),
      t(
        'DEMO-TX-0701',
        'Airtime Purchase',
        'Personal',
        personal,
        TxnKind.airtime,
        dr,
        2000,
        at(3, 12, 0),
        description: 'Airtime for 0803****567',
      ),
      t(
        'DEMO-TX-0702',
        'Data Purchase',
        'Personal',
        personal,
        TxnKind.data,
        dr,
        1500,
        at(3, 12, 4),
        status: TransactionStatus.failed,
        description: 'Failed and reversed',
      ),
      t(
        'DEMO-TX-0703',
        'POS Settlement',
        'POS 03',
        pos,
        TxnKind.card,
        cr,
        64300,
        at(3, 7, 30),
        description: 'Daily POS settlement',
      ),
      t(
        'DEMO-TX-0601',
        'Cable TV Subscription',
        'Personal',
        personal,
        TxnKind.bill,
        dr,
        15000,
        at(4, 20, 15),
        description: 'Monthly TV plan',
      ),
      t(
        'DEMO-TX-0602',
        'RexSave Withdrawal',
        'Personal',
        personal,
        TxnKind.rexsave,
        cr,
        20000,
        at(5, 13, 40),
        description: 'From RexSave to main account',
      ),
    ];
  }

  // -------------------------------------------------------------- receipts

  @override
  Future<Receipt> receiptFor(String reference) async {
    final t = _byRef[reference];
    if (t == null || t.fromAtlasHistory) {
      return receipts.receiptFor(reference);
    }
    return receiptOf(t);
  }

  Receipt receiptOf(AccountTransaction t) {
    final me =
        '${_account.holderName.toUpperCase()}\n'
        '${_account.bankName} | '
        '${MockReceiptBuilder.maskAccount(_account.accountNumber)}';
    final other = t.counterparty == null
        ? null
        : [t.counterparty!, ?t.counterpartyLine].join('\n');
    return Receipt(
      reference: t.reference,
      title: t.title,
      amountKobo: t.amountKobo,
      status: t.status,
      isSimulated: t.isSimulated,
      timestamp: t.at,
      rows: [
        ReceiptRow('Transaction No.', t.reference, copyable: true),
        if (t.counterparty != null)
          ReceiptRow(
            t.isCredit ? 'Sender’s Name' : 'Recipient’s Name',
            t.counterparty!,
          ),
        ReceiptRow('Amount', Naira.grouped(t.amountKobo)),
        ReceiptRow('Transaction Type', t.isCredit ? 'Credit' : 'Debit'),
        ReceiptRow('Category', t.kind.typeLabel),
        ReceiptRow('Account', t.channel),
        if (t.description != null) ReceiptRow('Description', t.description!),
        ReceiptRow('Transaction Date', RexDates.receipt(t.at)),
      ],
      shareRows: [
        // Money in: they sent it to me. Money out: I sent it to them.
        if (t.isCredit && other != null) ReceiptRow('Sender Details', other),
        ReceiptRow(t.isCredit ? 'Recipient Details' : 'Sender Details', me),
        if (!t.isCredit && other != null)
          ReceiptRow('Recipient Details', other),
        ReceiptRow('Transaction Type', t.kind.typeLabel),
        if (t.description != null) ReceiptRow('Description', t.description!),
        ReceiptRow('Transaction No.', t.reference, copyable: true),
        ReceiptRow('Transaction Date', RexDates.receipt(t.at)),
      ],
    );
  }
}
