import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../shared/widgets/badge.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/primary_button.dart';
import '../domain/saved_payment_method.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = ref.watch(savedPaymentMethodsProvider);

    return AppScaffold(
      title: 'Payment methods',
      large: true,
      subtitle: methods.isEmpty
          ? 'Save a card or wallet for one-tap checkout.'
          : '${methods.length} saved · default is used automatically',
      back: () => context.pop(),
      trailing: IconButton(
        icon: const Icon(Icons.add_rounded, size: 24),
        onPressed: () => _openAddSheet(context, ref),
      ),
      body: methods.isEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                4,
                AppSpacing.screenH,
                20,
              ),
              child: EmptyState(
                icon: Icons.credit_card_outlined,
                title: 'No payment methods yet',
                message:
                    'Add a card or link a wallet so your next wash is one tap.',
                action: PrimaryButton(
                  label: 'Add payment method',
                  size: BtnSize.lg,
                  leading: const Icon(Icons.add_rounded, size: 18),
                  onPressed: () => _openAddSheet(context, ref),
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
              itemCount: methods.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _PaymentMethodCard(
                method: methods[i],
                onMakeDefault: methods[i].isDefault
                    ? null
                    : () {
                        Haptics.selection();
                        ref
                            .read(savedPaymentMethodsProvider.notifier)
                            .setDefault(methods[i].id);
                      },
                onRemove: () => _confirmRemove(context, ref, methods[i]),
              ),
            ),
      bottom: methods.isEmpty
          ? null
          : ActionBar(
              children: [
                PrimaryButton(
                  label: 'Add another method',
                  full: true,
                  size: BtnSize.lg,
                  leading: const Icon(Icons.add_rounded, size: 18),
                  onPressed: () => _openAddSheet(context, ref),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 12,
                        color: AppColors.ink3,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Encrypted end-to-end · PCI-DSS compliant',
                        style: AppText.sans(11, color: AppColors.ink3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    SavedPaymentMethod method,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ConfirmRemoveSheet(method: method),
    );
    if (confirmed == true) {
      Haptics.medium();
      ref.read(savedPaymentMethodsProvider.notifier).remove(method.id);
    }
  }

  Future<void> _openAddSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _AddPaymentSheet(),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.onMakeDefault,
    required this.onRemove,
  });

  final SavedPaymentMethod method;
  final VoidCallback? onMakeDefault;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isCard = method.kind == PaymentMethodKind.card;
    final primary = isCard
        ? '${method.brand ?? 'Card'} · ${method.last4 ?? '••••'}'
        : method.label;
    final secondary = isCard
        ? 'Expires ${method.expiry ?? '—'}'
        : _walletSubtitle(method.kind);

    return AppCard(
      pad: 16,
      elevated: method.isDefault,
      borderColor: method.isDefault ? AppColors.accent : null,
      borderWidth: method.isDefault ? 1.5 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MethodGlyph(kind: method.kind),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            primary,
                            style: AppText.sans(15, weight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (method.isDefault) ...[
                          const SizedBox(width: 8),
                          const AppBadge('Default', tone: BadgeTone.accent),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      secondary,
                      style: AppText.sans(12, color: AppColors.ink3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.hair),
          const SizedBox(height: 8),
          Row(
            children: [
              if (onMakeDefault != null)
                TextButton(
                  onPressed: onMakeDefault,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Make default',
                    style: AppText.sans(13,
                        weight: FontWeight.w600, color: AppColors.ink),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    'Used for one-tap checkout',
                    style: AppText.sans(12, color: AppColors.ink3),
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: onRemove,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Remove',
                  style: AppText.sans(13,
                      weight: FontWeight.w600, color: AppColors.danger),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _walletSubtitle(PaymentMethodKind kind) {
    switch (kind) {
      case PaymentMethodKind.applePay:
        return 'Face ID or Touch ID required';
      case PaymentMethodKind.googlePay:
        return 'Google Pay · device lock required';
      case PaymentMethodKind.instantEft:
        return 'Bank login at checkout · Ozow';
      case PaymentMethodKind.card:
        return '';
    }
  }
}

class _MethodGlyph extends StatelessWidget {
  const _MethodGlyph({required this.kind});
  final PaymentMethodKind kind;

  @override
  Widget build(BuildContext context) {
    final (icon, bg) = switch (kind) {
      PaymentMethodKind.card => (Icons.credit_card_rounded, AppColors.ink),
      PaymentMethodKind.applePay => (Icons.apple, AppColors.ink),
      PaymentMethodKind.googlePay =>
        (Icons.account_balance_wallet_rounded, AppColors.ink2),
      PaymentMethodKind.instantEft =>
        (Icons.account_balance_outlined, AppColors.ink2),
    };
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 22, color: AppColors.bg),
    );
  }
}

class _ConfirmRemoveSheet extends StatelessWidget {
  const _ConfirmRemoveSheet({required this.method});
  final SavedPaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final label = method.kind == PaymentMethodKind.card
        ? '${method.brand ?? 'card'} ending ${method.last4 ?? '••••'}'
        : method.label;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadow.lg,
        ),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Remove payment method?', style: AppText.display(24)),
            const SizedBox(height: 8),
            Text(
              'You\'ll need to add $label again the next time you use it.',
              style: AppText.sans(14, color: AppColors.ink3, height: 1.5),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Remove',
              full: true,
              size: BtnSize.lg,
              variant: BtnVariant.danger,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Keep',
              full: true,
              variant: BtnVariant.ghost,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPaymentSheet extends ConsumerStatefulWidget {
  const _AddPaymentSheet();

  @override
  ConsumerState<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends ConsumerState<_AddPaymentSheet> {
  PaymentMethodKind _kind = PaymentMethodKind.card;
  final _number = TextEditingController();
  final _name = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  bool _makeDefault = true;

  @override
  void dispose() {
    _number.dispose();
    _name.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  bool get _cardValid {
    final digits = _number.text.replaceAll(' ', '');
    return digits.length >= 14 &&
        _name.text.trim().isNotEmpty &&
        _expiry.text.length == 5 &&
        _cvv.text.length >= 3;
  }

  void _save() {
    final notifier = ref.read(savedPaymentMethodsProvider.notifier);
    final id = 'pm_${DateTime.now().millisecondsSinceEpoch}';
    switch (_kind) {
      case PaymentMethodKind.card:
        if (!_cardValid) return;
        final digits = _number.text.replaceAll(' ', '');
        notifier.add(SavedPaymentMethod(
          id: id,
          kind: PaymentMethodKind.card,
          label: 'Card',
          brand: _brandFor(digits),
          last4: digits.substring(digits.length - 4),
          expiry: _expiry.text,
          isDefault: _makeDefault,
        ));
      case PaymentMethodKind.applePay:
        notifier.add(SavedPaymentMethod(
          id: id,
          kind: PaymentMethodKind.applePay,
          label: 'Apple Pay',
          isDefault: _makeDefault,
        ));
      case PaymentMethodKind.googlePay:
        notifier.add(SavedPaymentMethod(
          id: id,
          kind: PaymentMethodKind.googlePay,
          label: 'Google Pay',
          isDefault: _makeDefault,
        ));
      case PaymentMethodKind.instantEft:
        notifier.add(SavedPaymentMethod(
          id: id,
          kind: PaymentMethodKind.instantEft,
          label: 'Instant EFT',
          isDefault: _makeDefault,
        ));
    }
    Haptics.medium();
    Navigator.of(context).pop();
  }

  String _brandFor(String digits) {
    if (digits.startsWith('4')) return 'Visa';
    if (digits.startsWith('5') || digits.startsWith('2')) return 'Mastercard';
    if (digits.startsWith('3')) return 'Amex';
    return 'Card';
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadow.lg,
          ),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.hair2,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Add payment method', style: AppText.display(26)),
                const SizedBox(height: 4),
                Text(
                  'Cards are tokenised by our PSP. We never store the full PAN.',
                  style: AppText.sans(13, color: AppColors.ink3, height: 1.45),
                ),
                const SizedBox(height: 18),
                Text('TYPE', style: AppText.eyebrow(size: 11)),
                const SizedBox(height: 10),
                _KindPicker(
                  selected: _kind,
                  onChanged: (k) => setState(() => _kind = k),
                ),
                const SizedBox(height: 18),
                if (_kind == PaymentMethodKind.card) ...[
                  AppTextField(
                    label: 'Card number',
                    controller: _number,
                    keyboardType: TextInputType.number,
                    hint: '4242 4242 4242 4242',
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(19),
                      _CardNumberFormatter(),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Cardholder name',
                    controller: _name,
                    hint: 'As printed on card',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Expiry',
                          controller: _expiry,
                          hint: 'MM/YY',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            _ExpiryFormatter(),
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'CVV',
                          controller: _cvv,
                          hint: '123',
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone_iphone_rounded,
                          size: 20,
                          color: AppColors.ink2,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You\'ll confirm ${_kindLabel(_kind)} at checkout '
                            'with your device\'s built-in authentication.',
                            style: AppText.sans(
                              13,
                              color: AppColors.ink2,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),
                _DefaultToggle(
                  value: _makeDefault,
                  onChanged: (v) => setState(() => _makeDefault = v),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Save payment method',
                  full: true,
                  size: BtnSize.lg,
                  onPressed: (_kind == PaymentMethodKind.card && !_cardValid)
                      ? null
                      : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _kindLabel(PaymentMethodKind k) => switch (k) {
        PaymentMethodKind.applePay => 'Apple Pay',
        PaymentMethodKind.googlePay => 'Google Pay',
        PaymentMethodKind.instantEft => 'Instant EFT',
        PaymentMethodKind.card => 'card',
      };
}

class _KindPicker extends StatelessWidget {
  const _KindPicker({required this.selected, required this.onChanged});
  final PaymentMethodKind selected;
  final ValueChanged<PaymentMethodKind> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      (PaymentMethodKind.card, Icons.credit_card_rounded, 'Card'),
      (PaymentMethodKind.applePay, Icons.apple, 'Apple Pay'),
      (PaymentMethodKind.googlePay,
          Icons.account_balance_wallet_rounded, 'Google Pay'),
      (PaymentMethodKind.instantEft, Icons.account_balance_outlined, 'EFT'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (kind, icon, label) in items)
          _KindChip(
            icon: icon,
            label: label,
            selected: selected == kind,
            onTap: () {
              Haptics.selection();
              onChanged(kind);
            },
          ),
      ],
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.bg : AppColors.ink2,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppText.sans(
                  13,
                  weight: FontWeight.w600,
                  color: selected ? AppColors.bg : AppColors.ink,
                ),
              ),
            ],
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Icon(
                value
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 22,
                color: value ? AppColors.accent : AppColors.ink3,
              ),
              const SizedBox(width: 10),
              Text(
                'Set as default for one-tap checkout',
                style: AppText.sans(13, color: AppColors.ink2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    String formatted;
    if (digits.length <= 2) {
      formatted = digits;
    } else {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
