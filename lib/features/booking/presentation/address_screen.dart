import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../domain/address.dart';
import 'booking_draft.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  final _street = TextEditingController();
  final _suburb = TextEditingController();
  final _postal = TextEditingController();
  final _notes = TextEditingController();

  Address? _chosenSaved;
  String? _errorSuburb;
  bool _didPrefill = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(systemSettingsProvider);
    final saved = ref.watch(savedAddressesProvider).asData?.value ??
        const <Address>[];

    if (!_didPrefill && saved.isNotEmpty) {
      final draft = ref.read(bookingDraftProvider);
      if (draft.address != null) {
        _chosenSaved = saved.firstWhere(
          (a) => a.oneLine == draft.address!.oneLine,
          orElse: () => saved.first,
        );
      }
      _didPrefill = true;
    }

    return AppScaffold(
      title: 'Address',
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
            Text('Where to?', style: AppText.display(30)),
            const SizedBox(height: 6),
            Text(
              'We\'ll arrive right on your doorstep.',
              style: AppText.sans(13, color: AppColors.ink3),
            ),
            const SizedBox(height: 24),
            if (saved.isNotEmpty) ...[
              Text('SAVED', style: AppText.eyebrow(size: 11)),
              const SizedBox(height: 12),
              for (final a in saved) ...[
                _SavedAddressRow(
                  address: a,
                  selected: _chosenSaved?.id == a.id,
                  onTap: () => setState(() => _chosenSaved = a),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
            ],
            Text(
              saved.isEmpty ? 'NEW ADDRESS' : 'OR ADD NEW',
              style: AppText.eyebrow(size: 11),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Street address',
              hint: '14 Rivonia Road',
              controller: _street,
              leading: const Icon(Icons.place_outlined),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Suburb',
                    hint: 'Sandton',
                    controller: _suburb,
                    errorText: _errorSuburb,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: AppTextField(
                    label: 'Postal',
                    hint: '2196',
                    controller: _postal,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Notes for the team',
              hint: 'Gate code 1234, unit 12',
              controller: _notes,
              helper: 'Optional — gate codes, parking, pets.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.ink2,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'We service ${settings.serviceAreaSuburbs.take(6).join(", ")} and more.',
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
      bottom: ActionBar(
        children: [
          PrimaryButton(
            label: 'Use this address',
            full: true,
            size: BtnSize.lg,
            trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
            onPressed: () {
              final address = _chosenSaved ??
                  Address(
                    label: 'Home',
                    street: _street.text.trim(),
                    suburb: _suburb.text.trim(),
                    city: 'Johannesburg',
                    postalCode: _postal.text.trim(),
                    notes: _notes.text.trim().isEmpty
                        ? null
                        : _notes.text.trim(),
                  );
              if (address.street.isEmpty || address.suburb.isEmpty) {
                setState(() => _errorSuburb = 'Fill in the address first.');
                return;
              }
              final validSuburbs = settings.serviceAreaSuburbs
                  .map((s) => s.toLowerCase())
                  .toSet();
              if (!validSuburbs.contains(address.suburb.toLowerCase())) {
                setState(() =>
                    _errorSuburb = 'Sorry, we don\'t service this area yet.');
                return;
              }
              setState(() => _errorSuburb = null);
              ref.read(bookingDraftProvider.notifier).setAddress(address);
              context.push('/book/summary');
            },
          ),
        ],
      ),
    );
  }
}

class _SavedAddressRow extends StatelessWidget {
  const _SavedAddressRow({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final Address address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      pad: 14,
      borderColor: selected ? AppColors.accent : AppColors.hair,
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
            child: Icon(
              address.label.toLowerCase() == 'home'
                  ? Icons.home_outlined
                  : Icons.business_outlined,
              size: 18,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.label,
                  style: AppText.sans(14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  address.oneLine,
                  style: AppText.sans(12, color: AppColors.ink3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: AppMotion.fast,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: selected ? AppColors.accent : Colors.transparent,
              shape: BoxShape.circle,
              border: selected
                  ? null
                  : Border.all(color: AppColors.hair2, width: 1.5),
            ),
            child: selected
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}
