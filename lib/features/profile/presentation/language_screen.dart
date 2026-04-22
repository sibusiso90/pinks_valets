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

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  static const _languages = <_Lang>[
    _Lang('en', 'English', 'English', 'en_ZA'),
    _Lang('af', 'Afrikaans', 'Afrikaans', 'af_ZA'),
    _Lang('zu', 'isiZulu', 'IsiZulu', 'zu_ZA'),
    _Lang('xh', 'isiXhosa', 'IsiXhosa', 'xh_ZA'),
    _Lang('st', 'Sesotho', 'Sesotho', 'st_ZA'),
    _Lang('tn', 'Setswana', 'Setswana', 'tn_ZA'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageProvider);

    return AppScaffold(
      title: 'Language',
      large: true,
      subtitle: 'Choose how the app talks to you. We translate prices, '
          'dates, and messages.',
      back: () => context.pop(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          4,
          AppSpacing.screenH,
          24,
        ),
        children: [
          Text('APP LANGUAGE', style: AppText.eyebrow(size: 11)),
          const SizedBox(height: 10),
          AppCard(
            pad: 0,
            child: Column(
              children: [
                for (var i = 0; i < _languages.length; i++) ...[
                  _LanguageRow(
                    lang: _languages[i],
                    selected: _languages[i].code == current,
                    onTap: () {
                      Haptics.selection();
                      ref.read(languageProvider.notifier).state =
                          _languages[i].code;
                    },
                    roundedTop: i == 0,
                    roundedBottom: i == _languages.length - 1,
                  ),
                  if (i < _languages.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Divider(height: 1, color: AppColors.hair),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.ink2,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Some messages from our valets may still come through in '
                    'English while they confirm your booking.',
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
    );
  }
}

class _Lang {
  const _Lang(this.code, this.nativeName, this.englishName, this.locale);
  final String code;
  final String nativeName;
  final String englishName;
  final String locale;
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.lang,
    required this.selected,
    required this.onTap,
    required this.roundedTop,
    required this.roundedBottom,
  });

  final _Lang lang;
  final bool selected;
  final VoidCallback onTap;
  final bool roundedTop;
  final bool roundedBottom;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(roundedTop ? AppRadius.lg : 0),
          bottom: Radius.circular(roundedBottom ? AppRadius.lg : 0),
        ),
        splashColor: AppColors.accentSoft,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected ? AppColors.ink : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  lang.code.toUpperCase(),
                  style: AppText.sans(
                    12,
                    weight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: selected ? AppColors.bg : AppColors.ink2,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.nativeName,
                      style: AppText.sans(15, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lang.englishName,
                      style: AppText.sans(12, color: AppColors.ink3),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: AppMotion.fast,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.accent : Colors.transparent,
                  border: selected
                      ? null
                      : Border.all(color: AppColors.hair2, width: 1.5),
                ),
                alignment: Alignment.center,
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
