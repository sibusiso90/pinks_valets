import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/time_of_day.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/primary_button.dart';
import '../domain/schedule.dart';
import 'booking_draft.dart';

class TimePickerScreen extends ConsumerStatefulWidget {
  const TimePickerScreen({super.key});

  @override
  ConsumerState<TimePickerScreen> createState() => _TimePickerScreenState();
}

class _TimePickerScreenState extends ConsumerState<TimePickerScreen> {
  late Future<_SlotData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SlotData> _load() async {
    final draft = ref.read(bookingDraftProvider);
    final settings = ref.read(systemSettingsProvider);
    final scheduleRepo = ref.read(scheduleRepositoryProvider);
    final bookingsRepo = ref.read(bookingRepositoryProvider);
    final calc = ref.read(slotCalculatorProvider);

    if (draft.date == null || draft.service == null) {
      return _SlotData(
        slots: const [],
        schedule: DailySchedule(
          date: DateTime.now(),
          isClosed: true,
          startTime: '00:00',
          endTime: '00:00',
          staffCount: 0,
          timeBlocks: const [],
        ),
      );
    }
    final schedule = await scheduleRepo.forDate(draft.date!);
    final existing = await bookingsRepo.listForDate(draft.date!);
    final slots = calc.calculateAvailableStartTimes(
      schedule: schedule,
      existingBookings: existing,
      serviceDurationMinutes: draft.service!.durationMinutes,
      travelBufferMinutes: settings.travelBufferMinutes,
      slotIncrementMinutes: settings.slotIncrementMinutes,
      minimumLeadHours: settings.minimumLeadHours,
    );
    return _SlotData(slots: slots, schedule: schedule);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final title = draft.date == null
        ? 'Pick a time'
        : DateFormat('EEE, d MMMM').format(draft.date!);

    return AppScaffold(
      title: title,
      back: () => context.pop(),
      body: FutureBuilder<_SlotData>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.ink,
                strokeWidth: 2.5,
              ),
            );
          }
          final data = snap.data!;
          if (data.slots.isEmpty) {
            return EmptyState(
              icon: Icons.schedule_rounded,
              title: 'Fully booked\non this day.',
              message: 'Our team is at capacity. Try a different day.',
              action: PrimaryButton(
                label: 'Pick another date',
                onPressed: () => context.pop(),
              ),
            );
          }
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              0,
              AppSpacing.screenH,
              0,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available start times',
                      style: AppText.display(30),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${draft.service?.name ?? ''} takes '
                      '${formatDurationShort(draft.service?.durationMinutes ?? 0)}. '
                      'Your team arrives at the time you pick.',
                      style: AppText.sans(
                        13,
                        color: AppColors.ink3,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              _buildGroup(
                'Morning',
                Icons.wb_sunny_outlined,
                _filter(data.slots, (h) => h < 12),
              ),
              _buildGroup(
                'Afternoon',
                Icons.light_mode_outlined,
                _filter(data.slots, (h) => h >= 12 && h < 16),
              ),
              _buildGroup(
                'Evening',
                Icons.nightlight_outlined,
                _filter(data.slots, (h) => h >= 16),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
      bottom: ActionBar(
        children: [
          PrimaryButton(
            label: draft.startTime == null
                ? 'Select a time'
                : 'Continue with ${draft.startTime}',
            full: true,
            size: BtnSize.lg,
            trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
            onPressed: draft.startTime == null
                ? null
                : () => context.push('/book/address'),
          ),
        ],
      ),
    );
  }

  List<String> _filter(List<String> slots, bool Function(int) where) {
    return slots.where((s) => where(int.parse(s.split(':')[0]))).toList();
  }

  Widget _buildGroup(String label, IconData icon, List<String> slots) {
    if (slots.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.ink2),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: AppText.sans(
                  11,
                  color: AppColors.ink2,
                  weight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Divider(color: AppColors.hair, height: 1),
              ),
              const SizedBox(width: 10),
              Text(
                '${slots.length}',
                style: AppText.sans(11, color: AppColors.ink3),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, _) {
              final selected = ref.watch(bookingDraftProvider).startTime;
              return GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: slots
                    .map((t) => _TimeSlotTile(
                          time: t,
                          selected: selected == t,
                          onTap: () {
                            Haptics.selection();
                            ref
                                .read(bookingDraftProvider.notifier)
                                .setStartTime(t);
                          },
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimeSlotTile extends StatelessWidget {
  const _TimeSlotTile({
    required this.time,
    required this.selected,
    required this.onTap,
  });

  final String time;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: selected ? AppColors.ink : AppColors.hair2,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: selected ? AppShadow.sm : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          splashColor: AppColors.accentSoft,
          highlightColor: Colors.transparent,
          child: Center(
            child: Text(
              time,
              style: AppText.tabular(
                14,
                color: selected ? AppColors.bg : AppColors.ink,
                weight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlotData {
  const _SlotData({required this.slots, required this.schedule});
  final List<String> slots;
  final DailySchedule schedule;
}
