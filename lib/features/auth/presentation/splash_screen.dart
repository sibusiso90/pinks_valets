import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/pinks_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      context.go('/welcome');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: kDarkHeroGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _ctrl,
                    curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                  ),
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _ctrl,
                      curve: const Interval(
                        0.0,
                        0.7,
                        curve: AppMotion.spring,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PinksLogo(height: 96, color: AppColors.accent),
                        const SizedBox(height: 24),
                        Text(
                          'MOBILE CAR CARE',
                          style: AppText.sans(
                            12,
                            color: AppColors.ink3,
                            weight: FontWeight.w600,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 60,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _ctrl,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                  ),
                  child: Center(
                    child: Text(
                      'WARMING UP',
                      style: AppText.sans(
                        11,
                        color: AppColors.ink3,
                        weight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
