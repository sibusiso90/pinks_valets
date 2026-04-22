import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptics.dart';

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.active,
    required this.onChanged,
    required this.segments,
  });

  final String active;
  final ValueChanged<String> onChanged;
  final List<SegmentedTab> segments;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: segments.map((seg) {
            final on = seg.id == active;
            return AnimatedContainer(
              duration: AppMotion.medium,
              curve: AppMotion.standard,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: on ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: on ? AppShadow.sm : null,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: InkWell(
                  onTap: on
                      ? null
                      : () {
                          Haptics.selection();
                          onChanged(seg.id);
                        },
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  splashColor: AppColors.accentSoft,
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 9,
                    ),
                    child: Text(
                      seg.label,
                      style: AppText.sans(
                        13,
                        weight: FontWeight.w600,
                        color: on ? AppColors.ink : AppColors.ink2,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class SegmentedTab {
  const SegmentedTab(this.id, this.label);
  final String id;
  final String label;
}
