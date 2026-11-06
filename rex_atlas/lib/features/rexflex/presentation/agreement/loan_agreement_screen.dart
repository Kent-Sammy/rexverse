import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../../app/demo_device_frame.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';
import '../../application/rexflex_controller.dart';
import '../../domain/rexflex_models.dart';
import '../widgets/flex_ui.dart';
import 'loan_agreement_pdf.dart';

/// The loan agreement as a real PDF: previewed in-app, with share, print
/// and download (save) actions from the platform.
class LoanAgreementScreen extends StatelessWidget {
  const LoanAgreementScreen({
    super.key,
    required this.controller,
    required this.loan,
  });
  final RexFlexController controller;
  final FlexLoan loan;

  @override
  Widget build(BuildContext context) {
    final top = math.max(MediaQuery.paddingOf(context).top, 20.0) + 4;
    return Scaffold(
      backgroundColor: FlexColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: top),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Pressable(
                          key: const Key('flex-back'),
                          semanticLabel: 'Back',
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                Icons.arrow_back,
                                color: RexColors.textStrong,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Semantics(
                        header: true,
                        child: Text(
                          'Loan Agreement',
                          style: RexTypography.host(
                            17,
                            weight: FontWeight.w700,
                            color: FlexColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PdfPreview(
                  pdfFileName: 'RexFlex-Loan-Agreement-${loan.id}.pdf',
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  allowPrinting: true,
                  allowSharing: true,
                  scrollViewDecoration: const BoxDecoration(
                    color: FlexColors.background,
                  ),
                  actionBarTheme: const PdfActionBarTheme(
                    backgroundColor: FlexColors.navy,
                    iconColor: Colors.white,
                  ),
                  build: (format) async {
                    final account = await controller.loadAccount();
                    return buildLoanAgreementPdf(
                      loan: loan,
                      borrowerName: account.holderName,
                      accountLabel: account.maskedLabel,
                      format: format,
                    );
                  },
                ),
              ),
            ],
          ),
          if (DemoDeviceFrame.showsStatusBar(context))
            const Positioned(left: 0, right: 0, top: 0, child: DemoStatusBar()),
        ],
      ),
    );
  }
}
