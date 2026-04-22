import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import 'booking_draft.dart';

class DatePickerScreen extends ConsumerStatefulWidget {
  const DatePickerScreen({super.key});

  @override
  ConsumerState<DatePickerScreen> createState() => _DatePickerScreenState();
}

class _DatePickerScreenState extends ConsumerState<DatePickerScreen> {
  late DateTime _cursor;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _cursor = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final settings = ref.watch(systemSettingsProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = today.add(Duration(days: settings.bookingWindowDays));
    final selected = draft.date;

    return AppScaffold(
      title: 'Pick a date',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('When suits?', style: AppText.display(34)),
            const SizedBox(height: 8),
            Text(
              'Select any day — we work weekends. Sundays closed.',
              style: AppText.sans(13, color: AppColors.ink3, height: 1.45),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                _MonthBtn(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () {
                    Haptics.selection();
                    setState(() {
                      _cursor = DateTime(_cursor.year, _cursor.month - 1);
                    });
                  },
                ),
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: AppMotion.fast,
                      transitionBuilder: (w, a) => FadeTransition(
                        opacity: a,
                        child: w,
                      ),
                      child: Text(
                        DateFormat('MMMM y').format(_cursor),
                        key: ValueKey('${_cursor.year}-${_cursor.month}'),
                        style: AppText.display(22),
                      ),
                    ),
                  ),
                ),
                _MonthBtn(
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: () {
                    Haptics.selection();
                    setState(() {
                      _cursor = DateTime(_cursor.year, _cursor.month + 1);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DayNamesRow(),
            const SizedBox(height: 6),
            _MonthGrid(
              cursor: _cursor,
              selected: selected,
              today: today,
              maxDate: maxDate,
              onPick: (d) =>
                  ref.read(bookingDraftProvider.notifier).setDate(d),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                _LegendDot(color: AppColors.ink, label: 'Selected'),
                const SizedBox(width: 18),
                _LegendDot(color: AppColors.hair2, label: 'Closed'),
              ],
            ),
          ],
        ),
      ),
      bottom: ActionBar(
        children: [
          if (selected != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SELECTED', style: AppText.eyebrow(size: 11)),
                      const SizedBox(height: 3),
                      Text(
                        DateFormat('EEE, d MMMM').format(selected),
                        style: AppText.sans(15, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          PrimaryButton(
            label: 'Next — pick a time',
            full: true,
            size: BtnSize.lg,
            trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
            onPressed:
                selected == null ? null : () => context.push('/book/time'),
          ),
        ],
      ),
    );
  }
}

class _MonthBtn extends StatelessWidget {
  const _MonthBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 16, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _DayNamesRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: days
          .map((d) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: AppText.sans(
                      11,
                      color: AppColors.ink3,
                      weight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.cursor,
    required this.selected,
    required this.today,
    required this.maxDate,
    required this.onPick,
  });

  final DateTime cursor;
  final DateTime? selected;
  final DateTime today;
  final DateTime maxDate;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(cursor.year, cursor.month, 1);
    final leading = (firstOfMonth.weekday + 6) % 7;
    final daysInMonth = DateTime(cursor.year, cursor.month + 1, 0).day;

    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(cursor.year, cursor.month, d);
      final isPast = date.isBefore(today);
      final beyondWindow = date.isAfter(maxDate);
      final isSunday = date.weekday == DateTime.sunday;
      final unavailable = isPast || beyondWindow || isSunday;
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isSelected = selected != null &&
          selected!.year == date.year &&
          selected!.month == date.month &&
          selected!.day == date.day;

      cells.add(
        GestureDetector(
          onTap: unavailable
              ? null
              : () {
                  Haptics.selection();
                  onPick(date);
                },
          behavior: HitTestBehavior.opaque,
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.standard,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.ink : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday && !isSelected
                      ? Border.all(color: AppColors.ink, width: 1.5)
                      : null,
                  boxShadow: isSelected ? AppShadow.sm : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$d',
                  style: AppText.tabular(
                    15,
                    color: isSelected
                        ? AppColors.bg
                        : unavailable
                            ? AppColors.hair2
                            : AppColors.ink,
                    weight: isSelected || isToday
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ).copyWith(
                    decoration: unavailable && !isToday
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 0,
      crossAxisSpacing: 0,
      children: cells,
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppText.sans(12, color: AppColors.ink3),
        ),
      ],
    );
  }
}
