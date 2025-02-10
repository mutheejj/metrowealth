import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const primary = Color(0xFFB71C1C);
  static const primaryDark = Color(0xFF7F0000);
  static const primaryLight = Color(0xFFD32F2F);
  
  // Secondary colors
  static const secondary = Color(0xFF1976D2);
  static const secondaryDark = Color(0xFF0D47A1);
  static const secondaryLight = Color(0xFF42A5F5);

  // Background colors
  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const card = Colors.white;

  // Basic colors
  static const white = Colors.white;
  static const black = Colors.black;
  static const transparent = Colors.transparent;
  static const grey = Colors.grey;

  // Text colors
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFF9E9E9E);
  static const textLight = Colors.white;
  static const textDark = Colors.black;

  // Status colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA000);
  static const error = Color(0xFFD32F2F);
  static const info = Color(0xFF2196F3);

  // Category colors
  static const expense = Color(0xFFE53935);
  static const income = Color(0xFF43A047);
  static const savings = Color(0xFF1E88E5);
  static const investment = Color(0xFF6D4C41);

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF2196F3),
    Color(0xFFFFA726),
    Color(0xFF66BB6A),
    Color(0xFFEF5350),
    Color(0xFF8E24AA),
    Color(0xFF26A69A),
    Color(0xFFFF7043),
    Color(0xFF7E57C2),
  ];

  // Gradient colors
  static const gradientStart = Color(0xFFB71C1C);
  static const gradientEnd = Color(0xFFD32F2F);

  // Overlay colors
  static final overlay30 = Colors.black.withOpacity(0.3);
  static final overlay50 = Colors.black.withOpacity(0.5);

  // Get a color shade
  static Color getShade(Color color, {bool darker = false, double amount = .1}) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (darker ? (hsl.lightness - amount) : (hsl.lightness + amount))
          .clamp(0.0, 1.0),
    );

    return hslLight.toColor();
  }

  // Get a gradient from a base color
  static LinearGradient getGradient(Color color) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color,
        getShade(color, darker: true, amount: 0.2),
      ],
    );
  }
} 