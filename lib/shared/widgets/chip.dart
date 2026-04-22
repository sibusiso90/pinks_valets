import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptics.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
    this.accent = false,
    this.leading,
  });

  final String label;
  final bool active;
  final bool accent;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color border;
    if (active) {
      if (accent) {
        bg = AppColors.accent;
        fg = AppColors.accentInk;
        border = AppColors.accent;
      } else {
        bg = AppColors.ink;
        fg = AppColors.bg;
        border = AppColors.ink;
      }
    } else {
      bg = AppColors.surface;
      fg = AppColors.ink;
      border = AppColors.hair2;
    }

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: border)),
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  Haptics.selection();
                  onTap!();
                },
          customBorder: const StadiumBorder(),
          splashColor: AppColors.accentSoft,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(color: fg, size: 14),
                    child: leading!,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: AppText.sans(13, weight: FontWeight.w600, color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
