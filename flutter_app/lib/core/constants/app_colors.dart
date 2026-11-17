import 'package:flutter/material.dart';

class AppColors {
  // Core Brand Hues
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color purple = Color(0xFFA855F7);

  // Status & Biometric Hues
  static const Color accentNeon = Color(0xFF10B981); // Emerald Green (Good Form & Success)
  static const Color accentEmerald = Color(0xFF059669);
  static const Color warningOrange = Color(0xFFF59E0B); // Amber Orange (Posture Warnings)
  static const Color streakOrange = Color(0xFFFB923C); // Energy Orange (Streaks)
  static const Color errorRed = Color(0xFFEF4444); // Crimson (Critical Form Flaw)

  // Luxury Navy Surfaces
  static const Color bgDark = Color(0xFF0B0F19); // Deep luxury navy background
  static const Color surfaceDark = Color(0xFF121A2D); // Base card surface
  static const Color surfaceCard = Color(0xFF18233C); // Elevated card
  static const Color surfaceElevated = Color(0xFF212E4C); // Modal/Floating surface
  static const Color borderDark = Color(0xFF263554); // Subtle glassmorphic border

  // Modern Typography Hues
  static const Color textPrimary = Color(0xFFF8FAFC); // High emphasis
  static const Color textSecondary = Color(0xFF94A3B8); // Medium emphasis
  static const Color textMuted = Color(0xFF64748B); // Low emphasis

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetPurpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient streakGradient = LinearGradient(
    colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    colors: [Color(0x331E293B), Color(0x1A0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
