import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/segmented_tabs.dart';

class TermsPrivacyScreen extends StatefulWidget {
  const TermsPrivacyScreen({super.key, this.initial = 'terms'});
  final String initial;

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  late String _tab = widget.initial;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Terms & privacy',
      large: true,
      subtitle: 'Last updated 12 March 2026 · v1.4',
      back: () => context.pop(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              4,
              AppSpacing.screenH,
              16,
            ),
            child: SegmentedTabs(
              active: _tab,
              segments: const [
                SegmentedTab('terms', 'Terms of Service'),
                SegmentedTab('privacy', 'Privacy Policy'),
              ],
              onChanged: (id) => setState(() => _tab = id),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              child: _tab == 'terms'
                  ? const _TermsContent(key: ValueKey('terms'))
                  : const _PrivacyContent(key: ValueKey('privacy')),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        0,
        AppSpacing.screenH,
        32,
      ),
      children: const [
        _LegalSection(
          title: 'The quick version',
          body:
              'You book a wash in the app. We send a vetted valet to wash '
              'your car at the time and place you chose. Treat our team '
              'respectfully, keep your valuables safe, and we\'ll do the '
              'same for your car.',
        ),
        _LegalSection(
          title: '1. Bookings and cancellations',
          body:
              'A booking is confirmed once payment is captured. You can '
              'reschedule or cancel free of charge up to 2 hours before the '
              'wash. Cancellations within 2 hours are charged 50% of the '
              'service fee. Once the valet has arrived, the service is '
              'charged in full.',
        ),
        _LegalSection(
          title: '2. Pricing',
          body:
              'All prices are quoted in South African Rand and include VAT. '
              'Larger vehicles (bakkies, SUVs, 7-seaters) may attract a '
              'size uplift shown before you confirm. Add-ons are billed '
              'per booking, not per session.',
        ),
        _LegalSection(
          title: '3. Service area',
          body:
              'We currently operate in select Johannesburg suburbs. If we '
              'can\'t reach your address we\'ll cancel at no charge. Street '
              'addresses with secure access (gates, booms, shared '
              'driveways) remain your responsibility to authorise.',
        ),
        _LegalSection(
          title: '4. Damage and liability',
          body:
              'Our valets are trained and insured. If damage occurs during '
              'a service that is directly attributable to our work, report '
              'it within 24 hours and we\'ll assess and resolve it — either '
              'through repair, refund, or our insurer. We don\'t cover '
              'pre-existing damage, consumable wear, or items left inside '
              'the vehicle.',
        ),
        _LegalSection(
          title: '5. Tips and extras',
          body:
              'Tips are never expected and 100% go to the valet. If you\'d '
              'like to add a tip, you\'ll be prompted after the booking is '
              'completed.',
        ),
        _LegalSection(
          title: '6. Account',
          body:
              'You\'re responsible for keeping your account credentials '
              'safe. Let us know immediately if you suspect unauthorised '
              'access. We may suspend accounts that abuse the service, our '
              'staff, or our customers.',
        ),
        _LegalSection(
          title: '7. Governing law',
          body:
              'These terms are governed by the laws of South Africa. '
              'Disputes are heard in the Gauteng division, unless we both '
              'agree to an alternative forum.',
        ),
        SizedBox(height: 12),
        _LegalFooter(),
      ],
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        0,
        AppSpacing.screenH,
        32,
      ),
      children: const [
        _LegalSection(
          title: 'In plain language',
          body:
              'We only collect what we need to dispatch a valet to your car '
              'and process your payment. We don\'t sell your data. You can '
              'export or delete your account at any time.',
        ),
        _LegalSection(
          title: 'What we collect',
          body:
              'Your name, phone number, email, vehicle and address details, '
              'booking history, approximate device location for the '
              '"valet arriving" updates, and a tokenised reference to '
              'your payment method (never the full card number).',
        ),
        _LegalSection(
          title: 'How we use it',
          body:
              'To run your bookings, message you about arrival and '
              'completion, keep fraud out of the system, and improve our '
              'service. We send marketing emails only if you opt in — and '
              'you can unsubscribe from any message.',
        ),
        _LegalSection(
          title: 'Who we share with',
          body:
              'The valet assigned to your wash sees only the details they '
              'need: your first name, car, address, and time. Our payment '
              'processor (Stripe / Ozow) sees the payment data. We share '
              'information with the authorities only when legally required.',
        ),
        _LegalSection(
          title: 'Where data lives',
          body:
              'Data is stored on servers inside South Africa where '
              'possible, and otherwise in compliant regions. It is '
              'encrypted at rest and in transit.',
        ),
        _LegalSection(
          title: 'Your rights under POPIA',
          body:
              'You can request a copy of the data we hold about you, '
              'correct it, or ask us to delete it. Chat to our support '
              'team from the Help section and we\'ll respond within 7 '
              'business days.',
        ),
        _LegalSection(
          title: 'Cookies & analytics',
          body:
              'We use privacy-respecting analytics to understand which '
              'screens work and which don\'t. No advertising trackers. No '
              'third-party ad SDKs.',
        ),
        SizedBox(height: 12),
        _LegalFooter(),
      ],
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppText.sans(
              16,
              weight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppText.sans(14, color: AppColors.ink2, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      pad: 16,
      backgroundColor: AppColors.surfaceAlt,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions?',
            style: AppText.sans(14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Email legal@pinksvalets.co.za or chat to us from the Help & '
            'FAQ screen. We\'re happy to walk you through any of this.',
            style: AppText.sans(13, color: AppColors.ink2, height: 1.55),
          ),
        ],
      ),
    );
  }
}
