import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import 'sparkle.dart';

/// The Pink's wordmark.
///
/// Rendered as a composition rather than a PNG so it stays crisp at any size
/// and recolours cleanly for dark backgrounds. The handwritten "Pink's" uses
/// a script font (Dancing Script from Google Fonts) which captures the brand's
/// friendly, nostalgic feel. Under it sits "VEHICLE VALETS" in a tight
/// uppercase sans — just like the real logo.
class PinksLogo extends StatelessWidget {
  const PinksLogo({
    super.key,
    this.height = 28,
    this.color,
    this.showTagline = true,
  });

  final double height;
  final Color? color;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    final nameSize = height * 0.9;
    final tagSize = height * 0.25;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Text(
              "Pink's",
              style: GoogleFonts.dancingScript(
                fontSize: nameSize,
                fontWeight: FontWeight.w700,
                color: c,
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
            Positioned(
              top: -height * 0.08,
              right: -height * 0.10,
              child: Sparkle(size: height * 0.35, color: c),
            ),
          ],
        ),
        if (showTagline) ...[
          SizedBox(height: height * 0.04),
          Text(
            'VEHICLE VALETS',
            style: TextStyle(
              fontSize: tagSize,
              color: c,
              fontWeight: FontWeight.w900,
              letterSpacing: tagSize * 0.18,
              fontFamily: GoogleFonts.interTight().fontFamily,
            ),
          ),
        ],
      ],
    );
  }
}
