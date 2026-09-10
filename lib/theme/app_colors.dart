import 'package:flutter/material.dart';

class AppColors {
  // Main Background
  static const Color background = Color(0xFFD9E2F7);

  // Primary Text & Icons
  static const Color textPrimary = Color(0xFF0A1020);

  // Secondary & Muted Text
  static const Color textSecondary = Color(0xFF73809C);

  // Glass Container Fill
  static Color glassBackground = Colors.white.withValues(alpha: 0.40);
  static Color glassBackgroundDarker = Colors.white.withValues(alpha: 0.25);
  static Color glassBackgroundLighter = Colors.white.withValues(alpha: 0.55);

  // Glass Border
  static Color glassBorder = Colors.white.withValues(alpha: 0.65);
  static Color glassBorderSubtle = Colors.white.withValues(alpha: 0.40);

  // Accent Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF5B46F6),
      Color(0xFF8E37F5),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient navBarGradient = LinearGradient(
    colors: [
      Color(0xD0E5CCFF),
      Color(0xD0D9EDFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroOverlayGradient = LinearGradient(
    colors: [
      Colors.black87,
      Colors.transparent,
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
}
