import '../../domain/models/models.dart';

/// Demo fixtures. Names, numbers and dates come from the Figma frames so the
/// prototype reproduces the designed screens. None of this is real data.
abstract final class MockData {
  static const user = SourceAccount(
    holderName: 'OLOLADE MR. MONEY',
    firstName: 'Ololade',
    bankName: 'REXMFB',
    accountNumber: '11028281921',
  );

  static const banks = <Bank>[
    Bank(code: '058', name: 'GTBank Plc', shortName: 'GTBank'),
    Bank(code: '044', name: 'Access Bank Plc', shortName: 'Access'),
    Bank(code: '057', name: 'Zenith Bank Plc', shortName: 'Zenith'),
    Bank(code: '033', name: 'United Bank for Africa', shortName: 'UBA'),
    Bank(code: '011', name: 'First Bank of Nigeria', shortName: 'FirstBank'),
    Bank(code: '070', name: 'Fidelity Bank Plc', shortName: 'Fidelity'),
    Bank(code: '035', name: 'Wema Bank Plc', shortName: 'Wema'),
    Bank(code: '50211', name: 'Kuda Microfinance Bank', shortName: 'Kuda'),
    Bank(code: '999992', name: 'OPay Digital Services', shortName: 'OPay'),
    Bank(code: '50515', name: 'Moniepoint MFB', shortName: 'Moniepoint'),
  ];

  /// Free-text aliases → bank code.
  static const bankAliases = <String, String>{
    'gtb': '058',
    'gtbank': '058',
    'guaranty': '058',
    'guaranty trust': '058',
    'access': '044',
    'zenith': '057',
    'uba': '033',
    'united bank': '033',
    'first bank': '011',
    'firstbank': '011',
    'fbn': '011',
    'fidelity': '070',
    'wema': '035',
    'kuda': '50211',
    'opay': '999992',
    'moniepoint': '50515',
  };

  /// Name-enquiry fixtures. Unknown 10-digit numbers resolve to a name
  /// picked from [_fallbackNames]; numbers starting with 000000 fail.
  static const knownAccounts = <String, String>{
    '058:0004218716': 'ODELEYE OLAYINKA ANTHONY',
  };

  static const fallbackNames = [
    'ADEBAYO FUNMILAYO GRACE',
    'CHUKWU EMEKA DANIEL',
    'BELLO AISHA MARYAM',
    'OKAFOR CHIDINMA JOY',
    'ADEYEMI TUNDE SAMUEL',
  ];

  static List<TransactionRecord> seedHistory() => [
    TransactionRecord(
      reference: '7065142730001',
      title: 'Card Payment',
      category: TransactionCategory.cardPayment,
      amountKobo: 10000,
      timestamp: DateTime(2021, 5, 28, 10, 12),
      status: TransactionStatus.successful,
      channel: 'POS 01',
    ),
    TransactionRecord(
      reference: '7065142730002',
      title: 'Transfer to K. Adewale',
      category: TransactionCategory.transfer,
      amountKobo: 10000,
      timestamp: DateTime(2021, 5, 28, 9, 40),
      status: TransactionStatus.successful,
      counterpartyBankLabel: 'Access (0123456789)',
    ),
    TransactionRecord(
      reference: '7065142730003',
      title: 'Airtime Purchase',
      category: TransactionCategory.airtime,
      amountKobo: 10000,
      timestamp: DateTime(2021, 5, 28, 8, 5),
      status: TransactionStatus.successful,
      channel: 'Personal',
    ),
    TransactionRecord(
      reference: '7065142730004',
      title: 'Business Transfer',
      category: TransactionCategory.businessTransfer,
      amountKobo: 10000,
      timestamp: DateTime(2021, 5, 28, 7, 30),
      status: TransactionStatus.successful,
    ),
  ];

  /// The "Recent Transactions" card on the welcome sheet.
  static TransactionRecord seedLatestTransfer() => TransactionRecord(
    reference: '7065142730000',
    title: 'Tunde Adeyemi',
    category: TransactionCategory.transfer,
    amountKobo: 500000,
    timestamp: DateTime(2026, 10, 25, 19, 30),
    status: TransactionStatus.successful,
    counterpartyName: 'Tunde Adeyemi',
    counterpartyMasked: 'GTBank **** 8716',
    counterpartyBankLabel: 'GTBank (0004218716)',
  );

  // ---------------------------------------------------------------- bills
  // Illustrative providers and prices for the demo, not live tariffs.

