import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/sparkle.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_Notif>[
      const _Notif(
        title: 'Booking confirmed',
        sub: 'Full Valet · tomorrow, 10:30',
        time: '2m',
        tone: _Tone.accent,
        unread: true,
        group: 'Today',
      ),
      const _Notif(
        title: 'Receipt',
        sub: 'R350 paid — Visa ending 4242',
        time: '2m',
        tone: _Tone.neutral,
        unread: true,
        group: 'Today',
      ),
      const _Notif(
        title: 'Reminder',
        sub: 'Your wash is tomorrow at 10:30.',
        time: 'Yesterday',
        tone: _Tone.neutral,
        group: 'Earlier',
      ),
      const _Notif(
        title: 'Team on the way',
        sub: 'Sipho & Musa — arriving in 20 min.',
        time: '2d',
        tone: _Tone.success,
        group: 'Earlier',
      ),
      const _Notif(
        title: 'Cancelled',
        sub: 'Sun 3 Mar · Refund processed',
        time: '5w',
        tone: _Tone.danger,
        group: 'Earlier',
      ),
    ];

    // Group by the 'group' field, preserving order.
    final groups = <String, List<_Notif>>{};
    for (final n in items) {
      groups.putIfAbsent(n.group, () => []).add(n);
    }

    return AppScaffold(
      title: 'Notifications',
      large: true,
      back: () => context.pop(),
      trailing: AppLinkButton(label: 'Mark all read', onPressed: () {}),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          0,
          AppSpacing.screenH,
          24,
        ),
        children: [
          for (final entry in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 0, 12),
              child: Text(
                entry.key.toUpperCase(),
                style: AppText.eyebrow(size: 11),
              ),
            ),
            for (var i = 0; i < entry.value.length; i++) ...[
              _NotifRow(n: entry.value[i]),
              if (i < entry.value.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Divider(color: AppColors.hair, height: 1),
                ),
            ],
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

enum _Tone { accent, neutral, success, danger }

class _Notif {
  const _Notif({
    required this.title,
    required this.sub,
    required this.time,
    required this.tone,
    required this.group,
    this.unread = false,
  });
  final String title;
  final String sub;
  final String time;
  final _Tone tone;
  final String group;
  final bool unread;
}

class _NotifRow extends StatelessWidget {
  const _NotifRow({required this.n});
  final _Notif n;

  @override
  Widget build(BuildContext context) {
    final (bg, iconColor, icon) = _visuals();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: icon is Widget
                ? icon
                : Icon(icon as IconData, size: 16, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        n.title,
                        style: AppText.sans(14, weight: FontWeight.w700),
                      ),
                    ),
                    if (n.unread) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      n.time,
                      style: AppText.sans(11, color: AppColors.ink3),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  n.sub,
                  style: AppText.sans(13, color: AppColors.ink2, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, dynamic) _visuals() {
    switch (n.tone) {
      case _Tone.accent:
        return (
          AppColors.accentSoft,
          AppColors.accent,
          const Sparkle(size: 16, color: AppColors.accent),
        );
      case _Tone.success:
        return (
          AppColors.successSoft,
          AppColors.success,
          Icons.directions_car_filled_rounded,
        );
      case _Tone.danger:
        return (
          AppColors.dangerSoft,
          AppColors.danger,
          Icons.close_rounded,
        );
      case _Tone.neutral:
        return (
          AppColors.surfaceAlt,
          AppColors.ink2,
          Icons.notifications_outlined,
        );
    }
  }
}
