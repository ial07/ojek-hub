import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateHelper {
  static bool _initialized = false;

  /// Initialize locale data. Call this in main.dart or before usage.
  static Future<void> initialize() async {
    if (!_initialized) {
      await initializeDateFormatting('id_ID', null);
      _initialized = true;
    }
  }

  /// Formats date to: "Senin, 24 Jan 2026"
  static String formatJobDate(DateTime? date) {
    if (date == null) return '-';
    // Ensure initialized (defensive, though unlikely to block if async awaited in main)
    return DateFormat('EEEE, d MMM y', 'id_ID').format(date);
  }

  /// Returns relative label: "Hari ini", "Besok", "3 hari lagi"
  /// Returns empty string if outside the 7-day immediate window or past
  static String getRelativeLabel(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final jobDay = DateTime(date.year, date.month, date.day);

    final diff = jobDay.difference(today).inDays;

    if (diff < 0) return ''; // Past
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Besok';
    if (diff <= 7) return '$diff hari lagi';

    return '';
  }

  /// Returns color for the label based on urgency
  static bool isUrgent(DateTime? date) {
    if (date == null) return false;
    final label = getRelativeLabel(date);
    return label == 'Hari ini' || label == 'Besok';
  }
}
