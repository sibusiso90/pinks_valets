import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/time_of_day.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import 'booking_draft.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(bookingDraftProvider);
    final service = draft.service!;
    final startMinutes =
        parseMinutes(draft.startTime ?? '10:30') + service.durationMinutes;
    final endTime = formatMinutes(startMinutes);
    final df = DateFormat('EEE, d MMMM');

    return AppScaffold(
      title: 'Review',
      back: () => context.pop(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH + 4,
          0,
          AppSpacing.screenH + 4,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Almost there.', style: AppText.display(32)),
            const SizedBox(height: 6),
            Text(
              'Check the details and confirm.',
              style: AppText.sans(13, color: AppColors.ink3),
            ),
            const SizedBox(height: 20),
            AppCard(
              pad: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('SERVICE', style: AppText.eyebrow(size: 11)),
                      const Spacer(),
                      _ChangeButton(
                        onTap: () => context.go('/book/service'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(service.name, style: AppText.display(22)),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDurationShort(service.durationMinutes)} · ${service.description}',
                    style: AppText.sans(
                      13,
                      color: AppColors.ink3,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              pad: 0,
              child: Column(
                children: [
                  _Row(
                    icon: Icons.schedule_outlined,
                    label: 'WHEN',
                    value: df.format(draft.date!),
                    sub: '${draft.startTime} — $endTime',
                  ),
                  const Divider(height: 1, color: AppColors.hair),
                  _Row(
                    icon: Icons.place_outlined,
                    label: 'WHERE',
                    value: draft.address!.label,
                    sub: draft.address!.oneLine,
                  ),
                  const Divider(height: 1, color: AppColors.hair),
                  _Row(
                    icon: Icons.directions_car_filled_outlined,
                    label: 'VEHICLE',
                    value: 'BMW 320i',
                    sub: 'Mineral White · AB 12 CD GP',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              pad: 20,
              elevated: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PRICE', style: AppText.eyebrow(size: 11)),
                  const SizedBox(height: 12),
                  _Line(label: service.name, cents: service.priceCents),
                  const _Line(
                    label: 'Travel',
                    cents: 0,
                    sub: 'Included in Sandton',
                  ),
                  const Divider(height: 22, color: AppColors.hair),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: AppText.sans(15, weight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text(
                        formatRand(service.priceCents),
                        style: AppText.tabular(30, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: ActionBar(
        children: [
          PrimaryButton(
            label: 'Pay ${formatRand(service.priceCents)}',
            full: true,
            size: BtnSize.lg,
            trailing: const Icon(Icons.lock_rounded, size: 14),
            onPressed: () {
              Haptics.medium();
              context.push('/book/payment');
            },
          ),
        ],
      ),
    );
  }
}

class _ChangeButton extends StatelessWidget {
  const _ChangeButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: () {
          Haptics.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(
            'Change',
            style: AppText.sans(
              12,
              weight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });
  final IconData icon;
  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.ink, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.eyebrow(size: 11)),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: AppText.sans(15, weight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  sub,
                  style: AppText.sans(12, color: AppColors.ink3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.cents, this.sub});
  final String label;
  final int cents;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppText.sans(14, color: AppColors.ink2),
                ),
                if (sub != null)
                  Text(
                    sub!,
                    style: AppText.sans(11, color: AppColors.ink3),
                  ),
              ],
            ),
          ),
          Text(
            formatRand(cents),
            style: AppText.tabular(16, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
