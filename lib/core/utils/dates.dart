// Calendar-day arithmetic. Adding Duration(days: n) to a local midnight is
// wrong across a DST change (on 25 Oct in Spain, 00:00 + 24h is still the
// 25th, at 23:00), which silently put entries on the wrong day. Building
// the date from its fields always lands on the intended midnight.
DateTime addDays(DateTime date, int days) => DateTime(date.year, date.month, date.day + days);

// Whole calendar days from a to b, immune to DST (a 23h or 25h day is still
// one day apart).
int daysBetween(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
