import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/money.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../booking/data/booking_repository.dart';
import '../../booking/presentation/booking_draft.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _method = 'card';
  bool _processing = false;

  Future<void> _charge() async {
    final draft = ref.read(bookingDraftProvider);
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null ||
        draft.service == null ||
        draft.date == null ||
        draft.startTime == null ||
        draft.address == null) {
      return;
    }

    setState(() => _processing = true);
    try {
      final repo =
          ref.read(bookingRepositoryProvider) as InMemoryBookingRepository;
      final created = await repo.create(
        customerId: user.uid,
        service: draft.service!,
        date: draft.date!,
        startTime: draft.startTime!,
        address: draft.address!,
      );

      final result = await ref.read(paymentServiceProvider).charge(
            bookingId: created.id,
            amountCents: draft.service!.priceCents,
            method: _method,
          );

      if (!result.success) {
        setState(() => _processing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment failed. Try again.')),
          );
        }
        return;
      }

      await repo.markConfirmed(created.id, result.paymentId);

      if (!mounted) return;
      ref.read(bookingDraftProvider.notifier).clear();
      context.go('/book/confirmation?bookingId=${created.id}');
    } catch (e) {
      setState(() => _processing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final cents = draft.service?.priceCents ?? 0;

    return AppScaffold(
      title: 'Payment',
      back: _processing ? null : () => context.pop(),
      trailing: const Padding(
        padding: EdgeInsets.only(right: 14),
        child: Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.ink3),
      ),
      body: _processing
          ? _ProcessingView(amountCents: cents)
          : SingleChildScrollView(
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
                  Text(
                    'PAYING',
                    style: AppText.eyebrow(size: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(formatRand(cents), style: AppText.display(48)),
                  const SizedBox(height: 6),
                  Text(
                    '${draft.service?.name ?? ''} · ${draft.startTime ?? ''}',
                    style: AppText.sans(13, color: AppColors.ink3),
                  ),
                  const SizedBox(height: 28),
                  Text('PAY WITH', style: AppText.eyebrow(size: 11)),
                  const SizedBox(height: 12),
                  _PayOption(
                    icon: Icons.credit_card_rounded,
                    title: 'Visa · 4242',
                    sub: 'Expires 08/28',
                    selected: _method == 'card',
                    onTap: () => setState(() => _method = 'card'),
                  ),
                  const SizedBox(height: 10),
                  _PayOption(
                    icon: Icons.apple,
                    title: 'Apple Pay',
                    sub: 'Face ID required',
                    selected: _method == 'apple_pay',
                    onTap: () => setState(() => _method = 'apple_pay'),
                  ),
                  const SizedBox(height: 10),
                  _PayOption(
                    icon: Icons.account_balance_outlined,
                    title: 'Instant EFT',
                    sub: 'Bank login · Ozow',
                    selected: _method == 'instant_eft',
                    onTap: () => setState(() => _method = 'instant_eft'),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 18,
                          color: AppColors.ink2,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Processed securely. We never see your card '
                            'details, and you\'ll be refunded instantly for '
                            'eligible cancellations.',
                            style: AppText.sans(
                              12,
                              color: AppColors.ink2,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottom: _processing
          ? null
          : ActionBar(
              children: [
                PrimaryButton(
                  label: 'Confirm & pay ${formatRand(cents)}',
                  full: true,
                  size: BtnSize.lg,
                  trailing: const Icon(Icons.lock_rounded, size: 14),
                  onPressed: () {
                    Haptics.medium();
                    _charge();
                  },
                ),
              ],
            ),
    );
  }
}

class _PayOption extends StatelessWidget {
  const _PayOption({
    required this.icon,
    required this.title,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      pad: 14,
      borderColor: selected ? AppColors.accent : AppColors.hair2,
      borderWidth: selected ? 2 : 1,
      elevated: selected,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, size: 18, color: AppColors.ink),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.sans(15, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: AppText.sans(12, color: AppColors.ink3),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: AppMotion.fast,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.accent : Colors.transparent,
              border: selected
                  ? null
                  : Border.all(color: AppColors.hair2, width: 1.5),
            ),
            alignment: Alignment.center,
            child: selected
                ? const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView({required this.amountCents});
  final int amountCents;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 24),
            Text('Processing payment', style: AppText.display(26)),
            const SizedBox(height: 8),
            Text(
              'Don\'t close this screen. This usually takes 3–5 seconds.',
              style: AppText.sans(13, color: AppColors.ink3, height: 1.55),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
