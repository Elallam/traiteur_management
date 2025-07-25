import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class Helpers {
  // ==================== STRING UTILITIES ====================

  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Capitalize first letter only
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Get initials from full name
  static String getInitials(String fullName, {int maxInitials = 2}) {
    if (fullName.isEmpty) return '';

    List<String> names = fullName.trim().split(' ');
    String initials = '';

    for (int i = 0; i < names.length && i < maxInitials; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0].toUpperCase();
      }
    }

    return initials;
  }

  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  /// Remove extra spaces and trim
  static String cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Check if string is email
  static bool isEmail(String text) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text);
  }

  /// Check if string is phone number
  static bool isPhoneNumber(String text) {
    String cleanPhone = text.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleanPhone);
  }

  /// Format phone number
  static String formatPhoneNumber(String phoneNumber) {
    String clean = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (clean.length == 10 && clean.startsWith('0')) {
      // Moroccan mobile: 0612345678 -> 06 12 34 56 78
      return '${clean.substring(0, 2)} ${clean.substring(2, 4)} ${clean.substring(4, 6)} ${clean.substring(6, 8)} ${clean.substring(8)}';
    } else if (clean.length == 10) {
      // Other format: 1234567890 -> (123) 456-7890
      return '(${clean.substring(0, 3)}) ${clean.substring(3, 6)}-${clean.substring(6)}';
    }

    return phoneNumber; // Return original if can't format
  }

  // ==================== NUMBER UTILITIES ====================

  /// Format currency
  static String formatCurrency(double amount, {String symbol = 'DH'}) {
    final formatter = NumberFormat('#,##0.00');
    return '${formatter.format(amount)} $symbol';
  }

  /// Format number with commas
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,##0');
    return formatter.format(number);
  }

  /// Format percentage
  static String formatPercentage(double percentage, {int decimals = 1}) {
    return '${percentage.toStringAsFixed(decimals)}%';
  }

  /// Parse string to double safely
  static double parseDouble(String value, {double defaultValue = 0.0}) {
    try {
      return double.parse(value);
    } catch (e) {
      return defaultValue;
    }
  }

  /// Parse string to int safely
  static int parseInt(String value, {int defaultValue = 0}) {
    try {
      return int.parse(value);
    } catch (e) {
      return defaultValue;
    }
  }

  /// Check if number is positive
  static bool isPositive(num number) {
    return number > 0;
  }

  /// Check if number is zero
  static bool isZero(num number) {
    return number == 0;
  }

  /// Calculate percentage
  static double calculatePercentage(num part, num total) {
    if (total == 0) return 0.0;
    return (part / total) * 100;
  }

  /// Calculate percentage change
  static double calculatePercentageChange(num oldValue, num newValue) {
    if (oldValue == 0) return 0.0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  // ==================== VALIDATION UTILITIES ====================

  /// Validate required field
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validate minimum length
  static bool hasMinLength(String? value, int minLength) {
    return value != null && value.length >= minLength;
  }

  /// Validate maximum length
  static bool hasMaxLength(String? value, int maxLength) {
    return value != null && value.length <= maxLength;
  }

  /// Validate numeric input
  static bool isNumeric(String? value) {
    if (value == null || value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  /// Validate positive number
  static bool isPositiveNumber(String? value) {
    if (!isNumeric(value)) return false;
    return parseDouble(value!) > 0;
  }

  // ==================== COLOR UTILITIES ====================

  /// Generate color from string (for avatars, etc.)
  static int generateColorFromString(String text) {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }

    // Generate RGB values
    int r = (hash & 0xFF0000) >> 16;
    int g = (hash & 0x00FF00) >> 8;
    int b = hash & 0x0000FF;

    // Ensure colors are not too dark or too light
    r = (r % 156) + 100; // 100-255
    g = (g % 156) + 100;
    b = (b % 156) + 100;

    return (0xFF000000) | (r << 16) | (g << 8) | b;
  }

  // ==================== LIST UTILITIES ====================

  /// Check if list is null or empty
  static bool isListEmpty<T>(List<T>? list) {
    return list == null || list.isEmpty;
  }

  /// Get safe list item at index
  static T? getListItem<T>(List<T>? list, int index) {
    if (list == null || index < 0 || index >= list.length) {
      return null;
    }
    return list[index];
  }

  /// Split list into chunks
  static List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i,
          i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  /// Remove duplicates from list
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  // ==================== MAP UTILITIES ====================

  /// Check if map is null or empty
  static bool isMapEmpty<K, V>(Map<K, V>? map) {
    return map == null || map.isEmpty;
  }

  /// Get safe map value
  static V? getMapValue<K, V>(Map<K, V>? map, K key) {
    if (map == null) return null;
    return map[key];
  }

  // ==================== DEVICE UTILITIES ====================

  /// Copy text to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Vibrate device (if available)
  static void vibrate() {
    HapticFeedback.lightImpact();
  }

  /// Heavy vibrate
  static void vibrateHeavy() {
    HapticFeedback.heavyImpact();
  }

  // ==================== ERROR HANDLING ====================

  /// Get user-friendly error message
  static String getUserFriendlyError(dynamic error) {
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network connection error. Please check your internet connection.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('permission')) {
      return 'Permission denied. Please check your permissions.';
    } else if (errorString.contains('not found')) {
      return 'Requested resource not found.';
    } else if (errorString.contains('unauthorized') || errorString.contains('authentication')) {
      return 'Authentication failed. Please login again.';
    } else if (errorString.contains('firebase')) {
      return 'Database error. Please try again later.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ==================== FILE UTILITIES ====================

  /// Get file extension
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  /// Check if file is image
  static bool isImageFile(String fileName) {
    List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(getFileExtension(fileName));
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // ==================== SEARCH UTILITIES ====================

  /// Search in list by property
  static List<T> searchInList<T>(
      List<T> list,
      String query,
      String Function(T) getSearchText,
      ) {
    if (query.isEmpty) return list;

    query = query.toLowerCase().trim();

    return list.where((item) {
      String searchText = getSearchText(item).toLowerCase();
      return searchText.contains(query);
    }).toList();
  }

  /// Highlight search term in text
  static List<TextSpan> highlightSearchTerm(String text, String searchTerm) {
    if (searchTerm.isEmpty) {
      return [TextSpan(text: text)];
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerSearchTerm = searchTerm.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerSearchTerm, start);

    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + searchTerm.length),
        style: const TextStyle(
          backgroundColor: Color(0xFFFFEB3B),
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + searchTerm.length;
      index = lowerText.indexOf(lowerSearchTerm, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  // ==================== SORTING UTILITIES ====================

  /// Sort list by property
  static List<T> sortListBy<T, K extends Comparable>(
      List<T> list,
      K Function(T) getComparable, {
        bool ascending = true,
      }) {
    List<T> sortedList = List.from(list);
    sortedList.sort((a, b) {
      K valueA = getComparable(a);
      K valueB = getComparable(b);
      return ascending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
    });
    return sortedList;
  }

  // ==================== DEBOUNCE UTILITY ====================

  /// Simple debounce implementation
  static void debounce(Duration delay, void Function() action) {
    Timer? timer;
    timer?.cancel();
    timer = Timer(delay, action);
  }
}