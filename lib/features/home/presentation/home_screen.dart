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
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/badge.dart';
import '../../../shared/widgets/pinks_logo.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/tab_bar.dart';
import '../../booking/domain/address.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/service_type.dart';
import '../../booking/presentation/booking_draft.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;
    final firstName = (user?.name.split(' ').first) ?? 'there';
    final bookings = ref.watch(customerBookingsProvider).asData?.value ?? [];
    final services = ref.watch(servicesProvider).asData?.value ?? [];

    final upcoming = bookings.firstWhere(
      (b) => b.status.isUpcoming,
      orElse: () => _NoBooking.sentinel,
    );
    final hasUpcoming = upcoming.id != _NoBooking.sentinel.id;

    return AppScaffold(
      safe: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              10,
              AppSpacing.screenH,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  PinksLogo(height: 28, showTagline: false),
                  const Spacer(),
                  _BellButton(
                    hasUnread: true,
                    onTap: () => context.push('/notifications'),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              22,
              AppSpacing.screenH,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_timeGreeting()},',
                    style: AppText.sans(13, color: AppColors.ink3),
                  ),
                  const SizedBox(height: 4),
                  Text('$firstName.', style: AppText.display(34)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 24)),
          if (hasUpcoming)
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH,
              ),
              sliver: SliverToBoxAdapter(
                child: _UpcomingCard(booking: upcoming),
              ),
            ),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH,
            ),
            sliver: SliverToBoxAdapter(
              child: PrimaryButton(
                label: hasUpcoming ? 'Book another wash' : 'Book a wash',
                full: true,
                size: BtnSize.lg,
                variant: BtnVariant.accent,
                trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
                onPressed: () {
                  ref.read(bookingDraftProvider.notifier).clear();
                  context.push('/book/service');
                },
              ),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 32)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              0,
              AppSpacing.screenH,
              12,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    'POPULAR SERVICES',
                    style: AppText.eyebrow(size: 11),
                  ),
                  const Spacer(),
                  _SeeAllLink(
                    onTap: () => context.push('/book/service'),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              0,
              AppSpacing.screenH,
              12,
            ),
            sliver: SliverList.separated(
              itemCount: services.take(3).length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final s = services.take(3).toList()[i];
                return _ServiceRow(
                  service: s,
                  onTap: () {
                    ref.read(bookingDraftProvider.notifier)
                      ..clear()
                      ..setService(s);
                    context.push('/book/date');
                  },
                );
              },
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 32)),
        ],
      ),
      bottom: AppBottomNav(
        active: 'home',
        onTap: (id) {
          switch (id) {
            case 'home':
              break;
            case 'bookings':
              context.go('/my-bookings');
            case 'chat':
              context.go('/chat');
            case 'profile':
              context.go('/profile');
          }
        },
      ),
    );
  }

  String _timeGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}

class _SeeAllLink extends StatelessWidget {
  const _SeeAllLink({required this.onTap});
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
          child: Row(
            children: [
              Text(
                'See all',
                style: AppText.sans(
                  12,
                  color: AppColors.ink,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: AppColors.ink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE d MMMM');
    final now = DateTime.now();
    final diff = booking.date.difference(
      DateTime(now.year, now.month, now.day),
    );
    final isToday = diff.inDays == 0;
    final isTomorrow = diff == const Duration(days: 1);
    final dateLabel = isToday
        ? 'Today'
        : isTomorrow
            ? 'Tomorrow'
            : df.format(booking.date);

    return Container(
      decoration: BoxDecoration(
        gradient: kInkHeroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadow.lg,
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x66D81B84),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'UPCOMING',
                style: AppText.sans(
                  11,
                  color: AppColors.accent,
                  weight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Text(
                dateLabel.toUpperCase(),
                style: AppText.sans(
                  11,
                  color: const Color(0xFFB8ADA4),
                  weight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            booking.serviceName,
            style: AppText.display(28, color: AppColors.bg),
          ),
          const SizedBox(height: 6),
          Text(
            '${booking.startTime} — ${booking.endTime}  ·  ${formatDurationShort(booking.serviceDurationMinutes)}',
            style: AppText.sans(13, color: const Color(0xFFC8C0B6)),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    booking.address.oneLine,
                    style: AppText.sans(
                      13,
                      color: const Color(0xFFE5DFD5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              PrimaryButton(
                label: 'View details',
                size: BtnSize.sm,
                variant: BtnVariant.accent,
                onPressed: () {
                  // Booking detail routing — would go to /my-bookings/:id.
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  booking.address.label.isEmpty
                      ? ''
                      : 'Saved as ${booking.address.label}',
                  style: AppText.sans(12, color: const Color(0xFF8A8178)),
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

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service, required this.onTap});
  final ServiceType service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final featured = service.id == 'full-valet';
    return AppCard(
      onTap: onTap,
      pad: 16,
      borderColor: featured ? AppColors.ink : AppColors.hair,
      borderWidth: featured ? 1.5 : 1,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: featured ? AppColors.ink : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: Icon(
              _iconFor(service.id),
              size: 20,
              color: featured ? AppColors.bg : AppColors.ink,
            ),
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
                        service.name,
                        style: AppText.sans(
                          15,
                          weight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (featured) ...[
                      const SizedBox(width: 8),
                      const AppBadge('Popular', tone: BadgeTone.accent),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  formatDurationShort(service.durationMinutes),
                  style: AppText.sans(12, color: AppColors.ink3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRand(service.priceCents),
                style: AppText.tabular(16, weight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: AppColors.ink3,
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String id) {
    switch (id) {
      case 'full-valet':
        return Icons.auto_awesome_rounded;
      case 'exterior-wash':
        return Icons.water_drop_outlined;
      case 'interior-detail':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.local_car_wash_outlined;
    }
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.hasUnread, required this.onTap});
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.hair2, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Haptics.selection();
          onTap();
        },
        customBorder: const CircleBorder(),
        splashColor: AppColors.accentSoft,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                size: 20,
                color: AppColors.ink,
              ),
              if (hasUnread)
                Positioned(
                  top: 10,
                  right: 11,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bg, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sentinel helper — used to mean "no upcoming booking". Keeping this out of
/// the Booking class so a real booking can never masquerade as the sentinel.
class _NoBooking {
  static final sentinel = Booking(
    id: '__none__',
    customerId: '',
    serviceId: '',
    serviceName: '',
    serviceDurationMinutes: 0,
    date: DateTime(2000),
    startTime: '00:00',
    endTime: '00:00',
    address: const Address(
      label: '',
      street: '',
      suburb: '',
      city: '',
      postalCode: '',
    ),
    status: BookingStatus.completed,
    priceCents: 0,
    createdAt: DateTime(2000),
    updatedAt: DateTime(2000),
  );
}
