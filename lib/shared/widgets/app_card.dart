import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/haptics.dart';

/// Soft surface with hairline + optional subtle elevation.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.pad = AppSpacing.md,
    this.onTap,
    this.borderColor,
    this.borderWidth,
    this.backgroundColor,
    this.elevated = false,
    this.radius = AppRadius.lg,
  });

  final Widget child;
  final double pad;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double? borderWidth;
  final Color? backgroundColor;

  /// When true, adds a gentle warm drop shadow for floating cards
  /// (hero cards, detail bills, etc.). Default cards stay flat — we rely
  /// on hairlines to do the separating.
  final bool elevated;

  /// Corner radius. Most cards use [AppRadius.lg]; hero cards use [AppRadius.xl].
  final double radius;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: widget.borderColor ?? AppColors.hair,
          width: widget.borderWidth ?? 1,
        ),
        boxShadow: widget.elevated ? AppShadow.md : null,
      ),
      child: Padding(padding: EdgeInsets.all(widget.pad), child: widget.child),
    );

    if (widget.onTap == null) return content;

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: AppMotion.instant,
      curve: AppMotion.spring,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(widget.radius),
        child: InkWell(
          onTap: () {
            Haptics.selection();
            widget.onTap!();
          },
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          borderRadius: BorderRadius.circular(widget.radius),
          splashColor: AppColors.accentSoft,
          highlightColor: Colors.transparent,
          child: content,
        ),
      ),
    );
  }
}
