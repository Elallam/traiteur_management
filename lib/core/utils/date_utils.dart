import 'package:intl/intl.dart';

class DateUtils {
  // Date Formatters
  static final DateFormat _dayMonthYear = DateFormat('dd/MM/yyyy');
  static final DateFormat _dayMonthYearTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYear = DateFormat('MM/yyyy');
  static final DateFormat _dayMonth = DateFormat('dd MMM');
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _fullDate = DateFormat('EEEE, dd MMMM yyyy');
  static final DateFormat _shortDate = DateFormat('dd MMM yyyy');

  /// Format date as DD/MM/YYYY
  static String formatDate(DateTime date) {
    return _dayMonthYear.format(date);
  }

  /// Format date and time as DD/MM/YYYY HH:MM
  static String formatDateTime(DateTime dateTime) {
    return _dayMonthYearTime.format(dateTime);
  }

  /// Format as MM/YYYY for monthly reports
  static String formatMonthYear(DateTime date) {
    return _monthYear.format(date);
  }

  /// Format as DD MMM (e.g., 15 Jan)
  static String formatDayMonth(DateTime date) {
    return _dayMonth.format(date);
  }

  /// Format time as HH:MM
  static String formatTime(DateTime dateTime) {
    return _time.format(dateTime);
  }

  /// Format as full date (e.g., Monday, 15 January 2024)
  static String formatFullDate(DateTime date) {
    return _fullDate.format(date);
  }

  /// Format as short date (e.g., 15 Jan 2024)
  static String formatShortDate(DateTime date) {
    return _shortDate.format(date);
  }

  /// Get relative time (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      // Past time
      final absDifference = difference.abs();

      if (absDifference.inDays > 0) {
        return '${absDifference.inDays} day${absDifference.inDays == 1 ? '' : 's'} ago';
      } else if (absDifference.inHours > 0) {
        return '${absDifference.inHours} hour${absDifference.inHours == 1 ? '' : 's'} ago';
      } else if (absDifference.inMinutes > 0) {
        return '${absDifference.inMinutes} minute${absDifference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } else {
      // Future time
      if (difference.inDays > 0) {
        return 'in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
      } else if (difference.inHours > 0) {
        return 'in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
      } else if (difference.inMinutes > 0) {
        return 'in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
      } else {
        return 'Now';
      }
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if date is in current week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is in current month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if date is in current year
  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// Get smart date format (Today, Yesterday, or date)
  static String getSmartDateFormat(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else if (isThisWeek(date)) {
      return DateFormat('EEEE').format(date); // Day name
    } else if (isThisYear(date)) {
      return formatDayMonth(date);
    } else {
      return formatShortDate(date);
    }
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final daysToSubtract = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysToSubtract)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final daysToAdd = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToAdd)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Get end of year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  /// Get days between two dates
  static int daysBetween(DateTime startDate, DateTime endDate) {
    final start = startOfDay(startDate);
    final end = startOfDay(endDate);
    return end.difference(start).inDays;
  }

  /// Get working days between two dates (excluding weekends)
  static int workingDaysBetween(DateTime startDate, DateTime endDate) {
    int totalDays = daysBetween(startDate, endDate);
    int workingDays = 0;

    for (int i = 0; i <= totalDays; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      if (currentDate.weekday != DateTime.saturday &&
          currentDate.weekday != DateTime.sunday) {
        workingDays++;
      }
    }

    return workingDays;
  }

  /// Get age from birth date
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Parse date string in various formats
  static DateTime? parseDate(String dateString) {
    try {
      // Try different date formats
      List<DateFormat> formats = [
        DateFormat('dd/MM/yyyy'),
        DateFormat('dd-MM-yyyy'),
        DateFormat('yyyy-MM-dd'),
        DateFormat('dd/MM/yyyy HH:mm'),
        DateFormat('dd-MM-yyyy HH:mm'),
        DateFormat('yyyy-MM-dd HH:mm'),
      ];

      for (DateFormat format in formats) {
        try {
          return format.parse(dateString);
        } catch (e) {
          continue;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get month name
  static String getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return months[month - 1];
  }

  /// Get short month name
  static String getShortMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return months[month - 1];
  }

  /// Get day name
  static String getDayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];

    return days[weekday - 1];
  }

