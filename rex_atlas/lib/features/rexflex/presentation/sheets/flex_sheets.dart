import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/formatting/naira.dart';
import '../../../../core/widgets/appear.dart';
import '../../../../core/widgets/pressable.dart';
import '../../application/rexflex_controller.dart';
import '../../domain/rexflex_models.dart';
import '../widgets/flex_pin_entry.dart';
import '../widgets/flex_ui.dart';

String _days(int d) => '$d days';
String _interestLabel() => 'Interest (${RexFlexPricing.ratePer30DaysPct}%)';

// ---------------------------------------------------------------------------
// Eligibility: "Check Your Eligibility" → "You're Eligible!"
// ---------------------------------------------------------------------------

/// Returns the offer amount (kobo) when the customer taps Continue.
class EligibilitySheet extends StatefulWidget {
  const EligibilitySheet({super.key, required this.controller});
  final RexFlexController controller;

  @override
  State<EligibilitySheet> createState() => _EligibilitySheetState();
}

class _EligibilitySheetState extends State<EligibilitySheet> {
  bool _checking = false;
  EligibilityResult? _result;

  Future<void> _check() async {
    setState(() => _checking = true);
    final r = await widget.controller.checkEligibility();
    if (mounted) {
      setState(() {
        _checking = false;
        _result = r;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        child: r == null ? _checkView() : _eligibleView(r),
      ),
    );
  }

  Widget _checkView() {
    const criteria = [
      (
        Icons.account_balance_rounded,
        'Active Rex Account',
        'For at least 30 days',
      ),
      (
        Icons.account_balance_outlined,
        'At least 2 external inflows',
        'On different days',
      ),
      (
        Icons.donut_large_rounded,
        'Total inflows of ₦10,000+',
        'In the last 30 days',
      ),
    ];
    return FlexSheet(
      key: const ValueKey('check'),
      title: 'Check Your Eligibility',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            decoration: BoxDecoration(
              color: FlexColors.panel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (final (icon, title, sub) in criteria)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        FlexIconBubble(
                          icon: icon,
                          bg: Colors.white,
                          fg: const Color(0xFF3D7BF7),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: RexTypography.host(
                                  13,
                                  weight: FontWeight.w500,
                                  color: RexColors.textStrong,
                                ),
                              ),
                              Text(
                                sub,
                                style: RexTypography.host(
                                  11,
                                  weight: FontWeight.w500,
                                  color: FlexColors.label,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const FlexNote(
            "We'll use your account information to check your eligibility.",
          ),
          const SizedBox(height: 28),
          FlexButton(
            key: const Key('flex-check-eligibility'),
            label: 'Check Eligibility',
            busy: _checking,
            onTap: _check,
          ),
        ],
      ),
    );
  }

  Widget _eligibleView(EligibilityResult r) {
    final offers = widget.controller.offersFor(r.offerKobo);
    const tints = [
      (Color(0xFFF3E8FF), FlexColors.purple),
      (Color(0xFFE3F9E8), FlexColors.green),
    ];
    return FlexSheet(
      key: const ValueKey('eligible'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FlexSuccessHeader(
            title: "You're Eligible!",
            subtitle: 'You can apply for a RexFlex loan.',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FlexColors.panel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your ${widget.controller.hasHistory ? 'next' : 'first'} loan offer',
                        style: RexTypography.host(
                          12,
                          weight: FontWeight.w500,
                          color: FlexColors.label,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Naira.groupedWhole(r.offerKobo),
                        style: RexTypography.host(
                          22,
                          weight: FontWeight.w700,
                          color: RexColors.textStrong,
                        ),
                      ),
                    ],
                  ),
                ),
                const FlexIconBubble(
                  icon: Icons.account_balance_rounded,
                  bg: Colors.white,
                  fg: Color(0xFF3D7BF7),
                  size: 34,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < offers.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tints[i % 2].$1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        FlexIconBubble(
                          icon: Icons.hourglass_bottom_rounded,
                          bg: Colors.white,
                          fg: tints[i % 2].$2,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _days(offers[i].days),
                                style: RexTypography.host(
                                  13,
                                  weight: FontWeight.w600,
                                  color: RexColors.textStrong,
                                ),
                              ),
                              Text(
                                'Repay ${Naira.grouped(offers[i].totalKobo)}',
                                style: RexTypography.host(
                                  11,
                                  weight: FontWeight.w500,
                                  color: FlexColors.label,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          const FlexNote('8% interest per 30 days'),
          const SizedBox(height: 24),
          FlexButton(
            key: const Key('flex-eligible-continue'),
            label: 'Continue',
            onTap: () => Navigator.of(context).pop(r.offerKobo),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Application: "Application Received" timeline → "Loan Approved!"
// ---------------------------------------------------------------------------

/// Pops `true` when the customer taps "View Loan".
class ApplicationSheet extends StatelessWidget {
  const ApplicationSheet({
    super.key,
    required this.controller,
    required this.loan,
  });
  final RexFlexController controller;
  final FlexLoan loan;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: Alignment.bottomCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: loan.status == LoanStatus.pending
              ? _received(context)
              : _approved(context),
        ),
      ),
    );
  }

  Widget _received(BuildContext context) {
    final current = loan.stage?.index ?? 0;
    return FlexSheet(
      key: const ValueKey('received'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ExcludeSemantics(
            child: Text(
              '⏳',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 56),
            ),
          ),
          const SizedBox(height: 10),
          Semantics(
            header: true,
            child: Text(
              'Application Received',
              textAlign: TextAlign.center,
              style: RexTypography.host(
                18,
                weight: FontWeight.w700,
                color: RexColors.textStrong,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "We're processing your application. You'll get an update shortly.",
            textAlign: TextAlign.center,
            style: RexTypography.host(13, color: FlexColors.navy),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            decoration: BoxDecoration(
              color: FlexColors.panel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (final stage in ApplicationStage.values)
                  _StageRow(
                    stage: stage,
                    done: stage.index <= current,
                    last: stage == ApplicationStage.values.last,
                  ),
              ],
            ),
          ),
          const FlexDemoLabel(text: 'Demo review · no real credit check runs'),
        ],
      ),
    );
  }

  Widget _approved(BuildContext context) {
    final start = loan.startDate!;
    return FlexSheet(
      key: const ValueKey('approved'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FlexSuccessHeader(
            title: 'Loan Approved!',
            subtitle: 'Your loan has been disbursed to your Rex account',
          ),
          const SizedBox(height: 18),
          FlexDetailBox(
            title: 'Loan Details',
            rows: [
              ('Loan Amount', Naira.grouped(loan.principalKobo)),
              ('Total to Repay', Naira.grouped(loan.totalKobo)),
              (_interestLabel(), Naira.plain(loan.interestKobo)),
              ('Tenor', _days(loan.term.days)),
              ('Start Date', RexDates.dayMonthYear(start)),
              ('Due Date', RexDates.dayMonthYear(loan.dueDate!)),
            ],
          ),
          const SizedBox(height: 20),
          FlexButton(
            key: const Key('flex-view-loan'),
            label: 'View Loan',
            onTap: () => Navigator.of(context).pop(true),
          ),
          const FlexDemoLabel(),
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.done,
    required this.last,
  });
  final ApplicationStage stage;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${stage.title}, ${done ? 'complete' : 'waiting'}',
      child: ExcludeSemantics(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? const Color(0xFF3D6FE8) : Colors.white,
                      border: Border.all(
                        color: done
                            ? const Color(0xFFBFD2FF)
                            : const Color(0xFFD5E1F7),
                        width: 3,
                      ),
                    ),
                    child: done
                        ? const Icon(Icons.check, size: 13, color: Colors.white)
                        : null,
                  ),
                  if (!last)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: done
                            ? const Color(0xFFBFD2FF)
                            : const Color(0xFFDDE7FA),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.title,
                        style: RexTypography.host(
                          13,
                          weight: FontWeight.w600,
                          color: RexColors.textStrong,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stage.detail,
                        style: RexTypography.host(
                          11,
                          weight: FontWeight.w500,
                          color: FlexColors.label,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Repayment: choose → (amount) → review → PIN → processing → success
// ---------------------------------------------------------------------------

enum _RepayStep { choose, amount, review, pin, processing, success }

/// Returns the [RepaymentResult] once a payment succeeds, or null when the
/// sheet is closed before paying. When the loan was settled and the
/// customer taps "View Loan Details", pops `(result, true)`.
class RepaymentSheet extends StatefulWidget {
  const RepaymentSheet({
    super.key,
    required this.controller,
    required this.loan,
  });
  final RexFlexController controller;
  final FlexLoan loan;

  @override
  State<RepaymentSheet> createState() => _RepaymentSheetState();
}

class _RepaymentSheetState extends State<RepaymentSheet> {
  _RepayStep _step = _RepayStep.choose;
  bool _full = true;
  final _amountField = TextEditingController();
  int _partialKobo = 0;
  RepaymentResult? _result;
  String? _amountError;

  FlexLoan get loan => widget.loan;
  int get _payKobo => _full ? loan.outstandingKobo : _partialKobo;

  @override
  void initState() {
    super.initState();
    widget.controller.loadAccount().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _amountField.dispose();
    super.dispose();
  }

  void _go(_RepayStep s) => setState(() => _step = s);

  void _setAmount(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    final kobo = (int.tryParse(digits) ?? 0) * 100;
    setState(() {
      _partialKobo = kobo;
      _amountError = kobo > loan.outstandingKobo
          ? 'You can pay up to ${Naira.grouped(loan.outstandingKobo)}.'
          : null;
    });
  }

  Future<void> _authorize(String pin) async {
    final token = await widget.controller.authorizePin(pin);
    _go(_RepayStep.processing);
    final result = await widget.controller.repay(loan, _payKobo, token);
    if (!mounted) return;
    setState(() {
      _result = result;
      _step = _RepayStep.success;
    });
  }

  @override
  Widget build(BuildContext context) {
    final busy = _step == _RepayStep.processing;
    return PopScope(
      canPop: !busy,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.bottomCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(
            key: ValueKey(_step),
            child: switch (_step) {
              _RepayStep.choose => _choose(),
              _RepayStep.amount => _amount(),
              _RepayStep.review => _review(),
              _RepayStep.pin => FlexSheet(
                title: 'Confirm Payment',
                child: FlexPinEntry(
                  isDemo: widget.controller.isDemo,
                  onComplete: _authorize,
                ),
              ),
              _RepayStep.processing => _processing(),
              _RepayStep.success => _success(),
            },
          ),
        ),
      ),
    );
  }

  Widget _choose() => FlexSheet(
    title: 'Repay Your Loan',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'How much would you like to pay?',
          style: RexTypography.host(13, color: FlexColors.navy),
        ),
        const SizedBox(height: 14),
        FlexOptionCard(
          key: const Key('flex-repay-full'),
          unselectedColor: FlexColors.background,
          title: 'Full Repayment',
          subtitle:
              'Settle your loan of ${Naira.grouped(loan.outstandingKobo)}',
          selected: _full,
          onTap: () => setState(() => _full = true),
        ),
        const SizedBox(height: 10),
        FlexOptionCard(
          key: const Key('flex-repay-partial'),
          unselectedColor: FlexColors.background,
          title: 'Partial Repayment',
          subtitle: 'Pay a part of your outstanding balance',
          selected: !_full,
          onTap: () => setState(() => _full = false),
        ),
        const SizedBox(height: 24),
        FlexButton(
          key: const Key('flex-repay-continue'),
          label: 'Continue',
          onTap: () => _go(_full ? _RepayStep.review : _RepayStep.amount),
        ),
      ],
    ),
  );

  Widget _amount() {
    final valid = _partialKobo > 0 && _amountError == null;
    const chips = [500, 1000, 1500, 2000, 2500];
    return FlexSheet(
      title: 'Review Partial Repayment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Repayment Amount',
            style: RexTypography.host(
              12,
              weight: FontWeight.w600,
              color: RexColors.textStrong,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('flex-partial-amount'),
            controller: _amountField,
            keyboardType: TextInputType.number,
            onChanged: _setAmount,
            style: RexTypography.host(15, color: RexColors.textStrong),
            decoration: InputDecoration(
              hintText: 'Enter Amount',
              hintStyle: RexTypography.host(14, color: FlexColors.label),
              prefixText: '₦ ',
              filled: true,
              fillColor: FlexColors.panel,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < chips.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Pressable(
                    semanticLabel: '₦${chips[i]}',
                    onTap: chips[i] * 100 > loan.outstandingKobo
                        ? null
                        : () {
                            _amountField.text = '${chips[i]}';
                            _setAmount('${chips[i]}');
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _partialKobo == chips[i] * 100
                            ? FlexColors.navy
                            : FlexColors.panel,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Text(
                        '${chips[i]}',
                        style: RexTypography.host(
                          12,
                          weight: FontWeight.w500,
                          color: _partialKobo == chips[i] * 100
                              ? Colors.white
                              : FlexColors.label,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              text: 'Outstanding Balance:  ',
              children: [
                TextSpan(
                  text: Naira.grouped(loan.outstandingKobo),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            style: RexTypography.host(
              12,
              weight: FontWeight.w500,
              color: RexColors.textStrong,
            ),
          ),
          if (_amountError != null) ...[
            const SizedBox(height: 6),
            Text(
              _amountError!,
              style: RexTypography.host(
                12,
                weight: FontWeight.w500,
                color: RexColors.error,
              ),
            ),
          ],
          const SizedBox(height: 12),
          FlexNote(
            'You can pay any amount up to '
            '${Naira.groupedWhole(loan.outstandingKobo)}. Your due date '
            'remains ${RexDates.dayMonthYear(loan.dueDate!)}',
          ),
          const SizedBox(height: 22),
          FlexButton(
            key: const Key('flex-partial-continue'),
            label: 'Continue',
            onTap: valid
                ? () {
                    FocusScope.of(context).unfocus();
                    // Paying the whole balance here is a full repayment.
                    if (_partialKobo == loan.outstandingKobo) _full = true;
                    _go(_RepayStep.review);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _review() {
    final account = widget.controller.account;
    final left = loan.outstandingKobo - _payKobo;
    return FlexSheet(
      title: _full ? 'Review Repayment' : 'Review Partial Repayment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FlexDetailBox(
            title: 'Repayment Details',
            rows: _full
                ? [
                    ('Loan Amount', Naira.grouped(loan.principalKobo)),
                    (_interestLabel(), Naira.plain(loan.interestKobo)),
                    if (loan.repaidKobo > 0)
                      ('Already Repaid', Naira.grouped(loan.repaidKobo)),
                    ('Amount to pay', Naira.grouped(_payKobo)),
                  ]
                : [
                    ('Payment Amount', Naira.grouped(_payKobo)),
                    ('Outstanding Balance', Naira.grouped(left)),
                  ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: FlexColors.panel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Payment Method',
                  style: RexTypography.host(
                    13,
                    weight: FontWeight.w600,
                    color: RexColors.textStrong,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Colors.white),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RexMFB Account',
                            style: RexTypography.host(
                              11,
                              weight: FontWeight.w500,
                              color: FlexColors.label,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (account?.holderName ?? '').toUpperCase(),
                            style: RexTypography.host(
                              12,
                              weight: FontWeight.w600,
                              color: RexColors.textStrong,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Naira.grouped(RexFlexController.demoAccountBalanceKobo),
                      style: RexTypography.host(
                        12,
                        weight: FontWeight.w500,
                        color: RexColors.textStrong,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FlexNote(
            _full
                ? 'This payment will fully settle your loan and close it'
                : 'Your loan will remain active with a new outstanding '
                      'balance of ${Naira.grouped(left)}',
          ),
          const SizedBox(height: 22),
          FlexButton(
            key: const Key('flex-pay'),
            label: 'Pay ${Naira.grouped(_payKobo)}',
            onTap: () => _go(_RepayStep.pin),
          ),
        ],
      ),
    );
  }

  Widget _processing() => FlexSheet(
    showClose: false,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),
      child: Column(
        children: [
          const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: FlexColors.navy,
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            liveRegion: true,
            child: Text(
              'Processing Payment',
              style: RexTypography.host(
                17,
                weight: FontWeight.w700,
                color: RexColors.textStrong,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please wait while we confirm your payment',
            style: RexTypography.host(13, color: FlexColors.navy),
          ),
        ],
      ),
    ),
  );

  Widget _success() {
    final r = _result!;
    return FlexSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Appear(
            child: FlexSuccessHeader(
              title: r.settled
                  ? 'Repayment Successful!'
                  : 'Payment Successful!',
              subtitle: r.settled
                  ? 'Your loan has been fully repaid and is now settled.'
                  : 'Your payment was received. Your loan remains active.',
            ),
          ),
          const SizedBox(height: 18),
          FlexDetailBox(
            title: 'Loan Details',
            rows: r.settled
                ? [
                    ('Loan Amount', Naira.grouped(loan.principalKobo)),
                    ('Total Repaid', Naira.grouped(loan.totalKobo)),
                    (_interestLabel(), Naira.plain(loan.interestKobo)),
                    ('Reference', r.reference),
                  ]
                : [
                    ('Payment Amount', Naira.grouped(r.paidKobo)),
                    ('Outstanding Balance', Naira.grouped(r.outstandingKobo)),
                    ('Reference', r.reference),
                  ],
          ),
          const SizedBox(height: 20),
          FlexButton(
            key: const Key('flex-view-loan-details'),
            label: 'View Loan Details',
            onTap: () => Navigator.of(context).pop(r),
          ),
          const SizedBox(height: 10),
          FlexButton(
            key: const Key('flex-download-receipt'),
            label: 'Download Receipt',
            secondary: true,
            onTap: () => showFlexSheet<void>(
              context,
              (_) => FlexReceiptSheet(loan: loan, result: r),
            ),
          ),
          const FlexDemoLabel(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Well done, receipt and information sheets
// ---------------------------------------------------------------------------

enum WellDoneAction { journey, anotherLoan }

class WellDoneSheet extends StatelessWidget {
  const WellDoneSheet({super.key, required this.loan});
  final FlexLoan loan;

  @override
  Widget build(BuildContext context) => FlexSheet(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FlexSuccessHeader(
          title: 'Well done!',
          subtitle:
              "You've fully repaid your RexFlex loan of "
              '${Naira.grouped(loan.totalKobo)}',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            color: FlexColors.panel,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Build your credit',
                      style: RexTypography.host(
                        13,
                        weight: FontWeight.w600,
                        color: RexColors.textStrong,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep up your account activity and on-time repayments '
                      'to unlock higher amounts in future.',
                      style: RexTypography.host(
                        11,
                        weight: FontWeight.w500,
                        color: FlexColors.label,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const ExcludeSemantics(
                child: Image(
                  image: AssetImage(FlexAssets.cashTilt),
                  width: 70,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FlexButton(
          key: const Key('flex-see-journey'),
          label: 'See My Flex Journey',
          onTap: () => Navigator.of(context).pop(WellDoneAction.journey),
        ),
        const SizedBox(height: 10),
        FlexButton(
          key: const Key('flex-take-another'),
          label: 'Take Another Loan',
          secondary: true,
          onTap: () => Navigator.of(context).pop(WellDoneAction.anotherLoan),
        ),
      ],
    ),
  );
}

/// Simulated receipt. Clearly marked as demo data so it can't be mistaken
/// for proof of a real payment.
class FlexReceiptSheet extends StatelessWidget {
  const FlexReceiptSheet({super.key, required this.loan, required this.result});
  final FlexLoan loan;
  final RepaymentResult result;

  @override
  Widget build(BuildContext context) => FlexSheet(
    title: 'Payment Receipt',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: FlexColors.noteBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'DEMO RECEIPT · simulated payment, not a real transaction',
            textAlign: TextAlign.center,
            style: RexTypography.host(
              11,
              weight: FontWeight.w700,
              color: FlexColors.noteText,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FlexDetailBox(
          title: 'RexFlex Loan Repayment',
          rows: [
            ('Amount Paid', Naira.grouped(result.paidKobo)),
            ('Outstanding Balance', Naira.grouped(result.outstandingKobo)),
            ('Loan ID', loan.id),
            ('Reference', result.reference),
            ('Date', RexDates.dateTime(result.at)),
            ('Status', result.settled ? 'Loan settled' : 'Loan active'),
          ],
        ),
        const SizedBox(height: 16),
        FlexButton(label: 'Done', onTap: () => Navigator.of(context).pop()),
      ],
    ),
  );
}

/// Simple titled list of label/value rows or paragraphs.
class FlexInfoSheet extends StatelessWidget {
  const FlexInfoSheet({
    super.key,
    required this.title,
    this.rows = const [],
    this.paragraphs = const [],
  });
  final String title;
  final List<(String, String)> rows;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) => FlexSheet(
    title: title,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (rows.isNotEmpty) FlexDetailBox(title: 'Details', rows: rows),
        for (final p in paragraphs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6, right: 10),
                  child: Icon(Icons.circle, size: 6, color: FlexColors.navy),
                ),
                Expanded(
                  child: Text(
                    p,
                    style: RexTypography.host(13, color: RexColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        const FlexDemoLabel(
          text: 'Prototype copy · the real terms come from Rex Legal',
        ),
        const SizedBox(height: 12),
        FlexButton(label: 'Close', onTap: () => Navigator.of(context).pop()),
      ],
    ),
  );
}

const flexKeyTerms = [
  'Interest is 8% per 30 days, charged pro-rata for the tenor you choose.',
  'Repay in full or in parts any time before the due date from your Rex account.',
  'Each new loan needs a fresh eligibility and risk check.',
  'On-time repayment can raise your next offer, usually up to 2× your highest fully repaid loan.',
  'Your account data is used only to assess your credit eligibility.',
];
