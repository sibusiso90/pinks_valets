import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/otp_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/booking/presentation/address_screen.dart';
import '../features/booking/presentation/confirmation_screen.dart';
import '../features/booking/presentation/date_picker_screen.dart';
import '../features/booking/presentation/service_select_screen.dart';
import '../features/booking/presentation/summary_screen.dart';
import '../features/booking/presentation/time_picker_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/garage/presentation/addresses_screen.dart';
import '../features/garage/presentation/my_cars_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/my_bookings/presentation/my_bookings_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/payment/presentation/payment_methods_screen.dart';
import '../features/payment/presentation/payment_screen.dart';
import '../features/profile/presentation/help_faq_screen.dart';
import '../features/profile/presentation/language_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/terms_privacy_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, _) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (_, _) => const OtpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        path: '/book/service',
        builder: (_, _) => const ServiceSelectScreen(),
      ),
      GoRoute(
        path: '/book/date',
        builder: (_, _) => const DatePickerScreen(),
      ),
      GoRoute(
        path: '/book/time',
        builder: (_, _) => const TimePickerScreen(),
      ),
      GoRoute(
        path: '/book/address',
        builder: (_, _) => const AddressScreen(),
      ),
      GoRoute(
        path: '/book/summary',
        builder: (_, _) => const SummaryScreen(),
      ),
      GoRoute(
        path: '/book/payment',
        builder: (_, _) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/book/confirmation',
        builder: (ctx, state) {
          final id = state.uri.queryParameters['bookingId'] ?? '';
          return ConfirmationScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: '/my-bookings',
        builder: (_, _) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/cars',
        builder: (_, _) => const MyCarsScreen(),
      ),
      GoRoute(
        path: '/addresses',
        builder: (_, _) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (_, _) => const ChatScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/payment-methods',
        builder: (_, _) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/language',
        builder: (_, _) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (_, _) => const HelpFaqScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (ctx, state) {
          final initial = state.uri.queryParameters['tab'] ?? 'terms';
          return TermsPrivacyScreen(initial: initial);
        },
      ),
    ],
  );
});
