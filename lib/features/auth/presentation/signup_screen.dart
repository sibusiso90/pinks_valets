import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _agree = true;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.length < 8) {
      setState(() {
        _error =
            'Fill in every field — password needs at least 8 characters.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signUp(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );
      if (!mounted) return;
      context.push('/verify-otp');
    } catch (e) {
      setState(() => _error = 'Sign-up failed. Try again.');
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
            Text('Create your\naccount.', style: AppText.display(34)),
            const SizedBox(height: 10),
            Text(
              'Takes about a minute. We only use your details for your bookings.',
              style: AppText.sans(14, color: AppColors.ink3, height: 1.5),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Full name',
              hint: 'Thandi Mahlangu',
              controller: _name,
              textInputAction: TextInputAction.next,
              leading: const Icon(Icons.person_outline_rounded),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Mobile number',
              hint: '82 345 6789',
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              leading: Text(
                '+27',
                style: AppText.sans(15, color: AppColors.ink2),
              ),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Email',
              hint: 'thandi@mail.co.za',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              leading: const Icon(Icons.alternate_email_rounded),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Password',
              hint: 'At least 8 characters',
              controller: _password,
              obscureText: _obscure,
              helper: 'Use at least 8 characters with one number.',
              leading: const Icon(Icons.lock_outline_rounded),
              trailing: IconButton(
                splashRadius: 18,
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.ink3,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Haptics.selection();
                setState(() => _agree = !_agree);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 6,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: AppMotion.fast,
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: _agree ? AppColors.ink : Colors.transparent,
                        border: Border.all(
                          color: _agree ? AppColors.ink : AppColors.hair2,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: _agree
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: AppColors.bg,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppText.sans(
                            12,
                            color: AppColors.ink2,
                            height: 1.5,
                          ),
                          children: const [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 14,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _error!,
                      style: AppText.sans(13, color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      bottom: ActionBar(
        children: [
          PrimaryButton(
            label: 'Continue',
            full: true,
            size: BtnSize.lg,
            loading: _loading,
            trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
            onPressed: _agree ? _submit : null,
          ),
        ],
      ),
    );
  }
}
