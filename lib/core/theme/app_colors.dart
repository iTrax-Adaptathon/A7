import 'package:flutter/material.dart';

class AppColors {
  // Dark First Palette
  static const Color background = Color(0xFF0B0F19);
  static const Color surface = Color(0xFF151C2C);
  static const Color cardBg = Color(0xFF1B2437);
  static const Color cardBorder = Color(0xFF28344D);

  // Status & Decision Colors
  static const Color progress = Color(0xFF10B981); // 🟢 Emerald Neon
  static const Color maintain = Color(0xFFF59E0B); // 🟡 Amber Gold
  static const Color regress = Color(0xFFF43F5E); // 🔴 Rose Red
  static const Color recovery = Color(0xFF3B82F6); // 🔵 Electric Blue

  // Brand Accents
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF8B5CF6); // Violet
  static const Color accent = Color(0xFF06B6D4); // Cyan

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient maintainGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient regressGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
