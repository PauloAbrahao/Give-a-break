import '../../domain/entities/routine.dart';

extension RoutineTimeExtensions on Routine {
  /// Parses a time string in "HH:mm" format to a DateTime for today.
  DateTime? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Returns the start time as DateTime for today, or null if not set.
  DateTime? get startDateTime => _parseTime(startTime);

  /// Returns the end time as DateTime for today, or null if not set.
  DateTime? get endDateTime => _parseTime(endTime);

  /// Checks if the routine has valid time configuration.
  bool get hasTimeConfig => startTime != null && endTime != null;

  /// Checks if today is one of the routine's active days.
  /// DateTime.weekday: Monday = 1, Sunday = 7
  /// Routine days: Sunday = 0, Monday = 1, ..., Saturday = 6
  bool get isActiveToday {
    if (!isEnabled) return false;
    final now = DateTime.now();
    final todayIndex = now.weekday == 7 ? 0 : now.weekday;
    return days.contains(todayIndex);
  }

  /// Checks if the routine is currently running (within start and end time).
  bool get isCurrentlyRunning {
    if (!isEnabled || !isActiveToday) return false;
    if (!hasTimeConfig) return true;

    final now = DateTime.now();
    final start = startDateTime;
    final end = endDateTime;

    if (start == null || end == null) return true;

    return now.isAfter(start) && now.isBefore(end);
  }

  /// Checks if the routine is upcoming today (hasn't started yet).
  bool get isUpcomingToday {
    if (!isEnabled || !isActiveToday) return false;
    if (!hasTimeConfig) return false;

    final now = DateTime.now();
    final start = startDateTime;

    if (start == null) return false;

    return now.isBefore(start);
  }

  /// Returns the next occurrence of this routine as DateTime.
  /// Returns null if the routine has no upcoming occurrence.
  DateTime? get nextOccurrence {
    if (!isEnabled) return null;
    if (days.isEmpty) return null;

    final now = DateTime.now();
    final todayIndex = now.weekday == 7 ? 0 : now.weekday;

    // Check if routine is upcoming today
    if (isUpcomingToday && startDateTime != null) {
      return startDateTime;
    }

    // Find next day
    for (int i = 1; i <= 7; i++) {
      final checkDayIndex = (todayIndex + i) % 7;
      if (days.contains(checkDayIndex)) {
        final daysUntil = i;
        final nextDate = now.add(Duration(days: daysUntil));
        final start = _parseTime(startTime);
        if (start != null) {
          return DateTime(
            nextDate.year,
            nextDate.month,
            nextDate.day,
            start.hour,
            start.minute,
          );
        }
        return DateTime(nextDate.year, nextDate.month, nextDate.day, 0, 0);
      }
    }

    return null;
  }

  /// Returns a human-readable string for the next occurrence.
  String? get nextOccurrenceText {
    final next = nextOccurrence;
    if (next == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextDay = DateTime(next.year, next.month, next.day);

    String dayText;
    if (nextDay == today) {
      dayText = 'Today';
    } else if (nextDay == tomorrow) {
      dayText = 'Tomorrow';
    } else {
      dayText = _weekdayName(next.weekday);
    }

    if (startTime != null) {
      return '$dayText at $startTime';
    }
    return dayText;
  }

  String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[weekday - 1];
  }
}
