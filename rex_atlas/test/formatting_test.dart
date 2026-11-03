import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/core/formatting/dates.dart';
import 'package:rex_atlas/core/formatting/naira.dart';

void main() {
  test('Naira formats match the Figma copy', () {
    expect(Naira.plain(300000), '₦3000');
    expect(Naira.fixed(300000), '₦3000.00');
    expect(Naira.fixed(0), '₦0.00');
    expect(Naira.plain(10000000), '₦100,000');
    expect(Naira.fixed(394521), '₦3945.21');
    expect(Naira.fixed(10000000), '₦100,000.00');
    expect(Naira.grouped(300000), '₦3,000.00');
    expect(Naira.groupedWhole(5000000), '₦50,000');
    expect(Naira.grouped(50056367000), '₦500,563,670.00');
  });

  test('Receipt dates use ordinal days', () {
    expect(
      RexDates.receipt(DateTime(2025, 10, 17, 13, 38, 31)),
      'Oct 17th, 2025 13:38:31',
    );
    expect(
      RexDates.receipt(DateTime(2025, 10, 1, 9, 5, 2)),
      'Oct 1st, 2025 09:05:02',
    );
    expect(
      RexDates.receipt(DateTime(2025, 10, 12, 9, 5, 2)),
      'Oct 12th, 2025 09:05:02',
    );
    expect(RexDates.short(DateTime(2021, 5, 28)), 'May 28, 2021');
  });

  test('Greeting follows time of day', () {
    expect(RexDates.greeting(DateTime(2026, 1, 1, 9)), 'Good morning,');
    expect(RexDates.greeting(DateTime(2026, 1, 1, 14)), 'Good afternoon,');
    expect(RexDates.greeting(DateTime(2026, 1, 1, 20)), 'Good evening,');
  });
}
