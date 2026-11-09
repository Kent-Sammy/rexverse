import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/widgets/pressable.dart';
import '../domain/account_transaction.dart';

/// One choice from "Quick Filter" or "Bill Payments" (a single selection).
enum QuickFilter {
  all('All'),
  topUp('Top Up'),
  transfer('Transfer'),
  cardDebit('Card Debit'),
  virtualCard('Virtual Card Debit'),
  physicalCard('Physical Card Debit'),
  airtime('Airtime Top Up'),
  data('Data Top Up'),
  cables('Cables'),
  utility('Utility'),
  education('Education');

  const QuickFilter(this.label);
  final String label;

  static const quick = [
    all,
    topUp,
    transfer,
    cardDebit,
    virtualCard,
    physicalCard,
  ];
  static const bills = [airtime, data, cables, utility, education];

  bool matches(AccountTransaction t) => switch (this) {
    all => true,
    topUp => t.kind == TxnKind.transfer && t.isCredit,
    transfer => t.kind == TxnKind.transfer,
    cardDebit => t.kind == TxnKind.card && !t.isCredit,
    virtualCard => t.card == CardType.virtual && !t.isCredit,
    physicalCard => t.card == CardType.physical && !t.isCredit,
    airtime => t.kind == TxnKind.airtime,
    data => t.kind == TxnKind.data,
    cables => t.bill == BillType.cable,
    utility => t.bill == BillType.utility,
    education => t.bill == BillType.education,
  };
}

/// The "Transaction filter" choices: dates, type and amount range.
class TxnFilter {
  const TxnFilter({
    this.from,
    this.to,
    this.quick = QuickFilter.all,
    this.minNaira = 0,
    this.maxNaira = maxAmount,
  });

  /// Top of the amount slider; at this value there is no upper limit.
  static const maxAmount = 1000000.0;

  final DateTime? from;
  final DateTime? to;
  final QuickFilter quick;
  final double minNaira;
  final double maxNaira;

  bool get hasDates => from != null || to != null;
  bool get hasAmount => minNaira > 0 || maxNaira < maxAmount;
  bool get isActive => hasDates || quick != QuickFilter.all || hasAmount;

  bool matches(AccountTransaction t) {
    if (from != null && t.at.isBefore(_day(from!))) return false;
    if (to != null && !t.at.isBefore(_day(to!).add(const Duration(days: 1)))) {
      return false;
    }
    if (!quick.matches(t)) return false;
    final naira = t.amountKobo / 100;
    if (naira < minNaira) return false;
    if (maxNaira < maxAmount && naira > maxNaira) return false;
    return true;
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// "₦40k - ₦450k" (₦1M at the top means "and above").
  String get amountLabel =>
      '${compact(minNaira)} - ${compact(maxNaira)}'
      '${maxNaira >= maxAmount ? '+' : ''}';

  String get dateLabel {
    if (from != null && to != null) return '${short(from!)} – ${short(to!)}';
    if (from != null) return 'From ${short(from!)}';
    return 'Until ${short(to!)}';
  }

  static String compact(double naira) {
    if (naira >= 1000000) {
      final m = naira / 1000000;
      return '₦${m == m.roundToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}M';
    }
    if (naira >= 1000) return '₦${(naira / 1000).round()}k';
    return '₦${naira.round()}';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String short(DateTime d) => '${_months[d.month - 1]} ${d.day}';

  TxnFilter copyWith({
    DateTime? from,
    DateTime? to,
    QuickFilter? quick,
    double? minNaira,
    double? maxNaira,
    bool clearDates = false,
  }) => TxnFilter(
    from: clearDates ? null : from ?? this.from,
    to: clearDates ? null : to ?? this.to,
    quick: quick ?? this.quick,
    minNaira: minNaira ?? this.minNaira,
    maxNaira: maxNaira ?? this.maxNaira,
  );
}

/// Bottom sheet from the "Transaction filter" design.
class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({super.key, required this.initial, this.now});
  final TxnFilter initial;
  final DateTime? now;

  static Future<TxnFilter?> show(
    BuildContext context, {
    required TxnFilter initial,
    DateTime? now,
  }) => showModalBottomSheet<TxnFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => TransactionFilterSheet(initial: initial, now: now),
  );

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late TxnFilter _f = widget.initial;

  static const _chipBg = Color(0xFFEAF1FF);
  static const _selected = Color(0xFF00308F);
  static const _thumb = Color(0xFFC98A5E);

