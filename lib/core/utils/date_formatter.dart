import 'package:intl/intl.dart';

/// Helper format tanggal ala Indonesia, mis. "23 Juli 2026".
class DateFormatter {
  DateFormatter._();

  static final DateFormat _full = DateFormat('d MMMM yyyy', 'id_ID');
  static final DateFormat _short = DateFormat('d MMM', 'id_ID');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _dayName = DateFormat('EEEE', 'id_ID');

  static String full(DateTime date) => _full.format(date);
  static String short(DateTime date) => _short.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);
  static String dayName(DateTime date) => _dayName.format(date);

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);
}
