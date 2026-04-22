import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum BadgeTone { neutral, accent, success, warn, danger, dark }

class AppBadge extends StatelessWidget {
  const AppBadge(this.label, {super.key, this.tone = BadgeTone.neutral});

  final String label;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colours(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppText.sans(
          11,
          weight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  (Color, Color) _colours(BadgeTone t) {
    switch (t) {
      case BadgeTone.accent:
        return (AppColors.accentSoft, AppColors.accent);
      case BadgeTone.success:
        return (AppColors.successSoft, AppColors.success);
      case BadgeTone.warn:
        return (AppColors.warnSoft, AppColors.warn);
      case BadgeTone.danger:
        return (AppColors.dangerSoft, AppColors.danger);
      case BadgeTone.dark:
        return (AppColors.ink, AppColors.bg);
      case BadgeTone.neutral:
        return (AppColors.surfaceAlt, AppColors.ink2);
    }
  }
}
