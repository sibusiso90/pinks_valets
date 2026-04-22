import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/time_of_day.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/badge.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/segmented_tabs.dart';
import '../../../shared/widgets/tab_bar.dart';
import '../../booking/domain/booking.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  String _tab = 'upcoming';

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(customerBookingsProvider).asData?.value ?? [];

    final upcoming = bookings.where((b) => b.status.isUpcoming).toList();
    final history = bookings.where((b) => !b.status.isUpcoming).toList();
    final list = _tab == 'upcoming' ? upcoming : history;

    return AppScaffold(
      title: 'Bookings',
      large: true,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              0,
              AppSpacing.screenH,
              14,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SegmentedTabs(
                active: _tab,
                onChanged: (v) => setState(() => _tab = v),
                segments: [
                  SegmentedTab('upcoming', 'Upcoming (${upcoming.length})'),
                  SegmentedTab('history', 'History (${history.length})'),
                ],
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              transitionBuilder: (w, a) => FadeTransition(opacity: a, child: w),
              child: list.isEmpty
                  ? EmptyState(
                      key: ValueKey('empty-$_tab'),
                      icon: _tab == 'upcoming'
                          ? Icons.event_available_rounded
                          : Icons.history_rounded,
                      title: _tab == 'upcoming'
                          ? 'No bookings yet.'
                          : 'No history yet.',
                      message: _tab == 'upcoming'
                          ? 'When you book your first wash, it\'ll show up here.'
                          : 'Completed and cancelled bookings will appear here.',
                      action: _tab == 'upcoming'
                          ? PrimaryButton(
                              label: 'Book a wash',
                              size: BtnSize.lg,
                              variant: BtnVariant.accent,
                              trailing: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                              onPressed: () => context.go('/book/service'),
                            )
                          : null,
                    )
                  : ListView.separated(
                      key: ValueKey('list-$_tab'),
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenH,
                        0,
                        AppSpacing.screenH,
                        24,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _BookingCard(b: list[i]),
                    ),
            ),
          ),
        ],
      ),
      bottom: AppBottomNav(
        active: 'bookings',
        onTap: (id) {
          switch (id) {
            case 'home':
              context.go('/home');
            case 'bookings':
              break;
            case 'chat':
              context.go('/chat');
            case 'profile':
              context.go('/profile');
          }
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.b});
  final Booking b;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE d MMM');
    final tone = b.status.isUpcoming
        ? BadgeTone.accent
        : b.status.isDone
            ? BadgeTone.success
            : BadgeTone.danger;
    final label = b.status.isUpcoming
        ? 'Confirmed'
        : b.status.isDone
            ? 'Completed'
            : 'Cancelled';

    return AppCard(
      pad: 18,
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppBadge(label, tone: tone),
              const Spacer(),
              Text(
                formatRand(b.priceCents),
                style: AppText.tabular(16, weight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            b.serviceName,
            style: AppText.display(22),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 13,
                color: AppColors.ink3,
              ),
              const SizedBox(width: 5),
              Text(
                '${df.format(b.date)}  ·  ${b.startTime}',
                style: AppText.sans(13, color: AppColors.ink3),
              ),
              const Spacer(),
              Text(
                formatDurationShort(b.serviceDurationMinutes),
                style: AppText.sans(12, color: AppColors.ink3),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 13,
                color: AppColors.ink3,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  b.address.oneLine,
                  style: AppText.sans(12, color: AppColors.ink2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
