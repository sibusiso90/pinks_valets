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
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../booking/domain/address.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savedAddressesProvider);
    final addresses = async.asData?.value ?? const <Address>[];

    return AppScaffold(
      title: 'Addresses',
      large: true,
      subtitle: addresses.isEmpty
          ? 'Save your favourite spots so booking is one tap.'
          : '${addresses.length} saved ${addresses.length == 1 ? "place" : "places"}',
      back: () => context.pop(),
      trailing: IconButton(
        icon: const Icon(Icons.add_rounded, size: 24),
        onPressed: () => _openSheet(context, ref),
      ),
      body: addresses.isEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                4,
                AppSpacing.screenH,
                20,
              ),
              child: EmptyState(
                icon: Icons.place_outlined,
                title: 'No addresses yet',
                message:
                    'Add home, the office, or a regular spot — we only service '
                    'Johannesburg suburbs for now.',
                action: PrimaryButton(
                  label: 'Add an address',
                  size: BtnSize.lg,
                  leading: const Icon(Icons.add_rounded, size: 18),
                  onPressed: () => _openSheet(context, ref),
                ),
              ),
            )
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                4,
                AppSpacing.screenH,
                20,
              ),
              itemCount: addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _AddressCard(
                address: addresses[i],
                onEdit: () => _openSheet(context, ref, editing: addresses[i]),
                onDelete: () => _confirmDelete(context, ref, addresses[i]),
              ),
            ),
      bottom: addresses.isEmpty
          ? null
          : ActionBar(
              children: [
                PrimaryButton(
                  label: 'Add another address',
                  full: true,
                  size: BtnSize.lg,
                  leading: const Icon(Icons.add_rounded, size: 18),
                  onPressed: () => _openSheet(context, ref),
                ),
              ],
            ),
    );
  }

  Future<void> _openSheet(
    BuildContext context,
    WidgetRef ref, {
    Address? editing,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => _AddressSheet(editing: editing),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Address a,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text('Remove ${a.label}?', style: AppText.display(22)),
        content: Text(
          'This removes ${a.oneLine} from your address book. Existing '
          'bookings keep this address.',
          style: AppText.sans(14, color: AppColors.ink2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppText.sans(14)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Remove',
              style: AppText.sans(14,
                  color: AppColors.danger, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && a.id != null) {
      await ref.read(addressBookRepositoryProvider).remove(a.id!);
    }
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onEdit,
      pad: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _iconFor(address.label),
                  size: 22,
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
                      style: AppText.sans(15, weight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.oneLine,
                      style: AppText.sans(13, color: AppColors.ink2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, color: AppColors.ink3),
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (address.notes != null && address.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.sticky_note_2_outlined,
                      size: 16, color: AppColors.ink3),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address.notes!,
                      style:
                          AppText.sans(12, color: AppColors.ink2, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('home')) return Icons.home_outlined;
    if (l.contains('office') || l.contains('work')) {
      return Icons.business_outlined;
    }
    if (l.contains('gym')) return Icons.fitness_center_outlined;
    return Icons.place_outlined;
  }
}

class _AddressSheet extends ConsumerStatefulWidget {
  const _AddressSheet({this.editing});
  final Address? editing;

  @override
  ConsumerState<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends ConsumerState<_AddressSheet> {
  late final TextEditingController _label;
  late final TextEditingController _street;
  late final TextEditingController _suburb;
  late final TextEditingController _postal;
  late final TextEditingController _notes;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final a = widget.editing;
    _label = TextEditingController(text: a?.label ?? 'Home');
    _street = TextEditingController(text: a?.street ?? '');
    _suburb = TextEditingController(text: a?.suburb ?? '');
    _postal = TextEditingController(text: a?.postalCode ?? '');
    _notes = TextEditingController(text: a?.notes ?? '');
  }

  @override
  void dispose() {
    _label.dispose();
    _street.dispose();
    _suburb.dispose();
    _postal.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;
    final settings = ref.watch(systemSettingsProvider);
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.hair2,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            editing ? 'Edit address' : 'Add an address',
                            style: AppText.display(28),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            editing
                                ? 'Update the details of this place.'
                                : 'We pre-fill this at checkout.',
                            style:
                                AppText.sans(13, color: AppColors.ink3),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + keyboardInset),
                  children: [
                    Text(
                      'QUICK LABEL',
                      style: AppText.sans(
                        11,
                        color: AppColors.ink2,
                        weight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Home', 'Office', 'Gym', 'Other']
                          .map(
                            (p) => _LabelChip(
                              label: p,
                              selected: _label.text == p,
                              onTap: () => setState(() => _label.text = p),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Custom label',
                      hint: 'Home',
                      controller: _label,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Street address',
                      hint: '14 Rivonia Road',
                      controller: _street,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Suburb',
                            hint: 'Sandton',
                            controller: _suburb,
                          ),
                        ),
                        const SizedBox(width: 10),
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
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Notes for the team',
                      hint: 'Gate code 1234, parking at the back',
                      controller: _notes,
                      helper: 'Optional — gate codes, parking, pets.',
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16, color: AppColors.ink3),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'We service: ${settings.serviceAreaSuburbs.take(8).join(", ")}, and a few more.',
                              style: AppText.sans(12,
                                  color: AppColors.ink2, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        style:
                            AppText.sans(12, color: AppColors.danger),
                      ),
                    ],
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                  child: PrimaryButton(
                    label: editing ? 'Save changes' : 'Save address',
                    full: true,
                    size: BtnSize.lg,
                    loading: _saving,
                    onPressed: _saving ? null : _onSave,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onSave() async {
    final label = _label.text.trim();
    final street = _street.text.trim();
    final suburb = _suburb.text.trim();
    final postal = _postal.text.trim();

    if (label.isEmpty || street.isEmpty || suburb.isEmpty || postal.isEmpty) {
      setState(() =>
          _error = 'Fill in the label, street, suburb and postal code.');
      return;
    }

    final settings = ref.read(systemSettingsProvider);
    final valid = settings.serviceAreaSuburbs
        .map((s) => s.toLowerCase())
        .toSet();
    if (!valid.contains(suburb.toLowerCase())) {
      setState(() =>
          _error = "Sorry, we don't service $suburb yet.");
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final notes = _notes.text.trim();
    final repo = ref.read(addressBookRepositoryProvider);

    if (widget.editing == null) {
      await repo.add(
        Address(
          label: label,
          street: street,
          suburb: suburb,
          city: 'Johannesburg',
          postalCode: postal,
          notes: notes.isEmpty ? null : notes,
        ),
      );
    } else {
      await repo.update(
        widget.editing!.copyWith(
          label: label,
          street: street,
          suburb: suburb,
          postalCode: postal,
          notes: notes.isEmpty ? null : notes,
        ),
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? AppColors.ink : AppColors.hair2),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: AppText.sans(
              13,
              weight: FontWeight.w600,
              color: selected ? AppColors.bg : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
