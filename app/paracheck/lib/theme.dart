/*
  This file defines the theme for the ParaCheck Flutter application.
  It sets up colors, typography, and component styles to ensure a consistent
  look and feel across the app, enhancing user experience and visual appeal.
  This centralized theming approach simplifies maintenance and updates.
*/

import 'package:flutter/material.dart';
import 'package:paracheck/design/colors.dart';

ThemeData buildTheme() {
  // Define a color scheme based on a seed color
  final scheme = ColorScheme.fromSeed(seedColor: Colors.blue);
  // Customize the color scheme with app-specific colors
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    // Define text theme for consistent typography
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    // Define input decoration theme for form fields
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: scheme.surface,
    ),
    // Define button theme for elevated buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
  );
}
