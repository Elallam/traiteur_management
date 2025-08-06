import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2E7D4A); // Green for catering/food
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B4332);
  static const Color primaryAccent = Color(0xFF66BB6A);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF6B35); // Orange accent
  static const Color secondaryLight = Color(0xFFFF8A65);
  static const Color secondaryDark = Color(0xFFE65100);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF757575);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF424242);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE0E0E0);

  // Gradient Definitions for Enhanced UI
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2E7D4A), // primary
      Color(0xFF4CAF50), // primaryLight
    ],
    stops: [0.0, 1.0],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B35), // secondary
      Color(0xFFFF8A65), // secondaryLight
    ],
    stops: [0.0, 1.0],
  );

  // Background gradients for screens
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8F9FA), // Very light grey
      Color(0xFFFFFFFF), // White
      Color(0xFFF5F7FA), // Light blue-grey
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2ECC71), // Vibrant green
      Color(0xFF3498DB), // Clean blue
      Color(0xFF1ABC9C), // Turquoise
    ],
    stops: [0.0, 0.6, 1.0],
  );

  // Card and surface gradients
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFAFBFC),
    ],
    stops: [0.0, 1.0],
  );

  // Button gradients
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2E7D4A),
      Color(0xFF4CAF50),
    ],
    stops: [0.0, 1.0],
  );

  static const LinearGradient buttonHoverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1B4332),
      Color(0xFF2E7D4A),
    ],
    stops: [0.0, 1.0],
  );

  // Accent gradients for special elements
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF2E7D4A),
      Color(0xFFFF6B35),
    ],
    stops: [0.0, 1.0],
  );

  // Shimmer colors for loading states
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Overlay colors
  static const Color overlayLight = Color(0x0A000000);
  static const Color overlayMedium = Color(0x1F000000);
  static const Color overlayDark = Color(0x52000000);

  // Special colors for enhanced login/splash
  static const Color logoBackground = Color(0xFFFFFFFF);
  static const Color logoShadow = Color(0x40000000);
  static const Color ornamentColor = Color(0xFF2E7D4A);
  static const Color patternColor = Color(0x1A2E7D4A);

  // Input field colors
  static const Color inputBackground = Color(0xFFFAFBFC);
  static const Color inputBorder = Color(0xFFE1E5E9);
  static const Color inputFocusBorder = Color(0xFF2E7D4A);
  static const Color inputErrorBorder = Color(0xFFE53E3E);

  // Utility methods for color manipulation
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static LinearGradient scaleGradient(LinearGradient gradient, double factor) {
    return LinearGradient(
      begin: gradient.begin,
      end: gradient.end,
      colors: gradient.colors.map((color) =>
      Color.lerp(Colors.transparent, color, factor) ?? color
      ).toList(),
      stops: gradient.stops,
    );
  }

  // Theme-specific color schemes
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: primary,
    primaryContainer: primaryLight,
    secondary: secondary,
    secondaryContainer: secondaryLight,
    surface: surface,
    background: background,
    error: error,
    onPrimary: white,
    onSecondary: white,
    onSurface: textPrimary,
    onBackground: textPrimary,
    onError: white,
  );

  // Material 3 compatible colors
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color outline = Color(0xFFD1D5DB);
  static const Color outlineVariant = Color(0xFFE5E7EB);
  static const Color scrim = Color(0xFF000000);
}