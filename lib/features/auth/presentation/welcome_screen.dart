import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../shared/widgets/pinks_logo.dart';
import '../../../shared/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: kDarkHeroGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PinksLogo(
                    height: 32,
                    color: AppColors.accent,
                    showTagline: false,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '01 — BOOK',
                          style: AppText.sans(
                            11,
                            color: AppColors.accent,
                            weight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            style:
                                AppText.display(48, color: AppColors.darkInk),
                            children: [
                              const TextSpan(text: 'A considered\nwash,\n'),
                              TextSpan(
                                text: 'to your door.',
                                style: AppText.display(
                                  48,
                                  color: AppColors.accent,
                                  italic: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Text(
                            'Choose a service. Pick a slot. Our team arrives '
                            'with everything needed — you don\'t lift a finger.',
                            style: AppText.sans(
                              15,
                              color: const Color(0xFFC8C0B6),
                              height: 1.55,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: const [
                            _Dot(active: true),
                            SizedBox(width: 6),
                            _Dot(active: false),
                            SizedBox(width: 6),
                            _Dot(active: false),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: 'Create account',
                      full: true,
                      size: BtnSize.lg,
                      variant: BtnVariant.accent,
                      glow: true,
                      trailing: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                      onPressed: () => context.push('/signup'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: Colors.transparent,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: AppColors.darkHair.withValues(alpha: 0.8),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Haptics.light();
                            context.push('/login');
                          },
                          customBorder: const StadiumBorder(),
                          splashColor: Colors.white.withValues(alpha: 0.06),
                          highlightColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            child: Center(
                              child: Text(
                                'I already have one',
                                style: AppText.sans(
                                  15,
                                  color: AppColors.darkInk,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.standard,
        height: 3,
        decoration: BoxDecoration(
          color: active ? AppColors.accent : const Color(0xFF3A342C),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
