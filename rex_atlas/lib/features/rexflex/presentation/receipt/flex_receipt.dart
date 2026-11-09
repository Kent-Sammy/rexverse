import '../../../../core/formatting/dates.dart';
import '../../../../core/formatting/naira.dart';
import '../../../atlas/data/mock/mock_history_services.dart';
import '../../../atlas/domain/models/models.dart';
import '../../domain/rexflex_models.dart';

/// A RexFlex repayment as a [Receipt], so it opens in the shared
/// "Share Receipt" screen (image / PDF) used across the app.
Receipt flexRepaymentReceipt({
  required FlexLoan loan,
  required RepaymentResult result,
  required SourceAccount account,
}) {
  final status = result.settled ? 'Settled' : 'Active';
  return Receipt(
    reference: result.reference,
    title: 'RexFlex Loan Repayment',
    amountKobo: result.paidKobo,
    status: TransactionStatus.successful,
    isSimulated: result.isSimulated,
    timestamp: result.at,
    rows: [
      ReceiptRow('Transaction No.', result.reference, copyable: true),
      ReceiptRow('Amount Paid', Naira.grouped(result.paidKobo)),
      ReceiptRow('Outstanding Balance', Naira.grouped(result.outstandingKobo)),
      ReceiptRow('Loan ID', loan.id),
      ReceiptRow('Loan Status', status),
      ReceiptRow('Transaction Date', RexDates.receipt(result.at)),
    ],
    shareRows: [
      ReceiptRow('Paid To', 'REXFLEX LOAN\nLoan ID ${loan.id}'),
      ReceiptRow(
        'Paid From',
        '${account.holderName.toUpperCase()}\n'
            '${account.bankName} | '
            '${MockReceiptBuilder.maskAccount(account.accountNumber)}',
      ),
      const ReceiptRow('Transaction Type', 'Loan Repayment'),
      ReceiptRow('Loan Amount', Naira.grouped(loan.principalKobo)),
      ReceiptRow('Outstanding Balance', Naira.grouped(result.outstandingKobo)),
      ReceiptRow('Loan Status', status),
      ReceiptRow('Transaction No.', result.reference, copyable: true),
      ReceiptRow('Transaction Date', RexDates.receipt(result.at)),
    ],
  );
}
