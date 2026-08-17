import 'package:intl/intl.dart';

/// Centralized date/time display formatting used across the app.
/// Keep these patterns in sync with the formats already used inline
/// elsewhere in the codebase (e.g. appointment cards, schedule screens).
class AppFormatters {
  AppFormatters._();

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)}, ${formatTime(date)}';
  }
}
