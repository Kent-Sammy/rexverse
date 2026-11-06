import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/features/rexflex/domain/rexflex_models.dart';
import 'package:rex_atlas/features/rexflex/presentation/agreement/loan_agreement_pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds a real PDF loan agreement from the loan', () async {
    final loan =
        FlexLoan(
            id: 'RF0001',
            term: LoanTerm.priced(300000, 14),
            appliedAt: DateTime(2026, 11, 20, 9),
          )
          ..status = LoanStatus.active
          ..startDate = DateTime(2026, 11, 20, 9)
          ..dueDate = DateTime(2026, 12, 4, 9);
    final bytes = await buildLoanAgreementPdf(
      loan: loan,
      borrowerName: 'Ololade Mr. Money',
      accountLabel: 'REXMFB ******1921',
      compress: false,
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(5000));
    final text = String.fromCharCodes(bytes);
    expect(text, contains('RexFlex Loan Agreement RF0001')); // document title
  });
}
