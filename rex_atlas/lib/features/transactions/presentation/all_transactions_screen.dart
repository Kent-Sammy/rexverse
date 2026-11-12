import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/formatting/naira.dart';
import '../../../core/widgets/pressable.dart';
import '../../atlas/domain/models/models.dart';
import '../../atlas/presentation/receipt/receipt_header_bar.dart';
import '../../atlas/presentation/screens/atlas_receipt_screen.dart';
import '../../rexflex/presentation/widgets/flex_ui.dart';
import '../data/transactions_feed.dart';
import '../domain/account_transaction.dart';
import 'transaction_filter.dart';

/// "All Transactions": every product in the Rex wallet in one list, with
/// product tabs, a filter sheet, search, and a received/spent summary.
class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({
    super.key,
    required this.feed,
    this.onRepeat,
    this.onAskAtlas,
    this.onOpenRexFlex,
  });

  final TransactionsFeed feed;

  /// Sends a "Repeat Transfer" request to Atlas.
  final ValueChanged<String>? onRepeat;

  /// Opens Atlas with a request (e.g. "Save Money"), from empty states.
  final ValueChanged<String>? onAskAtlas;

  /// Opens RexFlex, from the RexFlex empty state.
  final VoidCallback? onOpenRexFlex;

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  late Future<List<AccountTransaction>> _load = widget.feed.load();
  TxnKind? _kind;
  TxnFilter _f = const TxnFilter();
  String _query = '';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<AccountTransaction> _filter(List<AccountTransaction> all) {
    final q = _query.trim().toLowerCase();
    return [
      for (final t in all)
        if ((_kind == null || t.kind == _kind) &&
            _f.matches(t) &&
            (q.isEmpty ||
                t.title.toLowerCase().contains(q) ||
                t.channel.toLowerCase().contains(q) ||
                t.kind.typeLabel.toLowerCase().contains(q) ||
                (t.counterparty?.toLowerCase().contains(q) ?? false) ||
                Naira.grouped(t.amountKobo).contains(q)))
          t,
    ];
  }

  Future<void> _open(AccountTransaction t) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AtlasReceiptScreen(
          reference: t.reference,
          receipts: widget.feed,
          onRepeat: widget.onRepeat,
        ),
      ),
    );
  }

  Future<void> _pickFilters() async {
    final picked = await TransactionFilterSheet.show(
      context,
      initial: _f,
      now: widget.feed.now,
    );
    if (picked != null) setState(() => _f = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RexColors.appBackground,
      body: Column(
        children: [
          const ReceiptHeaderBar(
            title: 'All Transactions',
            backKey: Key('txns-back'),
          ),
          Expanded(
            child: FutureBuilder<List<AccountTransaction>>(
              future: _load,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: RexColors.primary),
                  );
                }
                if (snap.hasError) {
                  return Center(
                    child: Pressable(
                      semanticLabel: 'Try again',
                      onTap: () => setState(() => _load = widget.feed.load()),
                      child: Text(
                        "We couldn't load your transactions. Tap to try again.",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: RexTypography.sheetBody,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final items = _filter(snap.data!);
                return ListView(
                  key: const Key('txns-list'),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    24 + MediaQuery.paddingOf(context).bottom,
                  ),
                  children: [
                    _SearchRow(
                      controller: _search,
                      filtered: _f.isActive,
                      onChanged: (v) => setState(() => _query = v),
                      onFilter: _pickFilters,
                    ),
                    const SizedBox(height: 8),
                    _ProductTabs(
                      selected: _kind,
                      onSelect: (k) => setState(() => _kind = k),
                    ),
                    if (_f.isActive) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (_f.hasDates)
                            _ActiveChip(
                              key: const Key('txns-clear-dates'),
                              label: _f.dateLabel,
                              onClear: () => setState(
                                () => _f = _f.copyWith(clearDates: true),
                              ),
                            ),
                          if (_f.quick != QuickFilter.all)
                            _ActiveChip(
                              key: const Key('txns-clear-type'),
                              label: _f.quick.label,
                              onClear: () => setState(
                                () => _f = _f.copyWith(quick: QuickFilter.all),
                              ),
                            ),
                          if (_f.hasAmount)
                            _ActiveChip(
                              key: const Key('txns-clear-amount'),
                              label: _f.amountLabel,
                              onClear: () => setState(
                                () => _f = _f.copyWith(
                                  minNaira: 0,
                                  maxNaira: TxnFilter.maxAmount,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    _Summary(items: items, now: widget.feed.now, filter: _f),
                    if (items.isEmpty) ...[
                      const SizedBox(height: 16),
                      _emptyState(),
                    ],
                    ..._groups(items),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    _search.clear();
    setState(() {
      _f = const TxnFilter();
      _query = '';
    });
  }

  /// What to show when the list is empty: a "no matches" card when a search
  /// or filter hid everything, otherwise one for the selected tab.
  Widget _emptyState() {
    if (_query.trim().isNotEmpty || _f.isActive) {
      return FlexEmptyState(
        key: const Key('txns-empty'),
        title: 'No transactions found',
        message:
            'Nothing matches your search or filters. Try another date, type '
            'or amount.',
        actionLabel: 'Clear filters',
        onAction: _clearFilters,
      );
    }
    final ask = widget.onAskAtlas;
    return switch (_kind) {
      TxnKind.rexsave => FlexEmptyState(
        key: const Key('txns-empty'),
        title: 'No RexSave transactions yet',
        message: 'Deposits, interest and withdrawals from RexSave show here.',
        actionLabel: ask == null ? null : 'Start saving',
        onAction: ask == null ? null : () => ask('Save Money'),
      ),
      TxnKind.rexflex => FlexEmptyState(
        key: const Key('txns-empty'),
        title: 'No RexFlex transactions yet',
        message: 'Loans you take and repayments you make show here.',
        actionLabel: widget.onOpenRexFlex == null ? null : 'Get a RexFlex loan',
        onAction: widget.onOpenRexFlex,
      ),
      TxnKind.rexvault => FlexEmptyState(
        key: const Key('txns-empty'),
        title: 'No RexVault transactions yet',
        message:
            'Money you lock in RexVault and the interest it earns show '
            'here.',
        actionLabel: ask == null ? null : 'Save in RexVault',
        onAction: ask == null ? null : () => ask('Save in RexVault'),
      ),
      _ => const FlexEmptyState(
        key: Key('txns-empty'),
        title: 'No transactions yet',
        message: 'Money in and out of your Rex wallet shows here.',
      ),
    };
  }

  List<Widget> _groups(List<AccountTransaction> items) {
    final now = widget.feed.now;
    final out = <Widget>[];
    DateTime? day;
    var group = <AccountTransaction>[];
    void flush() {
      if (group.isEmpty) return;
      out
        ..add(
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
            child: Semantics(
              header: true,
              child: Text(
                _dayLabel(day!, now),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RexTypography.host(15, weight: FontWeight.w600),
              ),
            ),
          ),
        )
        ..add(_Group(items: group, onTap: _open));
      group = [];
    }

    for (final t in items) {
      final d = DateTime(t.at.year, t.at.month, t.at.day);
      if (day != d) {
        flush();
        day = d;
      }
      group.add(t);
    }
    flush();
    return out;
  }
}

/// Icon, icon colour and disc colour for a transaction type.
(IconData, Color, Color) txnKindStyle(TxnKind k) => switch (k) {
  TxnKind.card => (
    Icons.credit_card_rounded,
    const Color(0xFF0E9F2E),
    const Color(0xFFE1F8E6),
  ),
  TxnKind.transfer => (
    Icons.swap_horiz_rounded,
    const Color(0xFF3D6BFF),
    const Color(0xFFE7EEFF),
  ),
  TxnKind.airtime => (
    Icons.phone_in_talk_rounded,
    const Color(0xFF0097A7),
    const Color(0xFFE0F7FA),
  ),
  TxnKind.data => (
    Icons.wifi_rounded,
    const Color(0xFF5177FD),
    const Color(0xFFEFF3FF),
  ),
  TxnKind.bill => (
    Icons.bolt_rounded,
    const Color(0xFFE07B00),
    const Color(0xFFFFF0D9),
  ),
  TxnKind.rexsave => (
    Icons.savings_rounded,
    const Color(0xFFE07B00),
    const Color(0xFFFFF4E5),
  ),
  TxnKind.rexvault => (
    Icons.lock_rounded,
    const Color(0xFF0097A7),
    const Color(0xFFE2FCFF),
  ),
  TxnKind.rexflex => (
    Icons.confirmation_number_rounded,
    const Color(0xFF0E9F2E),
    const Color(0xFFEBF3EB),
  ),
};

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _monthDay(DateTime d) => '${_months[d.month - 1]} ${d.day}';

/// "Today, Nov 9", "Yesterday, Nov 8", "Fri, Nov 6" or "May 28, 2021".
String _dayLabel(DateTime d, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(d).inDays;
  if (diff == 0) return 'Today, ${_monthDay(d)}';
  if (diff == 1) return 'Yesterday, ${_monthDay(d)}';
  if (diff < 7 && diff > 0) {
    return '${_weekdays[d.weekday - 1]}, ${_monthDay(d)}';
  }
  return '${_monthDay(d)}, ${d.year}';
}

String _time(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'AM' : 'PM'}';
}

// ---------------------------------------------------------------------------

BoxDecoration _card() =>
    BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12));

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.filtered,
    required this.onChanged,
    required this.onFilter,
  });
  final TextEditingController controller;
  final bool filtered;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: _card(),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                size: 22,
                color: RexColors.textTxMeta,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: const Key('txns-search'),
                  controller: controller,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  style: RexTypography.host(14),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Search transactions',
                    hintStyle: RexTypography.host(
                      14,
                      color: RexColors.textTxMeta,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 8),
      Pressable(
        key: const Key('txns-filter'),
        semanticLabel: filtered
            ? 'Filter by account or type, filter on'
            : 'Filter by account or type',
        onTap: onFilter,
        child: Container(
          width: 44,
          height: 44,
          decoration: _card(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.tune_rounded, size: 20, color: RexColors.navy),
              if (filtered)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: RexColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

/// All · RexSave · RexFlex · RexVault.
class _ProductTabs extends StatelessWidget {
  const _ProductTabs({required this.selected, required this.onSelect});
  final TxnKind? selected;
  final ValueChanged<TxnKind?> onSelect;

  static const _tabs = <TxnKind?>[
    null,
    TxnKind.rexsave,
    TxnKind.rexflex,
    TxnKind.rexvault,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _tabs.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(child: _tab(_tabs[i])),
        ],
      ],
    );
  }

  Widget _tab(TxnKind? k) {
    final label = k?.filterLabel ?? 'All';
    final on = k == selected;
    return Pressable(
      key: Key('txns-tab-${k?.name ?? 'all'}'),
      semanticLabel: '$label transactions${on ? ', selected' : ''}',
      onTap: () => onSelect(k),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 42,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: on ? const Color(0xFF00308F) : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RexTypography.host(
              13,
              weight: FontWeight.w600,
              color: on ? Colors.white : RexColors.navy,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({super.key, required this.label, required this.onClear});
  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Pressable(
    semanticLabel: 'Showing $label only. Clear filter',
    onTap: onClear,
    child: Container(
      padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
      decoration: BoxDecoration(
        color: RexColors.softBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RexTypography.host(
                13,
                weight: FontWeight.w600,
                color: RexColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.close_rounded, size: 16, color: RexColors.navy),
        ],
      ),
    ),
  );
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.items,
    required this.now,
    required this.filter,
  });
  final List<AccountTransaction> items;
  final DateTime now;
  final TxnFilter filter;

  @override
  Widget build(BuildContext context) {
    final today = DateTime(now.year, now.month, now.day);
    var inK = 0, outK = 0;
    for (final t in items) {
      if (t.status == TransactionStatus.failed) continue;
      // With a date filter, total the chosen range; otherwise today.
      if (!filter.hasDates && t.at.isBefore(today)) continue;
      if (t.isCredit) {
        inK += t.amountKobo;
      } else {
        outK += t.amountKobo;
      }
    }
    Widget side(bool received, int kobo) => Expanded(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: received
                  ? const Color(0xFFE1F8E6)
                  : const Color(0xFFFDE7E5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              received
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 18,
              color: received ? RexColors.success : RexColors.error,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    Naira.groupedWhole(kobo),
                    key: Key(received ? 'txns-received' : 'txns-spent'),
                    style: RexTypography.host(16, weight: FontWeight.w700),
                  ),
                ),
                Text(
                  received ? 'Received' : 'Spent',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RexTypography.host(
                    12,
                    weight: FontWeight.w500,
                    color: const Color(0xFF3A4D7A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                side(true, inK),
                const VerticalDivider(
                  width: 24,
                  thickness: 1,
                  color: RexColors.divider,
                ),
                side(false, outK),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: RexColors.divider),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Your Rex wallet',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RexTypography.host(
                  11,
                  weight: FontWeight.w500,
                  color: RexColors.textTxMeta,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.circle, size: 5, color: Color(0xFFC5CCDA)),
              ),
              Text(
                filter.hasDates ? filter.dateLabel : 'Today, ${_monthDay(now)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RexTypography.host(
                  11,
                  weight: FontWeight.w500,
                  color: RexColors.textTxMeta,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.items, required this.onTap});
  final List<AccountTransaction> items;
  final ValueChanged<AccountTransaction> onTap;

  @override
  Widget build(BuildContext context) => Container(
    decoration: _card(),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: RexColors.divider),
          _Row(t: items[i], onTap: () => onTap(items[i])),
        ],
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.t, required this.onTap});
  final AccountTransaction t;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, fg, bg) = txnKindStyle(t.kind);
    final (statusText, statusColor) = switch (t.status) {
      TransactionStatus.successful => ('Successful', RexColors.success),
      TransactionStatus.pending => ('Pending', RexColors.warning),
      TransactionStatus.failed => ('Failed', RexColors.error),
    };
    final amount =
        '${t.isCredit ? '+' : ''}${Naira.groupedWhole(t.amountKobo)}';
    return Pressable(
      key: Key('txn-${t.reference}'),
      semanticLabel:
          '${t.title}, ${t.channel}, ${_time(t.at)}, '
          '${t.isCredit ? 'received' : 'paid'} $amount, $statusText',
      onTap: onTap,
      pressedScale: 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, size: 19, color: fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RexTypography.host(14, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${t.channel}  •  ${_time(t.at)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RexTypography.host(
                      12,
                      weight: FontWeight.w500,
                      color: RexColors.textTxMeta,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: RexTypography.host(
                    14,
                    weight: FontWeight.w700,
                    color: t.isCredit
                        ? RexColors.success
                        : RexColors.textStrong,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RexTypography.host(
                    12,
                    weight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
