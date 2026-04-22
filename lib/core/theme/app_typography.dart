import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography for Pink's:
/// - Display: Instrument Serif (editorial, used sparingly for hero headlines
///   and confirmation moments like "Booked. See you Wednesday.")
/// - Sans: Inter Tight (body + UI)
///
/// Instrument Serif is light and benefits from slightly negative letter spacing
/// at large sizes; we also opt into tabular nums for Rand amounts.
class AppText {
  AppText._();

  // Display — editorial headlines
  static TextStyle display(double size, {Color? color, bool italic = false}) {
    return GoogleFonts.instrumentSerif(
      fontSize: size,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: 1.05,
      letterSpacing: size >= 28 ? -0.8 : -0.3,
      color: color ?? AppColors.ink,
    );
  }

  // Sans — body and UI
  static TextStyle sans(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w500,
    double? height,
    double letterSpacing = -0.2,
  }) {
    return GoogleFonts.interTight(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.ink,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Tabular — numbers that should align (Rand amounts, time slots)
  static TextStyle tabular(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.interTight(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.ink,
      letterSpacing: -0.1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // Eyebrow — the uppercase tracked mini-labels
  static TextStyle eyebrow({Color? color, double size = 11}) {
    return GoogleFonts.interTight(
      fontSize: size,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
      color: color ?? AppColors.ink3,
    );
  }
}
