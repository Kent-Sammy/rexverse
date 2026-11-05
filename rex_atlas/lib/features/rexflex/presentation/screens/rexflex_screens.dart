import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/demo_device_frame.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/formatting/naira.dart';
import '../../../../core/widgets/appear.dart';
import '../../../../core/widgets/pressable.dart';
import '../../application/rexflex_controller.dart';
import '../../domain/rexflex_models.dart';
import '../sheets/flex_sheets.dart';
import '../widgets/flex_ui.dart';

// ---------------------------------------------------------------------------
// Navigation helpers
// ---------------------------------------------------------------------------

/// Entry point from the home screen (RexFlex tile, Borrow tab). First-time
/// customers see the "Earn your flex" intro; returning ones the dashboard.
Future<void> openRexFlex(BuildContext context, RexFlexController c) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => c.hasHistory
            ? RexFlexDashboard(controller: c)
            : RexFlexOpener(controller: c),
      ),
    );

/// Resets the stack to Home → RexFlex dashboard (→ loan details).
void _showDashboard(
  BuildContext context,
  RexFlexController c, {
  FlexLoan? loan,
}) {
  final nav = Navigator.of(context);
  nav.popUntil((r) => r.isFirst);
  nav.push(
    MaterialPageRoute<void>(builder: (_) => RexFlexDashboard(controller: c)),
  );
  if (loan != null) {
    nav.push(
      MaterialPageRoute<void>(
        builder: (_) => LoanDetailsScreen(controller: c, loan: loan),
      ),
    );
  }
}

void _push(BuildContext context, Widget screen) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

/// Starts a new loan from wherever the customer is: pops up "Check Your
/// Eligibility" over the current screen, then continues to the repayment
/// term. Used by "Get Started" and "Take Another Loan".
Future<void> startNewLoan(BuildContext context, RexFlexController c) async {
  final offer = await showFlexSheet<int>(
    context,
    (_) => EligibilitySheet(controller: c),
  );
  if (offer == null || !context.mounted) return;
  _push(context, RepaymentTermScreen(controller: c, offerKobo: offer));
}

int _daysLeft(DateTime now, DateTime due) {
  final d = DateTime(
    due.year,
    due.month,
    due.day,
  ).difference(DateTime(now.year, now.month, now.day)).inDays;
  return math.max(0, d);
}

// ---------------------------------------------------------------------------
// 1. "Earn your flex" intro
// ---------------------------------------------------------------------------

class RexFlexOpener extends StatelessWidget {
  const RexFlexOpener({super.key, required this.controller});
  final RexFlexController controller;

