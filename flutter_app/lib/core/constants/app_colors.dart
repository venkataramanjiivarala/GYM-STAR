import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6366F1); // Indigo Primary
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color accentNeon = Color(0xFF10B981); // Neon Emerald Good Form
  static const Color warningOrange = Color(0xFFF59E0B); // Amber Warning
  static const Color errorRed = Color(0xFFEF4444); // Crimson Error
  
  static const Color bgDark = Color(0xFF0F172A); // Deep Slate Background
  static const Color surfaceDark = Color(0xFF1E293B); // Card Surface
  static const Color surfaceCard = Color(0xFF334155);
  
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
