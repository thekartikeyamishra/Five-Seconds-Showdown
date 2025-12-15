// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Purple Dream)
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  
  // Secondary Colors (Energy Pink)
  static const Color secondary = Color(0xFFEC4899);
  static const Color secondaryDark = Color(0xFFDB2777);
  static const Color secondaryLight = Color(0xFFF9A8D4);
  
  // Accent Colors (Sunset Orange)
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentDark = Color(0xFFFF4500);
  static const Color accentLight = Color(0xFFFF8C69);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Background Colors
  static const Color background = Color(0xFF0F172A);
  static const Color backgroundLight = Color(0xFF1E293B);
  static const Color surface = Color(0xFF1E293B);
  static const Color card = Color(0xFF334155);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF64748B);
  
  // Border & Divider
  static const Color border = Color(0xFF334155);
  static const Color divider = Color(0xFF475569);
  
  // Gradients
  static const List<Color> gradientPurple = [
    Color(0xFF8B5CF6),
    Color(0xFF7C3AED),
    Color(0xFF6D28D9),
  ];
  
  static const List<Color> gradientPink = [
    Color(0xFFEC4899),
    Color(0xFFDB2777),
    Color(0xFFBE185D),
  ];
  
  static const List<Color> gradientSunset = [
    Color(0xFFF59E0B),
    Color(0xFFF97316),
    Color(0xFFEF4444),
  ];
  
  static const List<Color> gradientOcean = [
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
  ];
  
  static const List<Color> gradientForest = [
    Color(0xFF10B981),
    Color(0xFF059669),
    Color(0xFF047857),
  ];
  
  static const List<Color> gradientFire = [
    Color(0xFFFCD34D),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
  ];
  
  // Timer Colors
  static const Color timerSafe = Color(0xFF10B981);
  static const Color timerWarning = Color(0xFFF59E0B);
  static const Color timerDanger = Color(0xFFEF4444);
  
  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  
  // Shimmer Colors
  static const Color shimmerBase = Color(0xFF1E293B);
  static const Color shimmerHighlight = Color(0xFF334155);
}