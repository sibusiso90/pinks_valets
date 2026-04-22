import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/primary_button.dart';
import '../domain/vehicle.dart';

class MyCarsScreen extends ConsumerWidget {
  const MyCarsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vehiclesProvider);
    final vehicles = async.asData?.value ?? const <Vehicle>[];

    return AppScaffold(
      title: 'My cars',
      large: true,
      subtitle: vehicles.isEmpty
          ? 'Add the cars we clean — your default one gets pre-picked at checkout.'
          : '${vehicles.length} ${vehicles.length == 1 ? "car" : "cars"} in your garage',
      back: () => context.pop(),
      trailing: IconButton(
        icon: const Icon(Icons.add_rounded, size: 24),
        onPressed: () {
          Haptics.selection();
          _openSheet(context, ref);
        },
      ),
      body: vehicles.isEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                4,
                AppSpacing.screenH,
                20,
              ),
              child: EmptyState(
                icon: Icons.directions_car_outlined,
                title: 'No cars yet',
                message:
                    "Add the cars you'd like Pink's to wash. We use this to "
                    'prep the right products before we arrive.',
                action: PrimaryButton(
                  label: 'Add a car',
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
              itemCount: vehicles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _VehicleCard(
                vehicle: vehicles[i],
                onEdit: () => _openSheet(context, ref, editing: vehicles[i]),
                onMakeDefault: () => ref
                    .read(vehicleRepositoryProvider)
                    .setDefault(vehicles[i].id),
                onDelete: () => _confirmDelete(context, ref, vehicles[i]),
              ),
            ),
      bottom: vehicles.isEmpty
          ? null
          : ActionBar(
              children: [
                PrimaryButton(
                  label: 'Add another car',
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
    Vehicle? editing,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => _VehicleSheet(editing: editing),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Vehicle v,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text('Remove ${v.nickname}?', style: AppText.display(22)),
        content: Text(
          'This removes ${v.display} from your garage. Existing bookings '
          'are not affected.',
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
              style:
                  AppText.sans(14, color: AppColors.danger, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(vehicleRepositoryProvider).remove(v.id);
    }
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.onEdit,
    required this.onMakeDefault,
    required this.onDelete,
  });

  final Vehicle vehicle;
  final VoidCallback onEdit;
  final VoidCallback onMakeDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onEdit,
      pad: 16,
      borderColor: vehicle.isDefault ? AppColors.ink : AppColors.hair,
      borderWidth: vehicle.isDefault ? 1.5 : 1,
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
                child: const Icon(
                  Icons.directions_car_filled_outlined,
                  size: 22,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            vehicle.nickname,
                            style:
                                AppText.sans(15, weight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (vehicle.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: AppText.sans(
                                10,
                                color: AppColors.accent,
                                weight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle.display,
                      style: AppText.sans(13, color: AppColors.ink2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _OverflowButton(
                onEdit: onEdit,
                onMakeDefault: vehicle.isDefault ? null : onMakeDefault,
                onDelete: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetaChip(label: vehicle.size.label),
              const SizedBox(width: 6),
              _MetaChip(label: vehicle.colour),
              const SizedBox(width: 6),
              _MetaChip(label: vehicle.year.toString()),
              const Spacer(),
              Text(
                vehicle.registration.toUpperCase(),
                style: AppText.tabular(12, color: AppColors.ink2,
                    weight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppText.sans(11, color: AppColors.ink2, weight: FontWeight.w600),
      ),
    );
  }
}

class _OverflowButton extends StatelessWidget {
  const _OverflowButton({
    required this.onEdit,
    required this.onMakeDefault,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback? onMakeDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, color: AppColors.ink3),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      onSelected: (v) {
        switch (v) {
          case 'edit':
            onEdit();
          case 'default':
            onMakeDefault?.call();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        if (onMakeDefault != null)
          const PopupMenuItem(
            value: 'default',
            child: Text('Make default'),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Text(
            'Delete',
            style: TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    );
  }
}

class _VehicleSheet extends ConsumerStatefulWidget {
  const _VehicleSheet({this.editing});
  final Vehicle? editing;

  @override
  ConsumerState<_VehicleSheet> createState() => _VehicleSheetState();
}

class _VehicleSheetState extends ConsumerState<_VehicleSheet> {
  late final TextEditingController _nickname;
  late final TextEditingController _make;
  late final TextEditingController _model;
  late final TextEditingController _year;
  late final TextEditingController _colour;
  late final TextEditingController _reg;
  late VehicleSize _size;
  late bool _isDefault;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final v = widget.editing;
    _nickname = TextEditingController(text: v?.nickname ?? '');
    _make = TextEditingController(text: v?.make ?? '');
    _model = TextEditingController(text: v?.model ?? '');
    _year = TextEditingController(
      text: v?.year.toString() ?? DateTime.now().year.toString(),
    );
    _colour = TextEditingController(text: v?.colour ?? '');
    _reg = TextEditingController(text: v?.registration ?? '');
    _size = v?.size ?? VehicleSize.sedan;
    _isDefault = v?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nickname.dispose();
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _colour.dispose();
    _reg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;
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
                            editing ? 'Edit car' : 'Add a car',
                            style: AppText.display(28),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            editing
                                ? 'Update the details of this vehicle.'
                                : "We'll prep the right products for it.",
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
                    AppTextField(
                      label: 'Nickname',
                      hint: 'Daily driver',
                      controller: _nickname,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Make',
                            hint: 'BMW',
                            controller: _make,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppTextField(
                            label: 'Model',
                            hint: '320i',
                            controller: _model,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: AppTextField(
                            label: 'Year',
                            hint: '2021',
                            controller: _year,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppTextField(
                            label: 'Colour',
                            hint: 'Alpine White',
                            controller: _colour,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Registration',
                      hint: 'CA 123 456',
                      controller: _reg,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'SIZE',
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
                      children: VehicleSize.values
                          .map(
                            (s) => _SizeChip(
                              label: s.label,
                              selected: _size == s,
                              onTap: () => setState(() => _size = s),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    _DefaultToggle(
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
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
                    label: editing ? 'Save changes' : 'Add to garage',
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
    final nick = _nickname.text.trim();
    final make = _make.text.trim();
    final model = _model.text.trim();
    final colour = _colour.text.trim();
    final reg = _reg.text.trim();
    final yearInt = int.tryParse(_year.text.trim());

    if (nick.isEmpty || make.isEmpty || model.isEmpty || colour.isEmpty) {
      setState(() => _error = 'Fill in nickname, make, model, and colour.');
      return;
    }
    if (yearInt == null || yearInt < 1950 || yearInt > DateTime.now().year + 1) {
      setState(() => _error = 'Enter a sensible year.');
      return;
    }
    if (reg.isEmpty) {
      setState(() => _error = 'Registration helps the team find you.');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final repo = ref.read(vehicleRepositoryProvider);
    if (widget.editing == null) {
      await repo.add(
        Vehicle(
          id: '',
          nickname: nick,
          make: make,
          model: model,
          year: yearInt,
          colour: colour,
          registration: reg,
          size: _size,
          isDefault: _isDefault,
        ),
      );
    } else {
      await repo.update(
        widget.editing!.copyWith(
          nickname: nick,
          make: make,
          model: model,
          year: yearInt,
          colour: colour,
          registration: reg,
          size: _size,
          isDefault: _isDefault,
        ),
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
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
        side: BorderSide(
          color: selected ? AppColors.ink : AppColors.hair2,
        ),
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

class _DefaultToggle extends StatelessWidget {
  const _DefaultToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      pad: 14,
      onTap: () => onChanged(!value),
      borderColor: value ? AppColors.ink : AppColors.hair,
      borderWidth: value ? 1.5 : 1,
      child: Row(
        children: [
          const Icon(Icons.star_outline_rounded, size: 20, color: AppColors.ink),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make this my default car',
                  style: AppText.sans(14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 1),
                Text(
                  'Pre-selected at checkout.',
                  style: AppText.sans(12, color: AppColors.ink3),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
