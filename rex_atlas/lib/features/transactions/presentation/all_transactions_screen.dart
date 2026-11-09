import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/formatting/naira.dart';
import '../../../core/widgets/pressable.dart';
import '../../atlas/domain/models/models.dart';
import '../../atlas/presentation/receipt/receipt_header_bar.dart';
import '../../atlas/presentation/screens/atlas_receipt_screen.dart';
import '../data/transactions_feed.dart';
import '../domain/account_transaction.dart';

/// "All Transactions": every account and every product in one list, with
/// account chips, a type filter, search, and a received/spent summary.
class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key, required this.feed, this.onRepeat});

  final TransactionsFeed feed;

  /// Sends a "Repeat Transfer" request to Atlas.
  final ValueChanged<String>? onRepeat;

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

enum _AccountFilter { all, personal, business, pos }

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  late Future<List<AccountTransaction>> _load = widget.feed.load();
  _AccountFilter _account = _AccountFilter.all;
  TxnKind? _kind;
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
        if ((_account == _AccountFilter.all ||
                t.account.index == _account.index - 1) &&
            (_kind == null ||
                t.kind == _kind ||
                (_kind == TxnKind.airtime && t.kind == TxnKind.data)) &&
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

  Future<void> _pickType() async {
    final picked = await showModalBottomSheet<_KindChoice>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TypeSheet(selected: _kind),
    );
    if (picked != null) setState(() => _kind = picked.kind);
  }

  void _notice(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

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
                    _AccountsCard(
                      onTap: () => _notice(
                        'Switching accounts is part of the main Rex app.',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SearchRow(
                      controller: _search,
                      filtered: _kind != null,
                      onChanged: (v) => setState(() => _query = v),
                      onFilter: _pickType,
                    ),
                    const SizedBox(height: 8),
                    _AccountChips(
                      selected: _account,
                      onSelect: (a) => setState(() => _account = a),
                    ),
                    if (_kind != null) ...[
                      const SizedBox(height: 8),
                      _ActiveType(
                        kind: _kind!,
                        onClear: () => setState(() => _kind = null),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _Summary(
                      items: items,
                      now: widget.feed.now,
                      scope: switch (_account) {
                        _AccountFilter.all => 'Across all accounts',
                        _AccountFilter.personal => 'Personal account',
                        _AccountFilter.business => 'Business accounts',
                        _AccountFilter.pos => 'POS terminals',
                      },
                    ),
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Text(
                          'No transactions match. Try another account, type '
                          'or search.',
                          key: const Key('txns-empty'),
                          textAlign: TextAlign.center,
                          style: RexTypography.host(
                            13,
                            color: RexColors.textTxMeta,
                          ),
                        ),
                      ),
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
                style: RexTypography.host(14, weight: FontWeight.w600),
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

class _AccountsCard extends StatelessWidget {
  const _AccountsCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    semanticLabel: 'All Accounts: Personal, 2 business accounts, 4 POS',
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: _card(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE7EEFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              size: 20,
              color: Color(0xFF1456F4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Accounts',
                  style: RexTypography.host(14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Personal, 2 business accounts, 4 POS',
                  style: RexTypography.host(12, color: const Color(0xFF3A4D7A)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF5177FD)),
        ],
      ),
    ),
  );
}

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
            ? 'Filter by type, filter on'
            : 'Filter by type',
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

class _AccountChips extends StatelessWidget {
  const _AccountChips({required this.selected, required this.onSelect});
  final _AccountFilter selected;
  final ValueChanged<_AccountFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    const labels = ['All', 'Personal', 'Business', 'POS'];
    return Row(
      children: [
        for (final f in _AccountFilter.values) ...[
          if (f.index > 0) const SizedBox(width: 6),
          Expanded(
            child: Pressable(
              key: Key('txns-chip-${labels[f.index].toLowerCase()}'),
              semanticLabel:
                  '${labels[f.index]} accounts'
                  '${f == selected ? ', selected' : ''}',
              onTap: () => onSelect(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: f == selected ? const Color(0xFF00308F) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    labels[f.index],
                    style: RexTypography.host(
                      13,
                      weight: FontWeight.w600,
                      color: f == selected ? Colors.white : RexColors.navy,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActiveType extends StatelessWidget {
  const _ActiveType({required this.kind, required this.onClear});
  final TxnKind kind;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Pressable(
      key: const Key('txns-clear-type'),
      semanticLabel: 'Showing ${_kindLabel(kind)} only. Clear filter',
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
            Text(
              _kindLabel(kind),
              style: RexTypography.host(
                12,
                weight: FontWeight.w600,
                color: RexColors.navy,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.close_rounded, size: 16, color: RexColors.navy),
          ],
        ),
      ),
    ),
  );
}

String _kindLabel(TxnKind k) =>
    k == TxnKind.airtime ? 'Airtime & Data' : k.filterLabel;

class _Summary extends StatelessWidget {
  const _Summary({required this.items, required this.now, required this.scope});
  final List<AccountTransaction> items;
  final DateTime now;
  final String scope;

  @override
  Widget build(BuildContext context) {
    final today = DateTime(now.year, now.month, now.day);
    var inK = 0, outK = 0;
    for (final t in items) {
      if (t.status == TransactionStatus.failed) continue;
      if (t.at.isBefore(today)) continue;
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
                    style: RexTypography.host(15, weight: FontWeight.w600),
                  ),
                ),
                Text(
                  received ? 'Received' : 'Spent',
                  style: RexTypography.host(12, color: const Color(0xFF3A4D7A)),
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
                scope,
                style: RexTypography.host(11, color: RexColors.textTxMeta),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.circle, size: 5, color: Color(0xFFC5CCDA)),
              ),
              Text(
                'Today, ${_monthDay(now)}',
                style: RexTypography.host(11, color: RexColors.textTxMeta),
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

  static (IconData, Color, Color) _style(TxnKind k) => switch (k) {
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

  @override
  Widget build(BuildContext context) {
    final (icon, fg, bg) = _style(t.kind);
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
                    style: RexTypography.host(14, weight: FontWeight.w500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${t.channel}  •  ${_time(t.at)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RexTypography.host(12, color: RexColors.textTxMeta),
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
                    weight: FontWeight.w600,
                    color: t.isCredit
                        ? RexColors.success
                        : RexColors.textStrong,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  statusText,
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

class _KindChoice {
  const _KindChoice(this.kind);
  final TxnKind? kind;
}

class _TypeSheet extends StatelessWidget {
  const _TypeSheet({required this.selected});
  final TxnKind? selected;

  static const _options = <TxnKind?>[
    null,
    TxnKind.transfer,
    TxnKind.card,
    TxnKind.airtime,
    TxnKind.bill,
    TxnKind.rexsave,
    TxnKind.rexvault,
    TxnKind.rexflex,
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RexColors.sheetHandle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Filter by type',
            style: RexTypography.host(18, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final k in _options)
            Pressable(
              key: Key('txns-type-${k?.name ?? 'all'}'),
              semanticLabel:
                  '${k == null ? 'All types' : _kindLabel(k)}'
                  '${k == selected ? ', selected' : ''}',
              onTap: () => Navigator.of(context).pop(_KindChoice(k)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: k == selected
                      ? RexColors.softBlue
                      : const Color(0xFFF7F8FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        k == null ? 'All types' : _kindLabel(k),
                        style: RexTypography.host(14, weight: FontWeight.w500),
                      ),
                    ),
                    if (k == selected)
                      const Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: RexColors.accentBlue,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
