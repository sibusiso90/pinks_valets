import 'package:flutter/material.dart';

/// Pink's Vehicle Valets brand palette — "Pink on Ivory" direction.
///
/// - Ink (near-black, slight warm violet) for primary text and buttons
/// - Pink (#D81B84) as the accent — the logo's magenta
/// - Ivory as the background — warm, not sterile
///
/// All colour references across the app MUST come from this class.
/// No hard-coded colour values in widgets.
class AppColors {
  AppColors._();

  // Surfaces
  static const Color bg = Color(0xFFFAF6F3);        // warm ivory
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF2EBE6);

  // Ink (text / primary buttons)
  static const Color ink = Color(0xFF140A0F);
  static const Color ink2 = Color(0xFF4A3E44);
  static const Color ink3 = Color(0xFF8F8289);

  // Hairlines
  static const Color hair = Color(0xFFECE3DE);
  static const Color hair2 = Color(0xFFD9CEC7);

  // Accent — Pink's magenta
  static const Color accent = Color(0xFFD81B84);
  static const Color accentInk = Color(0xFFFFFFFF);
  static const Color accentSoft = Color(0xFFFBE0EE);

  // Status
  static const Color success = Color(0xFF2F7A4D);
  static const Color warn = Color(0xFFB5811E);
  static const Color danger = Color(0xFF9A2F2F);
  static const Color successSoft = Color(0xFFE3EFE7);
  static const Color warnSoft = Color(0xFFF6ECD4);
  static const Color dangerSoft = Color(0xFFF4DEDE);

  // Dark surfaces (splash, hero)
  static const Color dark = Color(0xFF140A0F);
  static const Color darkInk = Color(0xFFFAF6F3);
  static const Color darkHair = Color(0xFF2A1A22);
}
