import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/core/utils/dates.dart';
import 'package:macrosapp/core/utils/formatters.dart';

void main() {
  test('addDays always lands on the next calendar midnight, even across DST', () {
    // Spain leaves summer time on the last Sunday of October: that day is
    // 25 hours long, so + Duration(days: 1) would still be the 25th.
    final dstDay = DateTime(2026, 10, 25);
    final next = addDays(dstDay, 1);
    expect(next, DateTime(2026, 10, 26));
    expect(addDays(next, -1), dstDay);
    expect(addDays(DateTime(2026, 3, 28), 2), DateTime(2026, 3, 30));
  });

  test('daysBetween counts calendar days regardless of DST', () {
    expect(daysBetween(DateTime(2026, 10, 25), DateTime(2026, 10, 26)), 1);
    expect(daysBetween(DateTime(2026, 3, 29), DateTime(2026, 3, 28)), -1);
  });

  test('Spanish number formatting uses a decimal comma', () {
    expect(formatKg(80), '80,0 kg');
    expect(formatDecimal(0.5), '0,5');
    expect(formatDecimal(2), '2');
    expect(parseDecimal('1,5'), 1.5);
    expect(parseDecimal('1.5'), 1.5);
  });
}
