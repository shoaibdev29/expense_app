class DateHelpers {
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);

  /// Returns the start of the week containing [date], using [firstDayOfWeek]
  /// where 1 = Monday ... 7 = Sunday (DateTime weekday values).
  static DateTime startOfWeek(DateTime date, int firstDayOfWeek) {
    final day = startOfDay(date);
    var diff = day.weekday - firstDayOfWeek;
    if (diff < 0) diff += 7;
    return day.subtract(Duration(days: diff));
  }

  static DateTime endOfWeek(DateTime date, int firstDayOfWeek) {
    final start = startOfWeek(date, firstDayOfWeek);
    return endOfDay(start.add(const Duration(days: 6)));
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
