import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptics.dart';

/// Bottom nav. Four destinations — Home, Bookings, Chat, Profile.
///
/// The active destination sits inside a soft ivory pill so the state is
/// immediately legible without colour shouting at the user.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.active,
    required this.onTap,
  });

  final String active;
  final ValueChanged<String> onTap;

  static const _items = [
    _NavItem('home', 'Home', Icons.home_rounded, Icons.home_outlined),
    _NavItem('bookings', 'Bookings', Icons.event_rounded,
        Icons.event_outlined),
    _NavItem('chat', 'Chat', Icons.chat_bubble_rounded,
        Icons.chat_bubble_outline_rounded),
    _NavItem('profile', 'Profile', Icons.person_rounded,
        Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hair, width: 1)),
        boxShadow: AppShadow.bar,
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
          child: Row(
            children: _items.map((it) {
              final on = it.id == active;
              return Expanded(
                child: _NavButton(
                  item: it,
                  active: on,
                  onTap: () {
                    if (on) return;
                    Haptics.selection();
                    onTap(it.id);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        splashColor: AppColors.accentSoft,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: AppMotion.medium,
          curve: AppMotion.standard,
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: active ? AppColors.surfaceAlt : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: AppMotion.fast,
                transitionBuilder: (w, a) =>
                    ScaleTransition(scale: a, child: w),
                child: Icon(
                  active ? item.iconActive : item.icon,
                  key: ValueKey('${item.id}-$active'),
                  size: 22,
                  color: active ? AppColors.ink : AppColors.ink3,
                ),
              ),
              AnimatedSize(
                duration: AppMotion.medium,
                curve: AppMotion.emphasized,
                child: active
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          item.label,
                          style: AppText.sans(
                            12,
                            weight: FontWeight.w600,
                            color: AppColors.ink,
                            letterSpacing: -0.1,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.id, this.label, this.iconActive, this.icon);
  final String id;
  final String label;
  final IconData icon;
  final IconData iconActive;
}
