import 'package:flutter/material.dart';

/// Color system — semantic & brand colors
class AppColors {
  AppColors._();

  // ════════════════════════════════════════════
  // BRAND COLORS
  // ════════════════════════════════════════════
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryDark = Color(0xFF0052CC);
  static const Color primaryLight = Color(0xFF3385FF);
  
  static const Color accent = Color(0xFF10B981);
  static const Color accentDark = Color(0xFF059669);
  static const Color accentLight = Color(0xFF34D399);

  // ════════════════════════════════════════════
  // NEUTRAL SCALE (Gray)
  // ════════════════════════════════════════════
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // ════════════════════════════════════════════
  // SEMANTIC COLORS (status, feedback)
  // ════════════════════════════════════════════
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E40AF);

  // ════════════════════════════════════════════
  // SURFACE COLORS
  // ════════════════════════════════════════════
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF9FAFB);

  // ════════════════════════════════════════════
  // TEXT COLORS
  // ════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  // ════════════════════════════════════════════
  // BORDER COLORS
  // ════════════════════════════════════════════
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFFD1D5DB);
  static const Color borderLight = Color(0xFFF3F4F6);

  // ════════════════════════════════════════════
  // ROLE-SPECIFIC (optional accent colors per role)
  // ════════════════════════════════════════════
  static const Color patient = Color(0xFF0066FF);
  static const Color doctor = Color(0xFF10B981);
  static const Color admin = Color(0xFF8B5CF6);
}