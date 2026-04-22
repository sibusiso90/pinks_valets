import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final _search = TextEditingController();
  String _query = '';

  static const _faqs = <_Faq>[
    _Faq(
      category: 'Bookings',
      question: 'How do I book a wash?',
      answer:
          'Tap "Book a wash" on the home screen. Pick a service, pick a time '
          'slot, add the address, then confirm. Our valet is dispatched the '
          'moment you pay.',
    ),
    _Faq(
      category: 'Bookings',
      question: 'Can I reschedule or cancel?',
      answer:
          'Yes — up to 2 hours before the slot from the booking details '
          'screen. Cancellations within 2 hours are charged 50%; after the '
          'valet has arrived, the wash is charged in full.',
    ),
    _Faq(
      category: 'Bookings',
      question: 'What if the weather changes?',
      answer:
          'If it rains during an exterior wash, we\'ll reschedule at no extra '
          'cost. Interior-only services carry on as planned.',
    ),
    _Faq(
      category: 'Payments',
      question: 'Which payment methods do you support?',
      answer:
          'Visa, Mastercard, Amex, Apple Pay, Google Pay, and Instant EFT '
          'via Ozow. Cards are tokenised by our PSP — we never store your '
          'full card number.',
    ),
    _Faq(
      category: 'Payments',
      question: 'When am I charged?',
      answer:
          'At the end of booking. If the wash is cancelled within the free '
          'window, you\'re refunded instantly.',
    ),
    _Faq(
      category: 'Service',
      question: 'What does a Premium wash include?',
      answer:
          'Exterior hand wash, wheels and tyres, interior vacuum, dashboard '
          'wipe, and windows inside and out. Leather conditioning is bundled '
          'with the Detail package.',
    ),
    _Faq(
      category: 'Service',
      question: 'How long does a wash take?',
      answer:
          'A Signature wash is 45–60 min, Premium is 75–90 min, and a full '
          'Detail runs 2–3 hours. Exact times depend on your car\'s size.',
    ),
    _Faq(
      category: 'Account',
      question: 'How do I change my phone number?',
      answer:
          'Open Profile → tap the identity card → Edit profile. You\'ll '
          'verify the new number with an OTP.',
    ),
    _Faq(
      category: 'Account',
      question: 'Can I delete my account?',
      answer:
          'Yes. Chat to us from the Support section and we\'ll action it '
          'within 7 days per POPIA. Completed bookings are kept for tax '
          'reasons as required by SARS.',
    ),
  ];

  List<_Faq> get _filtered {
    if (_query.trim().isEmpty) return _faqs;
    final q = _query.toLowerCase();
    return _faqs
        .where((f) =>
            f.question.toLowerCase().contains(q) ||
            f.answer.toLowerCase().contains(q) ||
            f.category.toLowerCase().contains(q))
        .toList();
  }

  Map<String, List<_Faq>> get _grouped {
    final out = <String, List<_Faq>>{};
    for (final f in _filtered) {
      out.putIfAbsent(f.category, () => []).add(f);
    }
    return out;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;

    return AppScaffold(
      title: 'Help & FAQ',
      large: true,
      subtitle: 'Quick answers. If you\'re still stuck, our team is a tap '
          'away.',
      back: () => context.pop(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          4,
          AppSpacing.screenH,
          32,
        ),
        children: [
          AppTextField(
            hint: 'Search help articles',
            controller: _search,
            leading: const Icon(Icons.search_rounded),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 20),
          if (_filtered.isEmpty)
            _NoResults(query: _query)
          else ...[
            for (final entry in grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 0, 10),
                child: Text(
                  entry.key.toUpperCase(),
                  style: AppText.eyebrow(size: 11),
                ),
              ),
              AppCard(
                pad: 0,
                child: Column(
                  children: [
                    for (var i = 0; i < entry.value.length; i++) ...[
                      _FaqTile(
                        faq: entry.value[i],
                        roundedTop: i == 0,
                        roundedBottom: i == entry.value.length - 1,
                      ),
                      if (i < entry.value.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Divider(height: 1, color: AppColors.hair),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
          const SizedBox(height: 4),
          _ContactCard(),
        ],
      ),
    );
  }
}

class _Faq {
  const _Faq({
    required this.category,
    required this.question,
    required this.answer,
  });
  final String category;
  final String question;
  final String answer;
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({
    required this.faq,
    required this.roundedTop,
    required this.roundedBottom,
  });
  final _Faq faq;
  final bool roundedTop;
  final bool roundedBottom;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Haptics.selection();
          setState(() => _open = !_open);
        },
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.roundedTop ? AppRadius.lg : 0),
          bottom: Radius.circular(widget.roundedBottom ? AppRadius.lg : 0),
        ),
        splashColor: AppColors.accentSoft,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: AppText.sans(15, weight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    duration: AppMotion.fast,
                    turns: _open ? 0.5 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.ink2,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: AppMotion.fast,
                curve: AppMotion.standard,
                alignment: Alignment.topLeft,
                child: _open
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          widget.faq.answer,
                          style: AppText.sans(
                            14,
                            color: AppColors.ink2,
                            height: 1.55,
                          ),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kInkHeroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadow.lg,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STILL NEED HELP?',
            style: AppText.eyebrow(
              size: 11,
              color: AppColors.bg.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We reply fast.',
            style: AppText.display(28, color: AppColors.bg),
          ),
          const SizedBox(height: 6),
          Text(
            'Chat to a human, Mon–Sat from 07:00–18:00. '
            'Typical reply under 3 minutes.',
            style: AppText.sans(
              13,
              color: AppColors.bg.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Chat with us',
                  full: true,
                  variant: BtnVariant.accent,
                  leading: const Icon(Icons.chat_bubble_rounded, size: 16),
                  onPressed: () => context.push('/chat'),
                ),
              ),
              const SizedBox(width: 10),
              _DarkIconButton(
                icon: Icons.call_rounded,
                onPressed: () {
                  Haptics.selection();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Calling +27 10 442 0010…'),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkIconButton extends StatelessWidget {
  const _DarkIconButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: SizedBox(
          width: 54,
          height: 54,
          child: Icon(icon, color: AppColors.bg, size: 20),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.search_off_rounded,
              size: 32,
              color: AppColors.ink2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No matches for "$query"',
            style: AppText.sans(15, weight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different phrase, or chat to our team.',
            style: AppText.sans(13, color: AppColors.ink3),
          ),
        ],
      ),
    );
  }
}
