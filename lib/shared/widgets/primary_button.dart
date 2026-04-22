import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptics.dart';

enum BtnVariant { primary, accent, ghost, soft, danger, link }

enum BtnSize { md, lg, sm }

/// Pill-shaped button matching the Pink's design system.
///
/// The spec insists on pill buttons and consistent loading states —
/// this is the single source of truth. Any other button in the app is a
/// bug.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = BtnVariant.primary,
    this.size = BtnSize.md,
    this.full = false,
    this.leading,
    this.trailing,
    this.loading = false,
    this.glow = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final BtnVariant variant;
  final BtnSize size;
  final bool full;
  final Widget? leading;
  final Widget? trailing;
  final bool loading;

  /// Halo behind filled primary / accent buttons for hero CTAs.
  /// Auto-enabled when size is [BtnSize.lg] on coloured variants.
  final bool glow;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    final colours = _colours(widget.variant);

    final textSize = widget.size == BtnSize.lg
        ? 16.0
        : widget.size == BtnSize.sm
            ? 13.0
            : 15.0;

    final content = widget.loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation(colours.fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leading != null) ...[
                IconTheme.merge(
                  data: IconThemeData(color: colours.fg, size: 16),
                  child: widget.leading!,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: AppText.sans(
                    textSize,
                    weight: FontWeight.w600,
                    color: colours.fg,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: 8),
                IconTheme.merge(
                  data: IconThemeData(color: colours.fg, size: 16),
                  child: widget.trailing!,
                ),
              ],
            ],
          );

    final padding = EdgeInsets.symmetric(
      horizontal: widget.size == BtnSize.lg
          ? 22
          : widget.size == BtnSize.sm
              ? 14
              : 20,
      vertical: widget.size == BtnSize.lg
          ? 17
          : widget.size == BtnSize.sm
              ? 8
              : 13,
    );

    // Filled variants get a subtle shadow for lift; ghost/link stay flat.
    final filled = widget.variant == BtnVariant.primary ||
        widget.variant == BtnVariant.accent ||
        widget.variant == BtnVariant.danger;
    final showGlow = (widget.glow ||
            (widget.size == BtnSize.lg && filled)) &&
        !disabled;

    final shadows = <BoxShadow>[
      if (filled && !disabled) ...AppShadow.sm,
      if (showGlow && widget.variant == BtnVariant.accent)
        ...AppShadow.accentGlow,
    ];

    final child = AnimatedScale(
      scale: _pressed && !disabled ? 0.97 : 1.0,
      duration: AppMotion.instant,
      curve: AppMotion.spring,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colours.bg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: colours.border != null
              ? Border.all(color: colours.border!, width: 1)
              : null,
          boxShadow: shadows,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const StadiumBorder(),
          child: InkWell(
            onTap: disabled
                ? null
                : () {
                    Haptics.light();
                    widget.onPressed?.call();
                  },
            onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
            onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
            onTapCancel: disabled ? null : () => setState(() => _pressed = false),
            customBorder: const StadiumBorder(),
            splashColor: widget.variant == BtnVariant.accent
                ? Colors.white.withValues(alpha: 0.18)
                : AppColors.accentSoft,
            highlightColor: Colors.transparent,
            child: Padding(padding: padding, child: Center(child: content)),
          ),
        ),
      ),
    );

    return AnimatedOpacity(
      duration: AppMotion.fast,
      opacity: disabled && !widget.loading ? 0.4 : 1,
      child: widget.full ? SizedBox(width: double.infinity, child: child) : child,
    );
  }

  _ButtonColours _colours(BtnVariant v) {
    switch (v) {
      case BtnVariant.primary:
        return const _ButtonColours(bg: AppColors.ink, fg: AppColors.bg);
      case BtnVariant.accent:
        return const _ButtonColours(
          bg: AppColors.accent,
          fg: AppColors.accentInk,
        );
      case BtnVariant.ghost:
        return const _ButtonColours(
          bg: Colors.transparent,
          fg: AppColors.ink,
          border: AppColors.hair2,
        );
      case BtnVariant.soft:
        return const _ButtonColours(
          bg: AppColors.surfaceAlt,
          fg: AppColors.ink,
        );
      case BtnVariant.danger:
        return const _ButtonColours(bg: AppColors.danger, fg: Colors.white);
      case BtnVariant.link:
        return const _ButtonColours(
          bg: Colors.transparent,
          fg: AppColors.accent,
        );
    }
  }
}

class _ButtonColours {
  const _ButtonColours({required this.bg, required this.fg, this.border});
  final Color bg;
  final Color fg;
  final Color? border;
}

/// Small, muted text link used in non-hero CTAs ("Forgot password?", etc.).
class AppLinkButton extends StatelessWidget {
  const AppLinkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed == null
          ? null
          : () {
              Haptics.selection();
              onPressed!();
            },
      style: TextButton.styleFrom(
        foregroundColor: destructive ? AppColors.danger : AppColors.accent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: AppText.sans(13,
            weight: FontWeight.w600,
            color: destructive ? AppColors.danger : AppColors.accent),
      ),
    );
  }
}