  Future<void> _getStarted(BuildContext context) =>
      startNewLoan(context, controller);

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    const benefits = [
      (
        Icons.payments_rounded,
        Color(0xFFE3EEFF),
        Color(0xFF3D7BF7),
        'Start small',
        'Borrow from ₦3,000',
      ),
      (
        Icons.currency_exchange_rounded,
        Color(0xFFE1F8E6),
        Color(0xFF22A447),
        'Repay on time',
        'Build your credit profile',
      ),
      (
        Icons.lock_open_rounded,
        Color(0xFFFBE4FA),
        Color(0xFFD13BCB),
        'Unlock higher amount',
        'Access up to ₦100,000 overtime',
      ),
    ];
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.4, 1],
                colors: [
                  Color(0xFFB4DBFF),
                  Color(0xFFD3E9FF),
                  Color(0xFFEFF6FF),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(height: math.max(pad.top, 20) + 26),
                    const ExcludeSemantics(
                      child: Appear(
                        offset: 20,
                        fromScale: 0.96,
                        child: Image(
                          image: AssetImage(FlexAssets.hero),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Semantics(
                      header: true,
                      child: Text(
                        'Earn your flex',
                        textAlign: TextAlign.center,
                        style: RexTypography.host(
                          22,
                          weight: FontWeight.w700,
                          color: const Color(0xFF0B1B3F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Get a short-term loan, start small and grow your credit',
                        textAlign: TextAlign.center,
                        style: RexTypography.host(
                          14,
                          color: const Color(0xFF2B4A80),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    for (var i = 0; i < benefits.length; i++)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Appear(
                          delay: Duration(milliseconds: 150 + 90 * i),
                          offset: 12,
                          child: FlexCard(
                            child: Row(
                              children: [
                                FlexIconBubble(
                                  icon: benefits[i].$1,
                                  bg: benefits[i].$2,
                                  fg: benefits[i].$3,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        benefits[i].$4,
                                        style: RexTypography.host(
                                          14,
                                          weight: FontWeight.w600,
                                          color: RexColors.textStrong,
                                        ),
                                      ),
                                      Text(
                                        benefits[i].$5,
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
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  math.max(16, pad.bottom + 8),
                ),
                child: FlexButton(
                  key: const Key('flex-get-started'),
                  label: 'Get Started',
                  onTap: () => _getStarted(context),
                ),
              ),
            ],
          ),
          Positioned(
            left: 12,
            top: math.max(pad.top, 20) + 2,
            child: Pressable(
              key: const Key('flex-back'),
              semanticLabel: 'Back',
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 22,
                  color: RexColors.textStrong,
                ),
              ),
            ),
          ),
          if (DemoDeviceFrame.showsStatusBar(context))
            const Positioned(left: 0, right: 0, top: 0, child: DemoStatusBar()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Choose a Repayment Term
// ---------------------------------------------------------------------------

class RepaymentTermScreen extends StatefulWidget {
  const RepaymentTermScreen({
    super.key,
    required this.controller,
    required this.offerKobo,
  });
  final RexFlexController controller;
  final int offerKobo;

  @override
  State<RepaymentTermScreen> createState() => _RepaymentTermScreenState();
}

class _RepaymentTermScreenState extends State<RepaymentTermScreen> {
  late final _terms = widget.controller.offersFor(widget.offerKobo);
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return FlexScaffold(
      title: 'Choose a Repayment Term',
      subtitle: 'Select one and get started quickly',
      children: [
        FlexBalanceCard(
          label: 'Available loan amount',
          amountKobo: widget.offerKobo,
          caption: 'Choose a repayment term that works for you',
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < _terms.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FlexOptionCard(
              key: Key('flex-term-${_terms[i].days}'),
              title:
                  '${Naira.grouped(_terms[i].principalKobo)}  for ${_terms[i].days} days',
              subtitle: 'Repay ${Naira.grouped(_terms[i].totalKobo)}',
              detail:
                  '(${Naira.groupedWhole(_terms[i].principalKobo)} + '
                  '${Naira.groupedWhole(_terms[i].interestKobo)} interest)',
              selected: _selected == i,
              onTap: () => setState(() => _selected = i),
            ),
          ),
        const SizedBox(height: 30),
        FlexButton(
          key: const Key('flex-term-continue'),
          label: 'Continue',
          onTap: () => _push(
            context,
            ReviewOfferScreen(
              controller: widget.controller,
              term: _terms[_selected],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Review Your Offer
// ---------------------------------------------------------------------------

class ReviewOfferScreen extends StatefulWidget {
  const ReviewOfferScreen({
    super.key,
    required this.controller,
    required this.term,
  });
  final RexFlexController controller;
  final LoanTerm term;

  @override
  State<ReviewOfferScreen> createState() => _ReviewOfferScreenState();
}

class _ReviewOfferScreenState extends State<ReviewOfferScreen> {
  bool _accepted = false;

  Future<void> _confirm() async {
    final c = widget.controller;
    final loan = c.apply(widget.term);
    final viewLoan = await showFlexSheet<bool>(
      context,
      (_) => ApplicationSheet(controller: c, loan: loan),
    );
    if (!mounted) return;
    // Approved → straight to the loan; closed early → the dashboard, where
    // the application shows as Pending until the review finishes.
    _showDashboard(context, c, loan: viewLoan == true ? loan : null);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.term;
    final start = widget.controller.now;
    final due = start.add(Duration(days: t.days));
    Widget cell(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: RexTypography.host(
              12,
              weight: FontWeight.w500,
              color: FlexColors.label,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: RexTypography.host(
              13,
              weight: FontWeight.w500,
              color: RexColors.textStrong,
            ),
          ),
        ],
      ),
    );
    Widget row(Widget a, Widget b) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [a, b]),
    );
    return FlexScaffold(
      title: 'Review Your Offer',
      subtitle: 'A quick breakdown of your loan offer',
      children: [
        FlexCard(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
          child: Column(
            children: [
              row(
                cell('Loan Amount', Naira.groupedWhole(t.principalKobo)),
                cell('Tenor', '${t.days} days'),
              ),
              const Divider(height: 1, color: RexColors.divider),
              row(
                cell(
                  'Interest (${RexFlexPricing.ratePer30DaysPct}%)',
                  Naira.groupedWhole(t.interestKobo),
                ),
                cell('Start Date', RexDates.dayMonthYear(start)),
              ),
              const Divider(height: 1, color: RexColors.divider),
              row(
                cell('Due Date', RexDates.dayMonthYear(due)),
                cell('Total to Repay', Naira.groupedWhole(t.totalKobo)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Pressable(
          key: const Key('flex-key-terms'),
          semanticLabel: 'Key terms',
          onTap: () => showFlexSheet<void>(
            context,
            (_) => const FlexInfoSheet(
              title: 'Key Terms',
              paragraphs: flexKeyTerms,
            ),
          ),
          child: FlexCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Key terms',
                    style: RexTypography.host(
                      13,
                      weight: FontWeight.w500,
                      color: RexColors.textStrong,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: RexColors.textStrong,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Semantics(
          checked: _accepted,
          child: Pressable(
            key: const Key('flex-consent'),
            semanticLabel:
                'I have read and accept the RexFlex Terms, Credit Policy and '
                'Consent to use my data for credit assessment.',
            onTap: () => setState(() => _accepted = !_accepted),
            child: FlexCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: _accepted
                          ? FlexColors.navy
                          : const Color(0xFFD4E1FF),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: _accepted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'I have read and accept the RexFlex Terms, Credit Policy '
                      'and Consent to use my data for credit assessment.',
                      style: RexTypography.host(
                        12,
                        weight: FontWeight.w500,
                        color: RexColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        FlexButton(
          key: const Key('flex-confirm-application'),
          label: 'Confirm Application',
          onTap: _accepted ? _confirm : null,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 4. RexFlex dashboard
// ---------------------------------------------------------------------------

class RexFlexDashboard extends StatefulWidget {
  const RexFlexDashboard({super.key, required this.controller});
  final RexFlexController controller;

  @override
  State<RexFlexDashboard> createState() => _RexFlexDashboardState();
}

class _RexFlexDashboardState extends State<RexFlexDashboard> {
  int _tab = 0;

  void _open(FlexLoan loan) {
    final c = widget.controller;
    if (loan.status == LoanStatus.pending) {
      showFlexSheet<bool>(
        context,
        (_) => ApplicationSheet(controller: c, loan: loan),
      ).then((view) {
        if (view == true && mounted) {
          _push(context, LoanDetailsScreen(controller: c, loan: loan));
        }
      });
    } else {
      _push(context, LoanDetailsScreen(controller: c, loan: loan));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final current = c.currentLoan;
        final loans = c.loans
            .where(
              (l) => switch (_tab) {
                1 => l.status != LoanStatus.settled,
                2 => l.status == LoanStatus.settled,
                _ => true,
              },
            )
            .toList();
        return FlexScaffold(
          title: 'RexFlex',
          subtitle: 'Get a short-term loan, start small and grow your credit',
          bottom: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (current == null) ...[
                FlexButton(
                  key: const Key('flex-dashboard-new-loan'),
                  label: 'Take Another Loan',
                  secondary: true,
                  onTap: () => startNewLoan(context, c),
                ),
                const SizedBox(height: 10),
              ],
              FlexButton(
                key: const Key('flex-dashboard-journey'),
                label: 'View My Flex Journey',
                onTap: () => _push(context, FlexJourneyScreen(controller: c)),
              ),
            ],
          ),
          children: [
            FlexBalanceCard(
              label: 'Outstanding Loan Amount',
              amountKobo: c.outstandingKobo,
              caption: switch (current?.status) {
                null => 'No loans at the moment',
                LoanStatus.pending => 'Application under review',
                _ => 'Due ${RexDates.dayMonthYear(current!.dueDate!)}',
              },
            ),
            const SizedBox(height: 12),
            FlexTabs(
              tabs: const ['All', 'Pending', 'Settled'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 12),
            if (loans.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  'No loans here yet',
                  textAlign: TextAlign.center,
                  style: RexTypography.host(13, color: FlexColors.label),
                ),
              ),
            for (final loan in loans)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LoanRow(loan: loan, onTap: () => _open(loan)),
              ),
          ],
        );
      },
    );
  }
}

class _LoanRow extends StatelessWidget {
  const _LoanRow({required this.loan, required this.onTap});
  final FlexLoan loan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (line1, line2) = switch (loan.status) {
      LoanStatus.pending => (
        'Proposed Due Date: ${RexDates.dayMonthYear(loan.proposedDueDate)}',
        'Proposed Total Repayment: ${Naira.grouped(loan.totalKobo)}',
      ),
      LoanStatus.active => (
        'Due Date: ${RexDates.dayMonthYear(loan.dueDate!)}',
        'Outstanding: ${Naira.grouped(loan.outstandingKobo)}',
      ),
      LoanStatus.settled => (
        'Settled: ${RexDates.dayMonthYear(loan.settledAt!)}',
        'Total Repayment: ${Naira.grouped(loan.totalKobo)}',
      ),
    };
    return Pressable(
      key: Key('flex-loan-${loan.id}'),
      semanticLabel:
          'RexFlex Loan ${Naira.grouped(loan.principalKobo)}, '
          '${loan.status.name}',
      onTap: onTap,
      child: FlexCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FlexIconBubble(
              icon: Icons.work_rounded,
              bg: FlexColors.purpleBg,
              fg: FlexColors.purple,
              size: 34,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RexFlex Loan',
                    style: RexTypography.host(
                      13,
                      weight: FontWeight.w600,
                      color: RexColors.textStrong,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    line1,
                    style: RexTypography.host(
                      10,
                      weight: FontWeight.w500,
                      color: FlexColors.label,
                    ),
                  ),
                  Text(
                    line2,
                    style: RexTypography.host(
                      10,
                      weight: FontWeight.w500,
                      color: FlexColors.label,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Naira.grouped(loan.principalKobo),
                  style: RexTypography.host(
                    13,
                    weight: FontWeight.w600,
                    color: RexColors.textStrong,
                  ),
                ),
                const SizedBox(height: 10),
                FlexPill.forStatus(loan.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. RexFlex Loan details
// ---------------------------------------------------------------------------

class LoanDetailsScreen extends StatefulWidget {
  const LoanDetailsScreen({
    super.key,
    required this.controller,
    required this.loan,
  });
  final RexFlexController controller;
  final FlexLoan loan;

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  RexFlexController get c => widget.controller;
  FlexLoan get loan => widget.loan;

  Future<void> _repay() async {
    final wasSettled = loan.status == LoanStatus.settled;
    await showFlexSheet<RepaymentResult>(
      context,
      (_) => RepaymentSheet(controller: c, loan: loan),
    );
    if (!mounted || wasSettled || loan.status != LoanStatus.settled) return;
    final action = await showFlexSheet<WellDoneAction>(
      context,
      (_) => WellDoneSheet(loan: loan),
    );
    if (!mounted) return;
    switch (action) {
      case WellDoneAction.journey:
        _push(context, FlexJourneyScreen(controller: c));
      case WellDoneAction.anotherLoan:
        startNewLoan(context, c);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final settled = loan.status == LoanStatus.settled;
        final due = loan.dueDate ?? loan.proposedDueDate;
        final pct = (loan.progress * 100).round();
        return FlexScaffold(
          title: 'RexFlex Loan',
          centeredTitle: true,
          children: [
            FlexBalanceCard(
              label: 'Outstanding Balance',
              amountKobo: loan.outstandingKobo,
              caption:
                  'Original loan Amount : ${Naira.grouped(loan.totalKobo)}',
            ),
            const SizedBox(height: 10),
            FlexCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        _Stat(
                          icon: Icons.account_balance_wallet_rounded,
                          bg: const Color(0xFFFFF4D6),
                          fg: const Color(0xFFE0A100),
                          label: 'Amount Repaid',
                          value: Naira.grouped(loan.repaidKobo),
                        ),
                        const VerticalDivider(
                          width: 20,
                          color: RexColors.divider,
                        ),
                        _Stat(
                          icon: Icons.account_balance_wallet_rounded,
                          bg: const Color(0xFFDDF7E3),
                          fg: const Color(0xFF22A447),
                          label: 'Total Repayment',
                          value: Naira.grouped(loan.totalKobo),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: RexColors.divider),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Repayment Progress',
                          style: RexTypography.host(
                            13,
                            weight: FontWeight.w500,
                            color: RexColors.textStrong,
                          ),
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: RexTypography.host(
                          11,
                          weight: FontWeight.w500,
                          color: FlexColors.label,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Repayment progress $pct percent',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: math.max(0.04, loan.progress)),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, _) => LinearProgressIndicator(
                          value: v,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE6EEFF),
                          color: const Color(0xFF1E5BE6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          settled
                              ? 'Settled ${RexDates.dayMonthYear(loan.settledAt!)}'
                              : '${_daysLeft(c.now, due)} days remaining',
                          style: RexTypography.host(
                            11,
                            weight: FontWeight.w500,
                            color: FlexColors.label,
                          ),
                        ),
                      ),
                      Text(
                        'Due ${RexDates.dayMonthYear(due)}',
                        style: RexTypography.host(
                          11,
                          weight: FontWeight.w500,
                          color: FlexColors.label,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (settled) ...[
              FlexCard(
                color: FlexColors.settledBg,
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: FlexColors.green,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loan Settled',
                            style: RexTypography.host(
                              13,
                              weight: FontWeight.w600,
                              color: RexColors.textStrong,
                            ),
                          ),
                          Text(
                            'Your loan was fully repaid on '
                            '${RexDates.dayMonthYear(loan.settledAt!)}',
                            style: RexTypography.host(
                              11,
                              weight: FontWeight.w500,
                              color: const Color(0xFF2F5236),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FlexButton(
                key: const Key('flex-loan-journey'),
                label: 'View My Flex Journey',
                onTap: () => _push(context, FlexJourneyScreen(controller: c)),
              ),
            ] else
              FlexButton(
                key: const Key('flex-repay-loan'),
                label: 'Repay Loan',
                onTap: loan.status == LoanStatus.active ? _repay : null,
              ),
            FlexSectionHeader(
              'Transactions',
              onSeeAll: () => _push(
                context,
                TransactionHistoryScreen(controller: c, loan: loan),
              ),
            ),
            for (final t in loan.transactions.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FlexTxnTile(t),
              ),
            if (loan.transactions.isEmpty)
              Text(
                'Your disbursement will appear here once approved.',
                style: RexTypography.host(
                  12,
                  weight: FontWeight.w500,
                  color: FlexColors.label,
                ),
              ),
            const FlexSectionHeader('Support & Information'),
            FlexMenuRow(
              icon: Icons.work_rounded,
              bg: FlexColors.purpleBg,
              fg: FlexColors.purple,
              title: 'Loan Information',
              subtitle: 'Reference, amount, rate, and dates',
              onTap: () => showFlexSheet<void>(
                context,
                (_) => FlexInfoSheet(
                  title: 'Loan Information',
                  rows: [
                    ('Reference', loan.id),
                    ('Loan Amount', Naira.grouped(loan.principalKobo)),
                    (
                      'Interest Rate',
                      '${RexFlexPricing.ratePer30DaysPct}% per 30 days',
                    ),
                    ('Interest', Naira.grouped(loan.interestKobo)),
                    ('Tenor', '${loan.term.days} days'),
                    if (loan.startDate != null)
                      ('Start Date', RexDates.dayMonthYear(loan.startDate!)),
                    ('Due Date', RexDates.dayMonthYear(due)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            FlexMenuRow(
              icon: Icons.description_rounded,
              bg: const Color(0xFFE3EEFF),
              fg: const Color(0xFF3D7BF7),
              title: 'Loan Agreement',
              subtitle: 'View the terms you accepted',
              onTap: () => showFlexSheet<void>(
                context,
                (_) => const FlexInfoSheet(
                  title: 'Loan Agreement',
                  paragraphs: flexKeyTerms,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FlexMenuRow(
              icon: Icons.headset_mic_rounded,
              bg: const Color(0xFFE1F8E6),
              fg: const Color(0xFF22A447),
              title: 'Get Help',
              subtitle: 'Support, disputes and general enquiries',
              onTap: () => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Support is part of the main Rex app, not this prototype.',
                    ),
                  ),
                ),
            ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color bg;
  final Color fg;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: fg),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: RexTypography.host(
                  10,
                  weight: FontWeight.w500,
                  color: FlexColors.label,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: RexTypography.host(
                    14,
                    weight: FontWeight.w600,
                    color: RexColors.textStrong,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// 6. Transaction History
// ---------------------------------------------------------------------------

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({
    super.key,
    required this.controller,
    required this.loan,
  });
  final RexFlexController controller;
  final FlexLoan loan;

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final loan = widget.loan;
    final txns = loan.transactions
        .where(
          (t) => switch (_tab) {
            1 => !t.isCredit,
            2 => t.isCredit,
            _ => true,
          },
        )
        .toList();
    return FlexScaffold(
      title: 'Transaction History',
      centeredTitle: true,
      children: [
        FlexTabs(
          tabs: const ['All', 'Repayments', 'Disbursement'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 12),
        if (loan.status == LoanStatus.settled) ...[
          FlexCard(
            color: FlexColors.settledBg,
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: FlexColors.green,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This loan is now settled',
                        style: RexTypography.host(
                          13,
                          weight: FontWeight.w600,
                          color: RexColors.textStrong,
                        ),
                      ),
                      Text(
                        'All payments have been received and your loan is closed',
                        style: RexTypography.host(
                          11,
                          weight: FontWeight.w500,
                          color: const Color(0xFF2F5236),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (txns.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Text(
              'No transactions yet',
              textAlign: TextAlign.center,
              style: RexTypography.host(13, color: FlexColors.label),
            ),
          ),
        for (final t in txns)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FlexTxnTile(t),
          ),
        const FlexDemoLabel(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 7. Your Flex Journey + How Progression Works
// ---------------------------------------------------------------------------

class FlexJourneyScreen extends StatelessWidget {
  const FlexJourneyScreen({super.key, required this.controller});
  final RexFlexController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final tier = c.tierIndex;
    final repaid = c.highestRepaidKobo;
    return FlexScaffold(
      title: 'Your Flex Journey',
      centeredTitle: true,
      children: [
        Appear(offset: 12, child: _JourneyHero(tier: tier)),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Semantics(
            header: true,
            child: Text(
              'Your levels',
              style: RexTypography.host(
                15,
                weight: FontWeight.w600,
                color: RexColors.textStrong,
              ),
            ),
          ),
        ),
        for (var i = 0; i < flexTiers.length; i++)
          Appear(
            delay: Duration(milliseconds: 120 + 90 * i),
            offset: 12,
            child: _TierStep(
              tier: flexTiers[i],
              index: i,
              state: i < tier
                  ? _TierState.done
                  : i == tier
                  ? _TierState.current
                  : _TierState.locked,
              repaidKobo: repaid,
              first: i == 0,
              last: i == flexTiers.length - 1,
            ),
          ),
        const SizedBox(height: 14),
        Appear(
          delay: const Duration(milliseconds: 420),
          offset: 12,
          child: FlexMenuRow(
            key: const Key('flex-how-progression'),
            icon: Icons.info_outline_rounded,
            bg: const Color(0xFFFFF1DC),
            fg: const Color(0xFFB86E00),
            title: 'How progression works',
            subtitle: 'What helps you grow and how offers are assessed',
            onTap: () => _push(context, const ProgressionScreen()),
          ),
        ),
      ],
    );
  }
}

const _levelIcons = [
  Icons.spa_rounded,
  Icons.trending_up_rounded,
  Icons.workspace_premium_rounded,
];
const _levelColors = [
  (Color(0xFFE6EEFF), Color(0xFF2F6BEA)),
  (Color(0xFFE2F7E8), Color(0xFF1E8E45)),
  (Color(0xFFF0E8FF), Color(0xFF7A2BD6)),
];
const _levelShort = ['Build', 'Grow', 'Max'];

/// Navy → blue banner with the current level and a 3-step progress track.
class _JourneyHero extends StatelessWidget {
  const _JourneyHero({required this.tier});
  final int tier;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [RexColors.userGradientStart, RexColors.userGradientEnd],
          ),
        ),
        child: Stack(
          children: [
            // Soft decorative glows.
            Positioned(
              right: -40,
              top: -50,
              child: _Glow(size: 170, alpha: 0.16),
            ),
            Positioned(
              left: -30,
              bottom: -70,
              child: _Glow(size: 140, alpha: 0.10),
            ),
            Positioned(
              right: 10,
              top: 14,
              child: Transform.rotate(
                angle: -0.35,
                child: const ExcludeSemantics(
                  child: Image(image: AssetImage(FlexAssets.cash), width: 82),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Text(
                      'LEVEL ${tier + 1} OF ${flexTiers.length}',
                      style: RexTypography.host(
                        10,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ).copyWith(letterSpacing: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(right: 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your credit journey on RexFlex',
                          style: RexTypography.host(
                            17,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Repay on time, build a strong record and unlock '
                          'higher amounts',
                          style: RexTypography.host(
                            12,
                            weight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Semantics(
                    label:
                        'Level ${tier + 1} of ${flexTiers.length}: '
                        '${flexTiers[tier].name}',
                    child: ExcludeSemantics(
                      child: Row(
                        children: [
                          for (var i = 0; i < flexTiers.length; i++) ...[
                            if (i > 0) const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(end: i <= tier ? 1 : 0),
                                    duration: Duration(
                                      milliseconds: 500 + 200 * i,
                                    ),
                                    curve: Curves.easeOutCubic,
                                    builder: (_, v, _) => ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: v,
                                        minHeight: 5,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.22),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _levelShort[i],
                                    style: RexTypography.host(
                                      11,
                                      weight: i == tier
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.alpha});
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: alpha),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
    ),
  );
}

enum _TierState { done, current, locked }

/// One level on the timeline: a node centred on a continuous rail, and a
/// white card with the level's icon, range and status.
class _TierStep extends StatelessWidget {
  const _TierStep({
    required this.tier,
    required this.index,
    required this.state,
    required this.repaidKobo,
    required this.first,
    required this.last,
  });
  final FlexTier tier;
  final int index;
  final _TierState state;
  final int repaidKobo;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    const railDone = Color(0xFF3D6FE8);
    const railTodo = Color(0xFFD5E1F7);
    final (tint, accent) = _levelColors[index];
    final locked = state == _TierState.locked;
    final current = state == _TierState.current;
    final status = switch (state) {
      _TierState.done =>
        repaidKobo > 0
            ? 'Completed · ${Naira.groupedWhole(repaidKobo)} repaid'
            : 'Completed',
      _TierState.current =>
        index == 0 && repaidKobo == 0
            ? 'Repay your first loan on time to grow'
            : 'You are here',
      _TierState.locked => tier.unlock,
    };
    final range =
        '${Naira.groupedWhole(tier.minKobo)} – ${Naira.groupedWhole(tier.maxKobo)}';

    return Semantics(
      label:
          '${tier.name}, $range, '
          '${switch (state) {
            _TierState.done => 'completed',
            _TierState.current => 'current level',
            _TierState.locked => 'locked',
          }}. $status',
      child: ExcludeSemantics(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 34,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 2,
                        color: first
                            ? Colors.transparent
                            : (state == _TierState.locked
                                  ? railTodo
                                  : railDone),
                      ),
                    ),
                    _Node(state: state),
                    Expanded(
                      child: Container(
                        width: 2,
                        color: last
                            ? Colors.transparent
                            : (state == _TierState.done ? railDone : railTodo),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: current ? const Color(0xFF9DB8F2) : Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: current
                          ? const [
                              BoxShadow(
                                color: Color(0x1F1E4FD8),
                                blurRadius: 18,
                                offset: Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: locked ? const Color(0xFFF0F2F7) : tint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            locked ? Icons.lock_rounded : _levelIcons[index],
                            size: 21,
                            color: locked ? const Color(0xFF8A94A8) : accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      tier.name,
                                      style: RexTypography.host(
                                        12,
                                        weight: FontWeight.w600,
                                        color: FlexColors.label,
                                      ),
                                    ),
                                  ),
                                  if (state != _TierState.locked)
                                    FlexPill(
                                      current ? 'Current' : 'Done',
                                      fg: current
                                          ? FlexColors.navy
                                          : FlexColors.green,
                                      bg: current
                                          ? FlexColors.secondaryBg
                                          : FlexColors.greenBg,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                range,
                                style: RexTypography.host(
                                  16,
                                  weight: FontWeight.w700,
                                  color: locked
                                      ? const Color(0xFF4A5468)
                                      : RexColors.textStrong,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                status,
                                style: RexTypography.host(
                                  11,
                                  weight: FontWeight.w500,
                                  color: state == _TierState.done
                                      ? FlexColors.green
                                      : FlexColors.label,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

/// Timeline node: filled check (done), pulsing ring (current), lock (locked).
class _Node extends StatefulWidget {
  const _Node({required this.state});
  final _TierState state;

  @override
  State<_Node> createState() => _NodeState();
}

class _NodeState extends State<_Node> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.state == _TierState.current && !reduce) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF3D6FE8);
    return switch (widget.state) {
      _TierState.done => Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5B8CFF), Color(0xFF1E4FD8)],
          ),
        ),
        child: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
      ),
      _TierState.current => SizedBox(
        width: 34,
        height: 34,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, _) {
            final t = _pulse.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 22 + 12 * t,
                  height: 22 + 12 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: blue.withValues(alpha: 0.28 * (1 - t)),
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: blue, width: 2.5),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: blue,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      _TierState.locked => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD5E1F7), width: 2),
        ),
      ),
    };
  }
}

class ProgressionScreen extends StatelessWidget {
  const ProgressionScreen({super.key});

  static const rules = [
    'Higher amounts are earned by successfully repaying loans on time.',
    'Each new loan requires a fresh eligibility and risk assessment.',
    'Increases are ordinarily capped at 2× your highest fully repaid principal.',
    'Flex Points and milestones do not automatically grant credit.',
  ];

  @override
  Widget build(BuildContext context) => FlexScaffold(
    title: 'How Progression Works',
    centeredTitle: true,
    children: [
      Text(
        'Understand what helps you grow and how your next offer is assessed.',
        style: RexTypography.host(13, color: FlexColors.label),
      ),
      const SizedBox(height: 14),
      for (var i = 0; i < rules.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Appear(
            delay: Duration(milliseconds: 60 * i),
            offset: 10,
            child: FlexCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const FlexIconBubble(
                    icon: Icons.insert_chart_rounded,
                    bg: Color(0xFFDDEBFF),
                    fg: Color(0xFF3D7BF7),
                    size: 40,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      rules[i],
                      style: RexTypography.host(
                        13,
                        color: RexColors.textStrong,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}
