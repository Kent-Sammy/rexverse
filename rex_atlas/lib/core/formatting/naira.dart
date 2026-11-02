/// Naira formatting helpers. Amounts are stored as integer kobo to avoid
/// floating-point money.
abstract final class Naira {
  static const symbol = '₦';

  /// `₦3000` – compact style used in chat bubbles and review rows.
  static String plain(int kobo) {
    final naira = kobo ~/ 100;
    final rem = kobo % 100;
    return rem == 0 ? '$symbol$naira' : '$symbol$naira.${_two(rem)}';
  }

  /// `₦3000.00` – used for totals and the confirmation card.
  static String fixed(int kobo) => '$symbol${kobo ~/ 100}.${_two(kobo % 100)}';

  /// `₦3,000.00` – grouped style used on receipts.
  static String grouped(int kobo) =>
      '$symbol${_group(kobo ~/ 100)}.${_two(kobo % 100)}';

  /// `₦50,000` – grouped without decimals.
  static String groupedWhole(int kobo) => '$symbol${_group(kobo ~/ 100)}';

  static String _two(int v) => v.toString().padLeft(2, '0');

  static String _group(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
