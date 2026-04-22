import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The 4-point starburst from the Pink's logo — reusable brand moment for
/// notification dots, confirmation screens, empty states and anywhere we want
/// a tiny flash of Pink.
class Sparkle extends StatelessWidget {
  const Sparkle({super.key, this.size = 14, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color ?? AppColors.accent),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final halfR = r * 0.28;
    final path = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx + halfR, cy - halfR)
      ..lineTo(size.width, cy)
      ..lineTo(cx + halfR, cy + halfR)
      ..lineTo(cx, size.height)
      ..lineTo(cx - halfR, cy + halfR)
      ..lineTo(0, cy)
      ..lineTo(cx - halfR, cy - halfR)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.color != color;
}
