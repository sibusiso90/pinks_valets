import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/time_of_day.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/badge.dart';
import '../../../shared/widgets/primary_button.dart';
import '../domain/service_type.dart';
import 'booking_draft.dart';

class ServiceSelectScreen extends ConsumerWidget {
  const ServiceSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider).asData?.value ?? [];
    final draft = ref.watch(bookingDraftProvider);
    final selected = draft.service;

    return AppScaffold(
      title: 'Services',
      large: true,
      subtitle: 'Choose what your car needs.',
      back: () => context.pop(),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          4,
          AppSpacing.screenH,
          24,
        ),
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final s = services[i];
          final isSelected = selected?.id == s.id;
          return _ServiceCard(
            service: s,
            selected: isSelected,
            featured: s.id == 'full-valet',
            onTap: () =>
                ref.read(bookingDraftProvider.notifier).setService(s),
          );
        },
      ),
      bottom: ActionBar(
        children: [
          PrimaryButton(
            label: selected == null
                ? 'Pick a service'
                : 'Continue with ${selected.name}',
            full: true,
            size: BtnSize.lg,
            trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
            onPressed:
                selected == null ? null : () => context.push('/book/date'),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.selected,
    required this.featured,
    required this.onTap,
  });

  final ServiceType service;
  final bool selected;
  final bool featured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double borderWidth = selected ? 2.0 : (featured ? 1.5 : 1);
    final Color borderColor = selected
        ? AppColors.accent
        : featured
            ? AppColors.ink
            : AppColors.hair;
    return AppCard(
      onTap: onTap,
      pad: 18,
      borderColor: borderColor,
      borderWidth: borderWidth,
      elevated: selected,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                      service.name,
                      style: AppText.display(22),
                    ),
                    if (featured && !selected)
                      const AppBadge('Most booked', tone: BadgeTone.dark),
                    if (selected)
                      const AppBadge('Selected', tone: BadgeTone.accent),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: AppText.sans(13, color: AppColors.ink2, height: 1.5),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: AppColors.ink3,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatDurationShort(service.durationMinutes),
                      style: AppText.sans(12, color: AppColors.ink3),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'FROM',
                style: AppText.eyebrow(size: 10),
              ),
              const SizedBox(height: 2),
              Text(
                formatRand(service.priceCents),
                style: AppText.tabular(28, weight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
