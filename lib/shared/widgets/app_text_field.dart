import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// World-class text field — a single clean surface, hairline border, accent
/// focus ring, soft halo lift on focus.
///
/// Resting → white surface with a warm hairline.
/// Focused → accent ring, soft pink halo beneath.
/// Error   → danger ring, danger halo, inline error row.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.controller,
    this.initialValue,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.leading,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.maxLength,
    this.inputFormatters,
  });

  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final Widget? leading;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final int? maxLength;
  final List<dynamic>? inputFormatters;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focus;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()
      ..addListener(() {
        final f = _focus.hasFocus;
        if (f != _focused) setState(() => _focused = f);
      });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    final Color borderColor = hasError
        ? AppColors.danger
        : _focused
            ? AppColors.ink
            : AppColors.hair2;

    final List<BoxShadow>? halo = hasError
        ? const [
            BoxShadow(
              color: Color(0x1A9A2F2F),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ]
        : _focused
            ? const [
                BoxShadow(
                  color: Color(0x14140A0F),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
                BoxShadow(
                  color: Color(0x08140A0F),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ]
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              widget.label!,
              style: AppText.sans(
                13,
                weight: FontWeight.w600,
                color: AppColors.ink,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
        AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: borderColor,
              width: _focused || hasError ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: halo,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                IconTheme.merge(
                  data: IconThemeData(
                    color: _focused ? AppColors.ink : AppColors.ink3,
                    size: 18,
                  ),
                  child: widget.leading!,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  maxLength: widget.maxLength,
                  cursorColor: AppColors.ink,
                  cursorWidth: 1.6,
                  cursorRadius: const Radius.circular(2),
                  style: AppText.sans(
                    16,
                    color: AppColors.ink,
                    letterSpacing: -0.2,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: AppText.sans(
                      16,
                      color: AppColors.ink3,
                      letterSpacing: -0.2,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 18),
                    counterText: '',
                  ),
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: 8),
                widget.trailing!,
              ],
            ],
          ),
        ),
        AnimatedSize(
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          widget.errorText!,
                          style: AppText.sans(
                            12,
                            color: AppColors.danger,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : widget.helper != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
                      child: Text(
                        widget.helper!,
                        style: AppText.sans(12, color: AppColors.ink3),
                      ),
                    )
                  : const SizedBox.shrink(),
        ),
        const SizedBox(height: AppSpacing.xxs),
      ],
    );
  }
}
