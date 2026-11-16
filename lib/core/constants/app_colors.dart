import 'package:flutter/material.dart';

class AppColors {
  // Brand / Theme Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color accent = Color(0xFFF59E0B); // Amber

  // Feedback Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B);

  // Backgrounds & Neutrals
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCard = Color(0xFF334155); // Slate 700

  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9); // Slate 100

  // Curated Vibrant Cell Palette (Good contrast against white text)
  static const List<Color> curatedPalette = [
    Color(0xFFE11D48), // Rose
    Color(0xFFD97706), // Amber
    Color(0xFF059669), // Emerald
    Color(0xFF0284C7), // Light Blue
    Color(0xFF7C3AED), // Violet
    Color(0xFFDB2777), // Pink
    Color(0xFFEA580C), // Orange
    Color(0xFF16A34A), // Green
    Color(0xFF2563EB), // Blue
    Color(0xFF9333EA), // Purple
    Color(0xFF0D9488), // Teal
    Color(0xFFC026D3), // Fuchsia
    Color(0xFF4338CA), // Indigo
    Color(0xFFCA8A04), // Yellow
    Color(0xFF0891B2), // Cyan
    Color(0xFFBE123C), // Crimson
    Color(0xFF475569), // Slate
    Color(0xFF15803D), // Forest
    Color(0xFF1D4ED8), // Cobalt
    Color(0xFFB45309), // Bronze
    Color(0xFF6D28D9), // Deep Purple
    Color(0xFF047857), // Jade
    Color(0xFF0369A1), // Sky
    Color(0xFF9D174D), // Maroon
    Color(0xFF374151), // Charcoal
  ];

  // Colorblind-friendly Palette (Wong / Okabe-Ito accessible colors)
  static const List<Color> colorblindPalette = [
    Color(0xFFE69F00), // Orange
    Color(0xFF56B4E9), // Sky Blue
    Color(0xFF009E73), // Bluish Green
    Color(0xFFF0E442), // Yellow
    Color(0xFF0072B2), // Blue
    Color(0xFFD55E00), // Vermilion
    Color(0xFFCC79A7), // Reddish Purple
    Color(0xFF004949), // Dark Cyan
    Color(0xFF009292), // Teal
    Color(0xFFFF6DB6), // Pink
    Color(0xFFFFB6DB), // Light Pink
    Color(0xFF490092), // Dark Violet
    Color(0xFF006DDB), // Medium Blue
    Color(0xFFB66DFF), // Light Violet
    Color(0xFF6DB6FF), // Soft Blue
    Color(0xFFB6DBFF), // Pale Blue
    Color(0xFF920000), // Dark Red
    Color(0xFF924900), // Dark Orange
    Color(0xFFDBD100), // Olive Yellow
    Color(0xFF24FF24), // Bright Green
    Color(0xFFFFB677), // Peach
    Color(0xFF333333), // Grey
    Color(0xFF888888), // Medium Grey
    Color(0xFF44AA99), // Sea Green
    Color(0xFF882255), // Wine
  ];
}
