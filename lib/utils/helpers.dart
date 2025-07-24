import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date, {String pattern = 'yyyy-MM-dd HH:mm'}) {
    return DateFormat(pattern).format(date);
  }

  static String? nullIfEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }

  static String truncate(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return value.substring(0, maxLength) + '...';
  }
}
