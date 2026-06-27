import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // prevents anyone from creating an instance

  // Primary Brand
  static const Color primary = Color(0xFFF4820A); // Orange
  static const Color primaryDark = Color(0xFFD06A00); // Pressed state

  // Navy (used for AppBar, headers, key UI elements)
  static const Color navy = Color(0xFF1B2A4A);
  static const Color navyLight = Color(0xFF243660);

  // Backgrounds — light mode
  static const Color background = Color(0xFFF5F7FA); // Page background
  static const Color surface = Color(0xFFFFFFFF); // Cards

  // Text
  static const Color textPrimary = Color(0xFF1B2A4A); // Dark navy for headings
  static const Color textSecondary = Color(0xFF5A6A85); // Muted body text
  static const Color textHint = Color(0xFFADB5BD); // Placeholder

  // Borders
  static const Color border = Color(0xFFE0E6EF);

  // Status
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
}
