abstract final class RexDates {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _ordinal(int d) {
    if (d >= 11 && d <= 13) return '${d}th';
    return switch (d % 10) {
      1 => '${d}st',
      2 => '${d}nd',
      3 => '${d}rd',
      _ => '${d}th',
    };
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// `Oct 17th, 2025 13:38:31` (receipt style from Figma).
  static String receipt(DateTime t) =>
      '${_months[t.month - 1]} ${_ordinal(t.day)}, ${t.year} '
      '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';

  /// `May 28, 2021` (history list style from Figma).
  static String short(DateTime t) =>
      '${_months[t.month - 1]} ${t.day}, ${t.year}';

  /// `Oct. 25, 2026 . 19:30` (welcome recent-transaction style from Figma).
  static String welcome(DateTime t) =>
      '${_months[t.month - 1]}. ${t.day}, ${t.year} . ${_two(t.hour)}:${_two(t.minute)}';

  /// `Today 9:41 AM` (iMessage-style conversation header).
  static String clock(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    return '$h:${_two(t.minute)} ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  static String greeting(DateTime now) {
    final h = now.hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}