  static const billers = <Biller>[
    Biller(
      id: 'ikedc',
      name: 'Ikeja Electric (IKEDC)',
      shortName: 'IKEDC',
      category: BillCategory.electricity,
      customerIdLabel: 'meter number',
      minIdLength: 11,
      maxIdLength: 13,
      minAmountKobo: 100000,
      maxAmountKobo: 50000000,
    ),
    Biller(
      id: 'ekedc',
      name: 'Eko Electric (EKEDC)',
      shortName: 'EKEDC',
      category: BillCategory.electricity,
      customerIdLabel: 'meter number',
      minIdLength: 11,
      maxIdLength: 13,
      minAmountKobo: 100000,
      maxAmountKobo: 50000000,
    ),
    Biller(
      id: 'aedc',
      name: 'Abuja Electric (AEDC)',
      shortName: 'AEDC',
      category: BillCategory.electricity,
      customerIdLabel: 'meter number',
      minIdLength: 11,
      maxIdLength: 13,
      minAmountKobo: 100000,
      maxAmountKobo: 50000000,
    ),
    Biller(
      id: 'ibedc',
      name: 'Ibadan Electric (IBEDC)',
      shortName: 'IBEDC',
      category: BillCategory.electricity,
      customerIdLabel: 'meter number',
      minIdLength: 11,
      maxIdLength: 13,
      minAmountKobo: 100000,
      maxAmountKobo: 50000000,
    ),
    Biller(
      id: 'phed',
      name: 'Port Harcourt Electric (PHED)',
      shortName: 'PHED',
      category: BillCategory.electricity,
      customerIdLabel: 'meter number',
      minIdLength: 11,
      maxIdLength: 13,
      minAmountKobo: 100000,
      maxAmountKobo: 50000000,
    ),
    Biller(
      id: 'eedc',
      name: 'Enugu Electric (EEDC)',
      shortName: 'EEDC',
      category: BillCategory.electricity,
      customerIdLabel: 'meter number',
      minIdLength: 11,
      maxIdLength: 13,
      minAmountKobo: 100000,
      maxAmountKobo: 50000000,
    ),
    Biller(
      id: 'dstv',
      name: 'DStv',
      shortName: 'DStv',
      category: BillCategory.cableTv,
      customerIdLabel: 'smartcard number',
      minIdLength: 10,
      maxIdLength: 11,
    ),
    Biller(
      id: 'gotv',
      name: 'GOtv',
      shortName: 'GOtv',
      category: BillCategory.cableTv,
      customerIdLabel: 'IUC number',
      minIdLength: 10,
      maxIdLength: 11,
    ),
    Biller(
      id: 'startimes',
      name: 'StarTimes',
      shortName: 'StarTimes',
      category: BillCategory.cableTv,
      customerIdLabel: 'smartcard number',
      minIdLength: 10,
      maxIdLength: 11,
    ),
    Biller(
      id: 'spectranet',
      name: 'Spectranet',
      shortName: 'Spectranet',
      category: BillCategory.internet,
      customerIdLabel: 'account ID',
      minIdLength: 10,
      maxIdLength: 10,
    ),
    Biller(
      id: 'smile',
      name: 'Smile',
      shortName: 'Smile',
      category: BillCategory.internet,
      customerIdLabel: 'account ID',
      minIdLength: 10,
      maxIdLength: 10,
    ),
  ];

  static const billerAliases = <String, String>{
    'ikedc': 'ikedc',
    'ikeja electric': 'ikedc',
    'ikeja': 'ikedc',
    'ekedc': 'ekedc',
    'eko electric': 'ekedc',
    'eko': 'ekedc',
    'aedc': 'aedc',
    'abuja electric': 'aedc',
    'abuja': 'aedc',
    'ibedc': 'ibedc',
    'ibadan electric': 'ibedc',
    'ibadan': 'ibedc',
    'phed': 'phed',
    'port harcourt electric': 'phed',
    'port harcourt': 'phed',
    'eedc': 'eedc',
    'enugu electric': 'eedc',
    'enugu': 'eedc',
    'dstv': 'dstv',
    'gotv': 'gotv',
    'startimes': 'startimes',
    'star times': 'startimes',
    'spectranet': 'spectranet',
    'smile': 'smile',
  };

  static const packages = <String, List<BillPackage>>{
    'dstv': [
      BillPackage(id: 'dstv-padi', name: 'Padi', amountKobo: 440000),
      BillPackage(id: 'dstv-yanga', name: 'Yanga', amountKobo: 600000),
      BillPackage(id: 'dstv-confam', name: 'Confam', amountKobo: 1100000),
      BillPackage(id: 'dstv-compact', name: 'Compact', amountKobo: 1900000),
      BillPackage(
        id: 'dstv-compact-plus',
        name: 'Compact Plus',
        amountKobo: 3000000,
      ),
      BillPackage(id: 'dstv-premium', name: 'Premium', amountKobo: 4450000),
    ],
    'gotv': [
      BillPackage(id: 'gotv-smallie', name: 'Smallie', amountKobo: 190000),
      BillPackage(id: 'gotv-jinja', name: 'Jinja', amountKobo: 390000),
      BillPackage(id: 'gotv-jolli', name: 'Jolli', amountKobo: 580000),
      BillPackage(id: 'gotv-max', name: 'Max', amountKobo: 850000),
      BillPackage(id: 'gotv-supa', name: 'Supa', amountKobo: 1140000),
    ],
    'startimes': [
      BillPackage(id: 'st-nova', name: 'Nova', amountKobo: 190000),
      BillPackage(id: 'st-basic', name: 'Basic', amountKobo: 370000),
      BillPackage(id: 'st-classic', name: 'Classic', amountKobo: 550000),
    ],
    'spectranet': [
      BillPackage(id: 'spec-lite', name: 'Unlimited Lite', amountKobo: 1500000),
      BillPackage(id: 'spec-plus', name: 'Unlimited Plus', amountKobo: 2500000),
      BillPackage(
        id: 'spec-premium',
        name: 'Unlimited Premium',
        amountKobo: 3500000,
      ),
    ],
    'smile': [
      BillPackage(id: 'smile-10gb', name: '10GB Monthly', amountKobo: 500000),
      BillPackage(id: 'smile-30gb', name: '30GB Monthly', amountKobo: 1100000),
      BillPackage(
        id: 'smile-unl',
        name: 'Unlimited Monthly',
        amountKobo: 2000000,
      ),
    ],
  };

  static const billCustomerAddress = '14 Admiralty Way, Lekki, Lagos';

  // -------------------------------------------------------- savings/vault
  static const rexSaveRatePct = 12.0;
  static const rexyDecemberBonusPct = 5.0;
  static const vaultRates = <int, double>{
    30: 14.0,
    90: 16.0,
    180: 18.0,
    365: 20.0,
  };
}