  Future<void> _pickDate({required bool start}) async {
    final now = widget.now ?? DateTime.now();
    final current = start ? _f.from : _f.to;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: start
          ? DateTime(now.year - 3)
          : (_f.from ?? DateTime(now.year - 3)),
      lastDate: start ? (_f.to ?? now) : now,
      helpText: start ? 'Start date' : 'End date',
    );
    if (picked == null) return;
    setState(
      () => _f = start ? _f.copyWith(from: picked) : _f.copyWith(to: picked),
    );
  }

  Widget _section(String title, Widget child) => Padding(
    padding: const EdgeInsets.only(top: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RexTypography.host(15, weight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );

  Widget _chip(QuickFilter q) {
    final on = _f.quick == q;
    return Pressable(
      key: Key('txns-quick-${q.name}'),
      semanticLabel: '${q.label}${on ? ', selected' : ''}',
      onTap: () => setState(() => _f = _f.copyWith(quick: q)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        constraints: const BoxConstraints(minWidth: 64),
        decoration: BoxDecoration(
          color: on ? _selected : _chipBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          q.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: RexTypography.host(
            13,
            weight: on ? FontWeight.w600 : FontWeight.w500,
            color: on ? Colors.white : RexColors.textStrong,
          ),
        ),
      ),
    );
  }

  Widget _dateField({required bool start}) {
    final value = start ? _f.from : _f.to;
    final label = start ? 'Start date' : 'End date';
    return Expanded(
      child: Pressable(
        key: Key(start ? 'txns-start-date' : 'txns-end-date'),
        semanticLabel: value == null
            ? label
            : '$label, ${TxnFilter.short(value)} ${value.year}',
        onTap: () => _pickDate(start: start),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _chipBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value == null
                      ? label
                      : '${TxnFilter.short(value)}, ${value.year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RexTypography.host(
                    14,
                    color: value == null
                        ? RexColors.textTxMeta
                        : RexColors.textStrong,
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: RexColors.textTxMeta,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tick(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _chipBg,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: RexTypography.host(
        11,
        weight: FontWeight.w500,
        color: const Color(0xFF4A5878),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 16 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction filter',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RexTypography.host(
                          18,
                          weight: FontWeight.w700,
                          color: RexColors.navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Filter all your transactions on Rex',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RexTypography.host(
                          13,
                          color: RexColors.textTxMeta,
                        ),
                      ),
                    ],
                  ),
                ),
                Pressable(
                  key: const Key('txns-filter-close'),
                  semanticLabel: 'Close filter',
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.close_rounded,
                      size: 24,
                      color: RexColors.navy,
                    ),
                  ),
                ),
              ],
            ),
            _section(
              'Date Filter',
              Row(
                children: [
                  _dateField(start: true),
                  const SizedBox(width: 12),
                  _dateField(start: false),
                ],
              ),
            ),
            _section(
              'Quick Filter',
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [for (final q in QuickFilter.quick) _chip(q)],
              ),
            ),
            _section(
              'Bill Payments',
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [for (final q in QuickFilter.bills) _chip(q)],
              ),
            ),
            _section(
              'Amount Range Filter',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _f.amountLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    key: const Key('txns-amount-label'),
                    style: RexTypography.host(
                      15,
                      weight: FontWeight.w600,
                      color: const Color(0xFF274981),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_tick('₦0'), _tick('₦500K'), _tick('₦1M')],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      activeTrackColor: _thumb,
                      inactiveTrackColor: const Color(0xFFE1E6F0),
                      thumbColor: _thumb,
                      overlayColor: _thumb.withValues(alpha: 0.12),
                      rangeThumbShape: const RoundRangeSliderThumbShape(
                        enabledThumbRadius: 12,
                        elevation: 3,
                      ),
                      showValueIndicator: ShowValueIndicator.never,
                    ),
                    child: RangeSlider(
                      key: const Key('txns-amount'),
                      min: 0,
                      max: TxnFilter.maxAmount,
                      divisions: 100,
                      values: RangeValues(_f.minNaira, _f.maxNaira),
                      semanticFormatterCallback: TxnFilter.compact,
                      onChanged: (v) => setState(
                        () => _f = _f.copyWith(
                          minNaira: v.start,
                          maxNaira: v.end,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Pressable(
              key: const Key('txns-apply'),
              semanticLabel: 'Apply Filter',
              onTap: () => Navigator.of(context).pop(_f),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: RexColors.navy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Apply Filter',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RexTypography.host(
                    15,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (widget.initial.isActive || _f.isActive) ...[
              const SizedBox(height: 6),
              Center(
                child: Pressable(
                  key: const Key('txns-filter-reset'),
                  semanticLabel: 'Clear all filters',
                  onTap: () => Navigator.of(context).pop(const TxnFilter()),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Clear all filters',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: RexTypography.host(
                        13,
                        weight: FontWeight.w600,
                        color: RexColors.navy,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
