import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/money.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/badge.dart';
import '../../../shared/widgets/primary_button.dart';
import '../domain/booking.dart';

class ConfirmationScreen extends ConsumerStatefulWidget {
  const ConfirmationScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  ConsumerState<ConfirmationScreen> createState() =>
      _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    // Heavy celebratory haptic when the screen lands.
    WidgetsBinding.instance.addPostFrameCallback((_) => Haptics.heavy());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(customerBookingsProvider).asData?.value ?? [];
    if (bookings.isEmpty) {
      return const AppScaffold(
        body: Center(child: Text('Booking not found.')),
      );
    }
    final Booking booking = bookings.firstWhere(
      (b) => b.id == widget.bookingId,
      orElse: () => bookings.first,
    );

    final df = DateFormat('EEE, d MMMM');
    final dayOfWeek = DateFormat('EEEE').format(booking.date);

    return AppScaffold(
      trailing: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.ink),
          onPressed: () {
            Haptics.selection();
            context.go('/home');
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH + 4,
          24,
          AppSpacing.screenH + 4,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0.0, 0.6, curve: AppMotion.spring),
              ),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                  boxShadow: AppShadow.md,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 30,
                  color: AppColors.bg,
                ),
              ),
            ),
            const SizedBox(height: 22),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
              ),
              child: RichText(
                text: TextSpan(
                  style: AppText.display(40),
                  children: [
                    const TextSpan(text: 'Booked.\n'),
                    TextSpan(
                      text: 'See you $dayOfWeek.',
                      style: AppText.display(
                        40,
                        color: AppColors.accent,
                        italic: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'A confirmation\'s been sent to your email. We\'ll remind you '
              'the day before and again 1 hour before we arrive.',
              style: AppText.sans(14, color: AppColors.ink3, height: 1.55),
            ),
            const SizedBox(height: 28),
            AppCard(
              pad: 20,
              elevated: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBadge(
                    'Booking #${booking.id.substring(0, 6).toUpperCase()}',
                    tone: BadgeTone.accent,
                  ),
                  const SizedBox(height: 12),
                  Text(booking.serviceName, style: AppText.display(24)),
                  const SizedBox(height: 4),
                  Divider(height: 28, color: AppColors.hair),
                  _Line(label: 'Date', value: df.format(booking.date)),
                  _Line(
                    label: 'Time',
                    value: '${booking.startTime} — ${booking.endTime}',
                  ),
                  _Line(label: 'Address', value: booking.address.oneLine),
                  _Line(
                    label: 'Paid',
                    value: formatRand(booking.priceCents),
                    bold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Add to calendar',
                    full: true,
                    variant: BtnVariant.ghost,
                    leading: const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    label: 'My bookings',
                    full: true,
                    onPressed: () => context.go('/my-bookings'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppText.sans(13, color: AppColors.ink3),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppText.sans(
                14,
                weight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
