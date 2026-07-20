// import 'package:flutter/material.dart';

// class AppColors {
//   AppColors._(); // prevents anyone from creating an instance

//   // Primary Brand
//   static const Color primary = Color(0xFFF4820A); // Orange
//   static const Color primaryDark = Color(0xFFD06A00); // Pressed state

//   // Navy (used for AppBar, headers, key UI elements)
//   static const Color navy = Color(0xFF1B2A4A);
//   static const Color navyLight = Color(0xFF243660);

//   // Backgrounds — light mode
//   static const Color background = Color(0xFFF5F7FA); // Page background
//   static const Color surface = Color(0xFFFFFFFF); // Cards

//   // Text
//   static const Color textPrimary = Color(0xFF1B2A4A); // Dark navy for headings
//   static const Color textSecondary = Color(0xFF5A6A85); // Muted body text
//   static const Color textHint = Color(0xFFADB5BD); // Placeholder

//   // Borders
//   static const Color border = Color(0xFFE0E6EF);

//   // Status
//   static const Color success = Color(0xFF28A745);
//   static const Color error = Color(0xFFDC3545);
//   static const Color warning = Color(0xFFFFC107);
// }

import 'package:flutter/material.dart';

/// Centralized color palette for the whole app.
/// Keeping colors here (instead of hardcoding hex codes in every screen)
/// means we only change a color ONCE and it updates everywhere — DRY principle.
class AppColors {
  AppColors._(); // private constructor -> prevents instantiation, utility class only

  // ---- PRIMARY BRAND (ORANGE) ----
  static const Color primary = Color(0xFFF4820A); // Main orange
  static const Color primaryDark = Color(0xFFD06A00); // Pressed / darker state
  static const Color primaryLight = Color(
    0xFFFFA94D,
  ); // Lighter orange for highlights/gradients

  // ---- NAVY (AppBar, Drawer header, dark surfaces, headings) ----
  static const Color navy = Color(0xFF1B2A4A);
  static const Color navyLight = Color(0xFF243660);

  // ---- Backgrounds ----
  static const Color background = Color(
    0xFFF5F7FA,
  ); // Page background — soft, neutral
  static const Color surface = Color(0xFFFFFFFF); // Cards / sheets

  // ---- Text ----
  static const Color textPrimary = Color(0xFF1B2A4A); // Headings — dark navy
  static const Color textSecondary = Color(0xFF5A6A85); // Body / muted text
  static const Color textHint = Color(0xFFADB5BD); // Placeholder text

  // ---- Borders ----
  static const Color border = Color(0xFFE0E6EF);

  // ---- Dark Mode ----
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkNavy = Color(0xFF0D1B2A);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkTextHint = Color(0xFF616161);
  static const Color darkBorder = Color(0xFF2C2C2C);

  // ---- Status colors ----
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);

  // ---- Helper getters (context-aware) ----
  static Color backgroundFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
      ? darkBackground
      : background;

  static Color surfaceFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
      ? darkSurface
      : surface;

  static Color navyFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
      ? darkNavy
      : navy;

  static Color navyLightFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
      ? darkNavy
      : navyLight;

  static Color textPrimaryFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
      ? darkTextPrimary
      : textPrimary;

  static Color textSecondaryFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
      ? darkTextSecondary
      : textSecondary;

  static Color textHintFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
      ? darkTextHint
      : textHint;

  static Color borderFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
      ? darkBorder
      : border;
}
