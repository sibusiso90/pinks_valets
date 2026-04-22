import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptics.dart';

/// Unified scaffold. Screens pass the title, an optional leading/trailing,
/// whether to show the large editorial title, and the body.
///
/// The app bar softly fades in a hairline divider once the body scrolls
/// beneath it — an understated cue that sells the premium feel.
class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.large = false,
    this.subtitle,
    this.back,
    this.trailing,
    required this.body,
    this.bottom,
    this.bg,
    this.safe = true,
    this.scrollController,
  });

  final String? title;
  final bool large;
  final String? subtitle;
  final VoidCallback? back;
  final Widget? trailing;
  final Widget body;
  final Widget? bottom;
  final Color? bg;
  final bool safe;

  /// Optional external scroll controller. If not provided, we still sense
  /// scrolling via [NotificationListener].
  final ScrollController? scrollController;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _scrolled = false;

  bool _onScroll(ScrollNotification n) {
    final shouldShow = n.metrics.pixels > 2;
    if (shouldShow != _scrolled) {
      setState(() => _scrolled = shouldShow);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final hasBar = widget.title != null ||
        widget.back != null ||
        widget.trailing != null;

    // Top content sits inside the safe area so the app bar doesn't duck
    // under the status bar / notch. The bottom action bar handles its own
    // safe-area padding so the bar surface extends flush to the bottom
    // edge of the device.
    final top = Column(
      children: [
        if (hasBar)
          _AppBar(
            title: widget.title,
            large: widget.large,
            subtitle: widget.subtitle,
            back: widget.back,
            trailing: widget.trailing,
            showDivider: _scrolled,
          ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: widget.body,
          ),
        ),
      ],
    );

    final body = Column(
      children: [
        Expanded(
          child:
              widget.safe ? SafeArea(bottom: false, child: top) : top,
        ),
        if (widget.bottom != null) widget.bottom!,
      ],
    );

    return Scaffold(
      backgroundColor: widget.bg ?? AppColors.bg,
      body: body,
      resizeToAvoidBottomInset: true,
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.title,
    required this.large,
    required this.subtitle,
    required this.back,
    required this.trailing,
    required this.showDivider,
  });

  final String? title;
  final bool large;
  final String? subtitle;
  final VoidCallback? back;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border(
          bottom: BorderSide(
            color: showDivider && !large ? AppColors.hair : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        large ? AppSpacing.screenH : 8,
        8,
        large ? AppSpacing.screenH : 8,
        large ? 0 : 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              children: [
                if (back != null)
                  _IconBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: back)
                else
                  const SizedBox(width: 44),
                Expanded(
                  child: large
                      ? const SizedBox()
                      : Center(
                          child: Text(
                            title ?? '',
                            style: AppText.sans(
                              16,
                              weight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ),
                if (trailing != null)
                  trailing!
                else
                  const SizedBox(width: 44),
              ],
            ),
          ),
          if (large && title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 6, 4, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: AppText.display(40),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: AppText.sans(14, color: AppColors.ink3, height: 1.45),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                Haptics.selection();
                onTap!();
              },
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 20, color: AppColors.ink),
        ),
      ),
    );
  }
}

/// Bottom action bar used by multi-step flows for primary CTAs.
/// Sits flush against the bottom edge of the device — the surface extends
/// behind the home indicator / nav bar, while content inside keeps clear
/// of system UI via [SafeArea].
class ActionBar extends StatelessWidget {
  const ActionBar({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hair, width: 1)),
        boxShadow: AppShadow.bar,
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            14,
            AppSpacing.screenH,
            8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
