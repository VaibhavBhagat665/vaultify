import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFE94560);
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF1D1E33);
  static const Color surfaceLight = Color(0xFF2D2E43);
  static const Color border = Color(0xFF2D2E43);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8D8E98);
  static const Color textMuted = Color(0xFF8D8E98);
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFE94560);
  static const Color warning = Color(0xFFFF9800);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
