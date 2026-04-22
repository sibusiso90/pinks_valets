import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;
  bool _loading = false;

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
            Text('Reset your\npassword.', style: AppText.display(34)),
            const SizedBox(height: 10),
            Text(
              'Enter the email tied to your account. We\'ll send a secure '
              'link to reset your password.',
              style: AppText.sans(14, color: AppColors.ink3, height: 1.5),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Email',
              hint: 'thandi@mail.co.za',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              leading: const Icon(Icons.alternate_email_rounded),
            ),
            AnimatedSize(
              duration: AppMotion.medium,
              curve: AppMotion.standard,
              child: _sent
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.successSoft,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Link sent. Check your inbox.',
                                style: AppText.sans(
                                  13,
                                  color: AppColors.success,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      bottom: ActionBar(
        children: [
          PrimaryButton(
            label: _sent ? 'Resend link' : 'Send reset link',
            full: true,
            size: BtnSize.lg,
            loading: _loading,
            onPressed: () async {
              setState(() => _loading = true);
              await ref
                  .read(authRepositoryProvider)
                  .requestPasswordReset(_email.text.trim());
              if (!mounted) return;
              setState(() {
                _loading = false;
                _sent = true;
              });
            },
          ),
          const SizedBox(height: 6),
          AppLinkButton(
            label: 'Back to sign in',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
