import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

/// Utility class for internationalization helpers
class I18nUtils {

  /// Format date according to locale
  static String formatDate(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'ar':
        return DateFormat('dd/MM/yyyy', 'ar').format(date);
      case 'fr':
        return DateFormat('dd/MM/yyyy', 'fr').format(date);
      default:
        return DateFormat('MM/dd/yyyy', 'en').format(date);
    }
  }

  /// Format date and time according to locale
  static String formatDateTime(DateTime dateTime, BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'ar':
        return DateFormat('dd/MM/yyyy HH:mm', 'ar').format(dateTime);
      case 'fr':
        return DateFormat('dd/MM/yyyy HH:mm', 'fr').format(dateTime);
      default:
        return DateFormat('MM/dd/yyyy hh:mm a', 'en').format(dateTime);
    }
  }

  /// Format time according to locale
  static String formatTime(DateTime time, BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'ar':
      case 'fr':
        return DateFormat('HH:mm', locale.languageCode).format(time);
      default:
        return DateFormat('hh:mm a', 'en').format(time);
    }
  }

  /// Format currency according to locale
  static String formatCurrency(double amount, BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'ar':
        return NumberFormat.currency(
          locale: 'ar',
          symbol: 'ر.س',
          decimalDigits: 2,
        ).format(amount);
      case 'fr':
        return NumberFormat.currency(
          locale: 'fr',
          symbol: '€',
          decimalDigits: 2,
        ).format(amount);
      default:
        return NumberFormat.currency(
          locale: 'en_US',
          symbol: '\$',
          decimalDigits: 2,
        ).format(amount);
    }
  }

  /// Format numbers according to locale
  static String formatNumber(num number, BuildContext context) {
    final locale = Localizations.localeOf(context);
    return NumberFormat.decimalPattern(locale.languageCode).format(number);
  }

  /// Format percentage according to locale
  static String formatPercentage(double percentage, BuildContext context) {
    final locale = Localizations.localeOf(context);
    return NumberFormat.percentPattern(locale.languageCode).format(percentage / 100);
  }

  /// Get localized month name
  static String getMonthName(int month, BuildContext context) {
    final locale = Localizations.localeOf(context);
    final date = DateTime(2024, month, 1);
    return DateFormat.MMMM(locale.languageCode).format(date);
  }

  /// Get localized day name
  static String getDayName(int weekday, BuildContext context) {
    final locale = Localizations.localeOf(context);
    final date = DateTime(2024, 1, weekday); // Starting from Monday
    return DateFormat.EEEE(locale.languageCode).format(date);
  }

  /// Get relative time (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime, context);
    } else if (difference.inDays > 0) {
      return l10n.updatedAgo('${difference.inDays}d');
    } else if (difference.inHours > 0) {
      return l10n.updatedAgo('${difference.inHours}h');
    } else if (difference.inMinutes > 0) {
      return l10n.updatedAgo('${difference.inMinutes}m');
    } else {
      return l10n.updatedAgo('1m');
    }
  }

  /// Check if current locale is RTL
  static bool isRTL(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return ['ar', 'he', 'fa', 'ur'].contains(locale.languageCode);
  }

  /// Get text direction for current locale
  static TextDirection getTextDirection(BuildContext context) {
    return isRTL(context) ? TextDirection.RTL : TextDirection.LTR;
  }

  /// Get appropriate text alignment for current locale
  static TextAlign getTextAlign(BuildContext context, {TextAlign? defaultAlign}) {
    if (defaultAlign != null) return defaultAlign;
    return isRTL(context) ? TextAlign.right : TextAlign.left;
  }

  /// Get appropriate edge insets for current locale
  static EdgeInsets getDirectionalPadding(
      BuildContext context, {
        double start = 0,
        double top = 0,
        double end = 0,
        double bottom = 0,
      }) {
    return isRTL(context)
        ? EdgeInsets.only(left: end, top: top, right: start, bottom: bottom)
        : EdgeInsets.only(left: start, top: top, right: end, bottom: bottom);
  }

  /// Get appropriate margin for current locale
  static EdgeInsets getDirectionalMargin(
      BuildContext context, {
        double start = 0,
        double top = 0,
        double end = 0,
        double bottom = 0,
      }) {
    return getDirectionalPadding(context, start: start, top: top, end: end, bottom: bottom);
  }

  /// Pluralization helper
  static String pluralize(int count, String singular, String plural) {
    return count == 1 ? singular : plural;
  }

  /// Get appropriate icon for navigation based on direction
  static IconData getBackIcon(BuildContext context) {
    return isRTL(context) ? Icons.arrow_forward : Icons.arrow_back;
  }

  /// Get appropriate icon for forward navigation based on direction
  static IconData getForwardIcon(BuildContext context) {
    return isRTL(context) ? Icons.arrow_back : Icons.arrow_forward;
  }

  /// Validate email format (basic validation)
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate phone number (basic validation)
  static bool isValidPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Check if it has a reasonable length (7-15 digits)
    return digitsOnly.length >= 7 && digitsOnly.length <= 15;
  }

  /// Get localized validation messages
  static String getValidationMessage(
      BuildContext context,
      String fieldName,
      ValidationError error,
      ) {
    final l10n = AppLocalizations.of(context)!;

    switch (error) {
      case ValidationError.required:
        return l10n.validationRequired;
      case ValidationError.invalidEmail:
        return l10n.validationInvalidEmail;
      case ValidationError.passwordTooShort:
        return l10n.validationPasswordTooShort;
      case ValidationError.invalidPhone:
        return l10n.validationInvalidPhone;
      default:
        return 'Invalid input';
    }
  }

  /// Format file size according to locale
  static String formatFileSize(int bytes, BuildContext context) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    final formattedSize = size < 10
        ? size.toStringAsFixed(1)
        : size.toStringAsFixed(0);

    return '$formattedSize ${suffixes[suffixIndex]}';
  }

  /// Get greeting based on time of day and locale
  static String getTimeBasedGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return l10n.welcome; // Could be extended to "Good Morning"
    } else if (hour < 17) {
      return l10n.welcome; // Could be extended to "Good Afternoon"
    } else {
      return l10n.welcome; // Could be extended to "Good Evening"
    }
  }

  /// Get appropriate keyboard type for locale
  static TextInputType getKeyboardType(TextInputType defaultType, BuildContext context) {
    final locale = Localizations.localeOf(context);

    // For Arabic, you might want to adjust keyboard behavior
    if (locale.languageCode == 'ar' && defaultType == TextInputType.text) {
      return TextInputType.text;
    }

    return defaultType;
  }

  /// Get localized status text
  static String getLocalizedStatus(String status, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (status.toLowerCase()) {
      case 'active':
        return l10n.active;
      case 'inactive':
        return l10n.inactive;
      case 'available':
        return l10n.available;
      case 'unavailable':
        return l10n.unavailable;
      case 'booked':
        return l10n.booked;
      case 'pending':
        return l10n.pending;
      case 'completed':
        return l10n.completed;
      case 'cancelled':
        return l10n.cancelled;
      default:
        return status;
    }
  }

  /// Get localized role text
  static String getLocalizedRole(String role, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (role.toLowerCase()) {
      case 'admin':
        return l10n.admin;
      case 'employee':
        return l10n.employee;
      case 'manager':
        return l10n.manager;
      default:
        return role;
    }
  }

  /// Handle text overflow for different locales
  static TextOverflow getTextOverflow(BuildContext context) {
    // Arabic text might need different overflow handling
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? TextOverflow.ellipsis : TextOverflow.fade;
  }

  /// Get appropriate font family for locale
  static String? getFontFamily(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'ar':
        return 'Amiri'; // Example Arabic font
      case 'fr':
        return null; // Use default
      default:
        return null; // Use default
    }
  }

  /// Convert between different calendar systems if needed
  static DateTime convertToLocalCalendar(DateTime dateTime, BuildContext context) {
    final locale = Localizations.localeOf(context);

    // For most cases, return the same date
    // This could be extended to support different calendar systems
    switch (locale.languageCode) {
      case 'ar':
      // Could implement Hijri calendar conversion here
        return dateTime;
      default:
        return dateTime;
    }
  }

  /// Get appropriate text scale factor for locale
  static double getTextScaleFactor(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'ar':
        return 1.0; // Arabic might need slight adjustment
      case 'fr':
        return 1.0; // French usually works well with default
      default:
        return 1.0;
    }
  }

  /// Format duration according to locale
  static String formatDuration(Duration duration, BuildContext context) {
    final locale = Localizations.localeOf(context);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    switch (locale.languageCode) {
      case 'ar':
        if (hours > 0) {
          return '${hours}س ${minutes}د';
        }
        return '${minutes}د';
      case 'fr':
        if (hours > 0) {
          return '${hours}h ${minutes}min';
        }
        return '${minutes}min';
      default:
        if (hours > 0) {
          return '${hours}h ${minutes}m';
        }
        return '${minutes}m';
    }
  }
}

/// Validation error types
enum ValidationError {
  required,
  invalidEmail,
  passwordTooShort,
  invalidPhone,
  invalidFormat,
  tooLong,
  tooShort,
}

/// Extension methods for easier locale handling
extension LocaleExtensions on BuildContext {
  /// Quick access to AppLocalizations
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Quick access to current locale
  Locale get currentLocale => Localizations.localeOf(this);

  /// Check if current locale is RTL
  bool get isRTL => I18nUtils.isRTL(this);

  /// Get text direction
  TextDirection get textDirection => I18nUtils.getTextDirection(this);

  /// Format currency with current locale
  String formatCurrency(double amount) => I18nUtils.formatCurrency(amount, this);

  /// Format date with current locale
  String formatDate(DateTime date) => I18nUtils.formatDate(date, this);

  /// Format time with current locale
  String formatTime(DateTime time) => I18nUtils.formatTime(time, this);

  /// Get relative time
  String getRelativeTime(DateTime dateTime) => I18nUtils.getRelativeTime(dateTime, this);
}