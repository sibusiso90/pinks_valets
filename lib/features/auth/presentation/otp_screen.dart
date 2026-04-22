import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _digits = List<String>.filled(6, '');
  late final List<FocusNode> _focus;
  late final List<TextEditingController> _ctrls;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _focus = List.generate(6, (_) {
      final node = FocusNode();
      node.addListener(() {
        if (mounted) setState(() {});
      });
      return node;
    });
    _ctrls = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final f in _focus) {
      f.dispose();
    }
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _digits.join();
    if (code.length < 6 || code.contains(RegExp(r'[^0-9]'))) {
      setState(() => _error = 'Enter the 6-digit code we sent you.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyOtp(code);
      if (!mounted) return;
      Haptics.medium();
      context.go('/home');
    } catch (_) {
      setState(() => _error = 'That code didn\'t work. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Verify your\nnumber.', style: AppText.display(34)),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: AppText.sans(14, color: AppColors.ink3, height: 1.5),
                children: [
                  const TextSpan(text: 'We sent a 6-digit code to '),
                  TextSpan(
                    text: '+27 82 345 6789',
                    style: AppText.sans(
                      14,
                      color: AppColors.ink,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: List.generate(6, (i) => _digitField(i)),
            ),
            const SizedBox(height: 22),
            Center(
              child: RichText(
                text: TextSpan(
                  style: AppText.sans(13, color: AppColors.ink3),
                  children: [
                    const TextSpan(text: 'Didn\'t receive it? '),
                    TextSpan(
                      text: 'Resend in 0:42',
                      style: AppText.sans(
                        13,
                        color: AppColors.ink,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 14,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _error!,
                      style: AppText.sans(13, color: AppColors.danger),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottom: ActionBar(
        children: [
          PrimaryButton(
            label: 'Verify',
            full: true,
            size: BtnSize.lg,
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _digitField(int i) {
    final hasValue = _digits[i].isNotEmpty;
    final isFocused = _focus[i].hasFocus;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: i == 5 ? 0 : 8),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isFocused
                  ? AppColors.ink
                  : hasValue
                      ? AppColors.ink
                      : AppColors.hair2,
              width: isFocused || hasValue ? 1.5 : 1,
            ),
            boxShadow: isFocused
                ? const [
                    BoxShadow(
                      color: Color(0x14140A0F),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            focusNode: _focus[i],
            controller: _ctrls[i],
            autofocus: i == 0,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            cursorColor: AppColors.ink,
            style: AppText.display(26),
            decoration: const InputDecoration(
              counterText: '',
              filled: false,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: (v) {
              if (v.isNotEmpty) Haptics.selection();
              setState(() => _digits[i] = v);
              if (v.isNotEmpty && i < 5) {
                _focus[i + 1].requestFocus();
              } else if (v.isEmpty && i > 0) {
                _focus[i - 1].requestFocus();
              }
            },
          ),
        ),
      ),
    );
  }
}
