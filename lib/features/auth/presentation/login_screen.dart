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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifier = TextEditingController(text: 'thandi@mail.co.za');
  final _password = TextEditingController(text: 'password');
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signIn(
            identifier: _identifier.text.trim(),
            password: _password.text,
          );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      setState(() => _error = 'Could not sign in. Try again.');
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
          8,
          AppSpacing.screenH + 4,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome back.', style: AppText.display(34)),
            const SizedBox(height: 10),
            Text(
              'Sign in to manage your bookings.',
              style: AppText.sans(14, color: AppColors.ink3, height: 1.45),
            ),
            const SizedBox(height: 28),
            AppTextField(
              label: 'Email or mobile',
              hint: 'thandi@mail.co.za',
              controller: _identifier,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              leading: const Icon(Icons.alternate_email_rounded),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Password',
              hint: '••••••••',
              controller: _password,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
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
            Align(
              alignment: Alignment.centerRight,
              child: AppLinkButton(
                label: 'Forgot password?',
                onPressed: () => context.push('/forgot-password'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
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
            label: 'Sign in',
            full: true,
            size: BtnSize.lg,
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 14),
          Center(
            child: InkWell(
              onTap: () {
                Haptics.selection();
                context.push('/signup');
              },
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: RichText(
                  text: TextSpan(
                    style: AppText.sans(13, color: AppColors.ink3),
                    children: [
                      const TextSpan(text: 'New here? '),
                      TextSpan(
                        text: 'Create an account',
                        style: AppText.sans(
                          13,
                          color: AppColors.ink,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
