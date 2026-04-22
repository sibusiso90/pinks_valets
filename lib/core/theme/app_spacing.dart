import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Spacing, radius, and sizing tokens.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Screen padding — single source of truth for horizontal/vertical gutters.
  static const double screenH = 20;
  static const double screenV = 16;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double pill = 999;
}

class AppIconSize {
  AppIconSize._();

  static const double xs = 14;
  static const double sm = 16;
  static const double md = 18;
  static const double lg = 20;
  static const double xl = 24;
}

/// Elevation tokens — subtle, warm shadows that match the ivory surface.
/// These are intentionally softer than Material defaults so the UI feels
/// editorial rather than app-y.
class AppShadow {
  AppShadow._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A140A0F),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F140A0F),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x08140A0F),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x14140A0F),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x0A140A0F),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Used above floating action bars when content scrolls beneath.
  static const List<BoxShadow> bar = [
    BoxShadow(
      color: Color(0x14140A0F),
      blurRadius: 24,
      offset: Offset(0, -6),
    ),
  ];

  /// Pink accent halo on selected / hero CTAs.
  static List<BoxShadow> accentGlow = const [
    BoxShadow(
      color: Color(0x33D81B84),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}

/// Motion tokens — shared durations / curves for a consistent feel.
class AppMotion {
  AppMotion._();

  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);

  /// iOS-like spring — premium and soft.
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve spring = Cubic(0.34, 1.56, 0.64, 1.0);
}

/// The single gradient reused for ink-surface heroes (upcoming booking card,
/// profile identity card). Sits quietly — almost invisible — but gives the
/// surface a living quality rather than flat black.
const LinearGradient kInkHeroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1C0E14), Color(0xFF140A0F), Color(0xFF0F080C)],
  stops: [0.0, 0.55, 1.0],
);

/// The dark splash/welcome gradient — accent glow blooms from the corner.
const RadialGradient kDarkHeroGradient = RadialGradient(
  center: Alignment(-0.5, -0.8),
  radius: 1.4,
  colors: [Color(0xFF2A1420), AppColors.dark],
  stops: [0.0, 0.75],
);
