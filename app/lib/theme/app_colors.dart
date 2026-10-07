import 'package:flutter/material.dart';

/// TrendLens "Bright Creator" design tokens.
/// Accent palette is shared between light and dark themes; only the
/// surfaces and text colors change.
class AppColors {
  // Brand accents (same in both themes)
  static const Color primary = Color(0xFF7C3AED); // purple
  static const Color pink = Color(0xFFEC4899); // pink
  static const Color blue = Color(0xFF0284C7); // blue
  static const Color success = Color(0xFF16A34A); // green
  static const Color orange = Color(0xFFF97316); // orange / coral

  /// Signature violet -> pink gradient for heroes, primary CTAs and Go Pro cards.
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light theme ("TrendLens Bright Creator", default)
  static const Color lightBackground = Color(0xFFFAFAF8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF1F1F4);
  static const Color lightText = Color(0xFF111827);
  static const Color lightMuted = Color(0xFF6B7280);

  // Dark theme
  static const Color darkBackground = Color(0xFF0E0E12);
  static const Color darkCard = Color(0xFF1A1A22);
  static const Color darkSurface = Color(0xFF23232E);
  static const Color darkText = Color(0xFFF9FAFB);
  static const Color darkMuted = Color(0xFF9CA3AF);
}

/// Converts a hex string like "#7C3AED" into a [Color].
Color hexToColor(String hex) {
  var value = hex.replaceAll('#', '').trim();
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}
