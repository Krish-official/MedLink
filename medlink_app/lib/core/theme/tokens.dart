import 'package:flutter/material.dart';

/// Design tokens — single source of truth for all visual values
class AppTokens {
  AppTokens._();

  // ════════════════════════════════════════════
  // SPACING (4px base grid)
  // ════════════════════════════════════════════
  static const double space0 = 0;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  // ════════════════════════════════════════════
  // BORDER RADIUS
  // ════════════════════════════════════════════
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 9999;

  // ════════════════════════════════════════════
  // ELEVATION (shadows)
  // ════════════════════════════════════════════
  static const double elevationNone = 0;
  static const double elevationSm = 2;
  static const double elevationMd = 4;
  static const double elevationLg = 8;
  static const double elevationXl = 16;

  // ════════════════════════════════════════════
  // ICON SIZES
  // ════════════════════════════════════════════
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  // ════════════════════════════════════════════
  // BREAKPOINTS (for responsive)
  // ════════════════════════════════════════════
  static const double breakpointMobile = 480;
  static const double breakpointTablet = 768;
  static const double breakpointDesktop = 1024;

  // ════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ════════════════════════════════════════════
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
}