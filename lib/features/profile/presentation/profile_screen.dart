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
import '../../../shared/widgets/tab_bar.dart';
import '../../payment/domain/saved_payment_method.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;
    final bookings = ref.watch(customerBookingsProvider).asData?.value ?? [];
    final vehicles = ref.watch(vehiclesProvider).asData?.value ?? const [];
    final addresses =
        ref.watch(savedAddressesProvider).asData?.value ?? const [];
    final methods = ref.watch(savedPaymentMethodsProvider);
    final langCode = ref.watch(languageProvider);

    final completed = bookings.where((b) => b.status.isDone).toList();
    final spent = completed.fold<int>(0, (s, b) => s + b.priceCents);
    final defaultCar = vehicles.where((v) => v.isDefault).toList();
    final carSubtitle = vehicles.isEmpty
        ? 'None yet — add your first car'
        : defaultCar.isNotEmpty
            ? '${defaultCar.first.display} · ${vehicles.length} saved'
            : '${vehicles.length} saved';
    final addressSubtitle = addresses.isEmpty
        ? 'None yet — save home or the office'
        : '${addresses.length} saved';
    final defaultMethod = methods.where((m) => m.isDefault).toList();
    final methodSubtitle = methods.isEmpty
        ? 'None yet — add a card or wallet'
        : defaultMethod.isNotEmpty
            ? '${_methodLabel(defaultMethod.first.kind, defaultMethod.first.last4)} · '
                '${methods.length} saved'
            : '${methods.length} saved';
    final languageLabel = _languageName(langCode);

    return AppScaffold(
      title: 'Profile',
      large: true,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          0,
          AppSpacing.screenH,
          28,
        ),
        children: [
          _IdentityCard(
            name: user?.name ?? 'Thandi Mahlangu',
            phone: user?.phone ?? '',
            email: user?.email ?? '',
            washes: completed.length,
            spent: spent,
            tier: 'Gold',
            onEdit: () => _showComingSoon(context, 'Edit profile'),
          ),
          const SizedBox(height: 28),
          _SectionLabel('GARAGE'),
          const SizedBox(height: 10),
          _RowsCard(rows: [
            _RowItem(
              icon: Icons.directions_car_outlined,
              title: 'My cars',
              subtitle: carSubtitle,
              onTap: () => context.push('/cars'),
            ),
            _RowItem(
              icon: Icons.place_outlined,
              title: 'Saved addresses',
              subtitle: addressSubtitle,
              onTap: () => context.push('/addresses'),
            ),
            _RowItem(
              icon: Icons.credit_card_outlined,
              title: 'Payment methods',
              subtitle: methodSubtitle,
              onTap: () => context.push('/payment-methods'),
            ),
          ]),
          const SizedBox(height: 24),
          _SectionLabel('PREFERENCES'),
          const SizedBox(height: 10),
          _RowsCard(rows: [
            _RowItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: 'Reminders, arrival updates',
              onTap: () => context.push('/notifications'),
            ),
            _RowItem(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: languageLabel,
              onTap: () => context.push('/language'),
            ),
          ]),
          const SizedBox(height: 24),
          _SectionLabel('SUPPORT'),
          const SizedBox(height: 10),
          _RowsCard(rows: [
            _RowItem(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chat with Pink\'s',
              subtitle: 'Mon–Sat · 07:00 – 18:00',
              onTap: () => context.push('/chat'),
            ),
            _RowItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & FAQ',
              subtitle: 'Answers in under a minute',
              onTap: () => context.push('/help'),
            ),
            _RowItem(
              icon: Icons.shield_outlined,
              title: 'Terms & privacy',
              subtitle: 'Last updated 12 March 2026',
              onTap: () => context.push('/terms'),
            ),
          ]),
          const SizedBox(height: 22),
          _SignOutRow(
            onTap: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (!context.mounted) return;
              context.go('/welcome');
            },
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              "Pink's · v1.0.0",
              style: AppText.sans(
                11,
                color: AppColors.ink3,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
      bottom: AppBottomNav(
        active: 'profile',
        onTap: (id) {
          switch (id) {
            case 'home':
              context.go('/home');
            case 'bookings':
              context.go('/my-bookings');
            case 'chat':
              context.go('/chat');
            case 'profile':
              break;
          }
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — coming soon'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _methodLabel(PaymentMethodKind kind, String? last4) {
    switch (kind) {
      case PaymentMethodKind.card:
        return 'Card · ${last4 ?? '••••'}';
      case PaymentMethodKind.applePay:
        return 'Apple Pay';
      case PaymentMethodKind.googlePay:
        return 'Google Pay';
      case PaymentMethodKind.instantEft:
        return 'Instant EFT';
    }
  }

  String _languageName(String code) {
    switch (code) {
      case 'af':
        return 'Afrikaans';
      case 'zu':
        return 'isiZulu';
      case 'xh':
        return 'isiXhosa';
      case 'st':
        return 'Sesotho';
      case 'tn':
        return 'Setswana';
      case 'en':
      default:
        return 'English';
    }
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.name,
    required this.phone,
    required this.email,
    required this.washes,
    required this.spent,
    required this.tier,
    required this.onEdit,
  });

  final String name;
  final String phone;
  final String email;
  final int washes;
  final int spent;
  final String tier;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kInkHeroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadow.lg,
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF04BA3), AppColors.accent],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: AppShadow.accentGlow,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(name),
                  style: AppText.display(22, color: AppColors.accentInk),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppText.display(24, color: AppColors.bg),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [phone, email].where((s) => s.isNotEmpty).join(' · '),
                      style: AppText.sans(
                        12,
                        color: AppColors.bg.withValues(alpha: 0.65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _CircleIconBtn(
                icon: Icons.edit_outlined,
                onTap: onEdit,
                tooltip: 'Edit profile',
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            height: 1,
            color: AppColors.bg.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DarkStat(
                  value: washes.toString(),
                  label: 'Washes',
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.bg.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _DarkStat(
                  value: formatRand(spent),
                  label: 'Spent',
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.bg.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _DarkStat(value: tier, label: 'Tier'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '??';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}

class _CircleIconBtn extends StatelessWidget {
  const _CircleIconBtn({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: Colors.white.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {
          Haptics.selection();
          onTap();
        },
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 16, color: AppColors.bg),
        ),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: child) : child;
  }
}

class _DarkStat extends StatelessWidget {
  const _DarkStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppText.display(24, color: AppColors.bg),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: AppText.sans(
            10,
            color: AppColors.bg.withValues(alpha: 0.55),
            weight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
      child: Text(
        label,
        style: AppText.eyebrow(size: 11),
      ),
    );
  }
}

class _RowItem {
  const _RowItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
}

class _RowsCard extends StatelessWidget {
  const _RowsCard({required this.rows});
  final List<_RowItem> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      pad: 0,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: rows[i].onTap == null
                    ? null
                    : () {
                        Haptics.selection();
                        rows[i].onTap!();
                      },
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(i == 0 ? AppRadius.lg : 0),
                  bottom: Radius.circular(
                      i == rows.length - 1 ? AppRadius.lg : 0),
                ),
                splashColor: AppColors.accentSoft,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        alignment: Alignment.center,
                        child: Icon(rows[i].icon,
                            size: 18, color: AppColors.ink),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rows[i].title,
                              style: AppText.sans(15, weight: FontWeight.w600),
                            ),
                            if (rows[i].subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                rows[i].subtitle!,
                                style:
                                    AppText.sans(12, color: AppColors.ink3),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: AppColors.ink3,
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),
              ),
            ),
            if (i < rows.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Divider(height: 1, color: AppColors.hair),
              ),
          ],
        ],
      ),
    );
  }
}

class _SignOutRow extends StatelessWidget {
  const _SignOutRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      pad: 0,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: () {
            Haptics.medium();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppRadius.lg),
          splashColor: AppColors.dangerSoft,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.logout_rounded,
                      size: 18, color: AppColors.danger),
                ),
                const SizedBox(width: 14),
                Text(
                  'Sign out',
                  style: AppText.sans(
                    15,
                    color: AppColors.danger,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