  /// Get short day name
  static String getShortDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Get quarter from date
  static int getQuarter(DateTime date) {
    return ((date.month - 1) ~/ 3) + 1;
  }

  /// Get dates for current week
  static List<DateTime> getCurrentWeekDates() {
    final now = DateTime.now();
    final startOfWeek = DateUtils.startOfWeek(now);

    List<DateTime> weekDates = [];
    for (int i = 0; i < 7; i++) {
      weekDates.add(startOfWeek.add(Duration(days: i)));
    }

    return weekDates;
  }

  /// Get dates for current month
  static List<DateTime> getCurrentMonthDates() {
    final now = DateTime.now();
    final startOfMonth = DateUtils.startOfMonth(now);
    final endOfMonth = DateUtils.endOfMonth(now);
    final totalDays = endOfMonth.day;

    List<DateTime> monthDates = [];
    for (int i = 0; i < totalDays; i++) {
      monthDates.add(startOfMonth.add(Duration(days: i)));
    }

    return monthDates;
  }

  /// Check if year is leap year
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Get duration in human readable format
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    } else {
      return '${duration.inSeconds} second${duration.inSeconds == 1 ? '' : 's'}';
    }
  }

  /// Get time until date
  static String getTimeUntil(DateTime futureDate) {
    final now = DateTime.now();
    final difference = futureDate.difference(now);

    if (difference.isNegative) {
      return 'Past due';
    }

    return formatDuration(difference);
  }

  /// Get date range string
  static String formatDateRange(DateTime startDate, DateTime endDate) {
    if (isSameDay(startDate, endDate)) {
      return formatDate(startDate);
    } else if (startDate.month == endDate.month && startDate.year == endDate.year) {
      return '${startDate.day} - ${formatDate(endDate)}';
    } else {
      return '${formatDate(startDate)} - ${formatDate(endDate)}';
    }
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get next occurrence of a weekday
  static DateTime getNextWeekday(int weekday) {
    final now = DateTime.now();
    int daysUntilWeekday = weekday - now.weekday;

    if (daysUntilWeekday <= 0) {
      daysUntilWeekday += 7;
    }

    return now.add(Duration(days: daysUntilWeekday));
  }

  /// Get previous occurrence of a weekday
  static DateTime getPreviousWeekday(int weekday) {
    final now = DateTime.now();
    int daysSinceWeekday = now.weekday - weekday;

    if (daysSinceWeekday <= 0) {
      daysSinceWeekday += 7;
    }

    return now.subtract(Duration(days: daysSinceWeekday));
  }

  /// Validate date string
  static bool isValidDate(String dateString) {
    return parseDate(dateString) != null;
  }

  /// Get business days in month (excluding weekends)
  static int getBusinessDaysInMonth(DateTime date) {
    final startOfMonth = DateUtils.startOfMonth(date);
    final endOfMonth = DateUtils.endOfMonth(date);

    return workingDaysBetween(startOfMonth, endOfMonth);
  }

  /// Convert minutes to hours and minutes string
  static String minutesToHoursAndMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Get fiscal year (assuming April-March fiscal year)
  static String getFiscalYear(DateTime date) {
    if (date.month >= 4) {
      return '${date.year}-${date.year + 1}';
    } else {
      return '${date.year - 1}-${date.year}';
    }
  }

  /// Get date with time set to specific hour
  static DateTime setTimeOfDay(DateTime date, int hour, [int minute = 0, int second = 0]) {
    return DateTime(date.year, date.month, date.day, hour, minute, second);
  }

  /// Check if date is within range
  static bool isDateInRange(DateTime date, DateTime startDate, DateTime endDate) {
    return date.isAfter(startDate.subtract(const Duration(milliseconds: 1))) &&
        date.isBefore(endDate.add(const Duration(milliseconds: 1)));
  }
}