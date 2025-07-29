import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';

  // Default locale
  Locale _locale = const Locale('en');

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic
    Locale('fr'), // French
  ];

  // Language names for display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'ar': 'العربية',
    'fr': 'Français',
  };

  // Language flags/emojis for better UX
  static const Map<String, String> languageFlags = {
    'en': '🇺🇸',
    'ar': '🇸🇦',
    'fr': '🇫🇷',
  };

  // RTL languages
  static const List<String> rtlLanguages = ['ar', 'he', 'fa'];

  Locale get locale => _locale;

  bool get isRTL => rtlLanguages.contains(_locale.languageCode);

  String get currentLanguageName => languageNames[_locale.languageCode] ?? 'English';

  String get currentLanguageFlag => languageFlags[_locale.languageCode] ?? '🇺🇸';

  LocaleProvider() {
    _loadSavedLocale();
  }

  /// Load saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);

      if (savedLocaleCode != null) {
        final savedLocale = Locale(savedLocaleCode);
        if (supportedLocales.contains(savedLocale)) {
          _locale = savedLocale;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading saved locale: $e');
      // Fall back to default locale if there's an error
    }
  }

  /// Set new locale and save to SharedPreferences
  Future<void> setLocale(Locale newLocale) async {
    if (!supportedLocales.contains(newLocale)) {
      debugPrint('Unsupported locale: ${newLocale.languageCode}');
      return;
    }

    if (_locale == newLocale) return;

    _locale = newLocale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Set locale by language code
  Future<void> setLocaleByCode(String languageCode) async {
    final locale = Locale(languageCode);
    await setLocale(locale);
  }

  /// Toggle between supported languages (useful for quick switching)
  Future<void> toggleLanguage() async {
    final currentIndex = supportedLocales.indexOf(_locale);
    final nextIndex = (currentIndex + 1) % supportedLocales.length;
    await setLocale(supportedLocales[nextIndex]);
  }

  /// Reset to default locale
  Future<void> resetToDefault() async {
    await setLocale(const Locale('en'));
  }

  /// Get text direction for current locale
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;

  /// Check if current locale matches given language code
  bool isCurrentLanguage(String languageCode) {
    return _locale.languageCode == languageCode;
  }

  /// Get locale by language code
  static Locale? getLocaleByCode(String languageCode) {
    try {
      return supportedLocales.firstWhere(
            (locale) => locale.languageCode == languageCode,
      );
    } catch (e) {
      return null;
    }
  }

  /// Initialize with system locale if supported
  Future<void> initializeWithSystemLocale() async {
    try {
      final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;

      for (final systemLocale in systemLocales) {
        if (supportedLocales.any((supported) =>
        supported.languageCode == systemLocale.languageCode)) {
          await setLocale(Locale(systemLocale.languageCode));
          return;
        }
      }

      // If no system locale is supported, keep current or default
    } catch (e) {
      debugPrint('Error initializing with system locale: $e');
    }
  }
}