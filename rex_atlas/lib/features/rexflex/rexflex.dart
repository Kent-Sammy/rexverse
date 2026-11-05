/// RexFlex: short-term loans (simulated in this prototype).
library;

export 'application/rexflex_controller.dart';
export 'application/rexflex_loan_overview.dart';
export 'data/mock_rexflex_service.dart';
export 'domain/rexflex_models.dart';
export 'domain/rexflex_service.dart';
export 'presentation/screens/rexflex_screens.dart'
    show
        openRexFlex,
        openRexFlexLoan,
        startRexFlexFromAtlas,
        viewRexFlexLoanFromAtlas;
