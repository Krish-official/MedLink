import 'package:flutter/material.dart';

class AccessibilityUtils {
  AccessibilityUtils._();

  /// Minimum touch target size as per accessibility guidelines
  static const double minTouchTarget = 48.0;

  /// Check if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Announce to screen reader
  static void announce(BuildContext context, String message) {
    if (isScreenReaderEnabled(context)) {
      // Announce via Semantics
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }

  /// Wrap widget with minimum touch target
  static Widget ensureTouchTarget({
    required Widget child,
    double minSize = minTouchTarget,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }
}

/// Extension for contrast ratio checking
extension ColorContrastX on Color {
  /// Calculate relative luminance
  double get relativeLuminance {
    final r = red / 255;
    final g = green / 255;
    final b = blue / 255;

    final rLum = r <= 0.03928 ? r / 12.92 : ((r + 0.055) / 1.055).pow(2.4);
    final gLum = g <= 0.03928 ? g / 12.92 : ((g + 0.055) / 1.055).pow(2.4);
    final bLum = b <= 0.03928 ? b / 12.92 : ((b + 0.055) / 1.055).pow(2.4);

    return 0.2126 * rLum + 0.7152 * gLum + 0.0722 * bLum;
  }

  /// Calculate contrast ratio with another color
  double contrastRatio(Color other) {
    final l1 = relativeLuminance;
    final l2 = other.relativeLuminance;

    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if meets WCAG AA standard (4.5:1 for normal text)
  bool meetsWCAGAA(Color background) {
    return contrastRatio(background) >= 4.5;
  }

  /// Check if meets WCAG AAA standard (7:1 for normal text)
  bool meetsWCAGAAA(Color background) {
    return contrastRatio(background) >= 7.0;
  }
}

extension on num {
  num pow(num exponent) {
    return this * exponent;
  }
}