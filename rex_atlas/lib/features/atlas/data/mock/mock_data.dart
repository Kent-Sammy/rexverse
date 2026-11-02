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
}
