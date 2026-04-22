import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/auth_user.dart';
import '../../features/booking/data/booking_repository.dart';
import '../../features/booking/data/schedule_repository.dart';
import '../../features/booking/data/service_catalog_repository.dart';
import '../../features/booking/data/slot_calculator.dart';
import '../../features/booking/domain/address.dart';
import '../../features/booking/domain/booking.dart';
import '../../features/booking/domain/service_type.dart';
import '../../features/booking/domain/system_settings.dart';
import '../../features/garage/data/address_book_repository.dart';
import '../../features/garage/data/vehicle_repository.dart';
import '../../features/garage/domain/vehicle.dart';
import '../../features/payment/data/payment_service.dart';
import '../../features/payment/domain/saved_payment_method.dart';

// ---------- Repositories ---------------------------------------------------

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return InMemoryAuthRepository();
});

final serviceCatalogRepositoryProvider =
    Provider<ServiceCatalogRepository>((ref) {
  return InMemoryServiceCatalogRepository();
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return InMemoryScheduleRepository();
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return InMemoryBookingRepository();
});

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return InMemoryVehicleRepository();
});

final addressBookRepositoryProvider = Provider<AddressBookRepository>((ref) {
  return InMemoryAddressBookRepository();
});

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return FakePaymentService();
});

final slotCalculatorProvider = Provider<SlotCalculator>((ref) {
  return const SlotCalculator();
});

final systemSettingsProvider = Provider<SystemSettings>((ref) {
  return SystemSettings.defaults;
});

// ---------- Auth state -----------------------------------------------------

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges();
});

// ---------- Services catalogue --------------------------------------------

final servicesProvider = FutureProvider<List<ServiceType>>((ref) {
  final repo = ref.watch(serviceCatalogRepositoryProvider);
  return repo.listActive();
});

// ---------- Bookings -------------------------------------------------------

final customerBookingsProvider =
    StreamProvider<List<Booking>>((ref) {
  final auth = ref.watch(authStateProvider).asData?.value;
  final repo = ref.watch(bookingRepositoryProvider);
  if (auth == null) return const Stream.empty();
  return repo.watchForCustomer(auth.uid);
});

// ---------- Garage (vehicles + saved addresses) ---------------------------

final vehiclesProvider = StreamProvider<List<Vehicle>>((ref) {
  return ref.watch(vehicleRepositoryProvider).watch();
});

final savedAddressesProvider = StreamProvider<List<Address>>((ref) {
  return ref.watch(addressBookRepositoryProvider).watch();
});

// ---------- Preferences ----------------------------------------------------

/// App language preference. Two-letter code ("en", "af", "zu", …).
/// Kept in-memory for the prototype; wire to shared_preferences when real.
final languageProvider = StateProvider<String>((ref) => 'en');

// ---------- Saved payment methods -----------------------------------------

class SavedPaymentMethodsNotifier
    extends StateNotifier<List<SavedPaymentMethod>> {
  SavedPaymentMethodsNotifier()
      : super(const [
          SavedPaymentMethod(
            id: 'pm_1',
            kind: PaymentMethodKind.card,
            label: 'Personal Visa',
            brand: 'Visa',
            last4: '4242',
            expiry: '08/28',
            isDefault: true,
          ),
          SavedPaymentMethod(
            id: 'pm_2',
            kind: PaymentMethodKind.applePay,
            label: 'Apple Pay',
          ),
        ]);

  void add(SavedPaymentMethod method) {
    final isFirst = state.isEmpty;
    state = [...state, method.copyWith(isDefault: isFirst || method.isDefault)];
  }

  void remove(String id) {
    final removed = state.firstWhere(
      (m) => m.id == id,
      orElse: () => state.first,
    );
    final next = state.where((m) => m.id != id).toList();
    if (removed.isDefault && next.isNotEmpty) {
      next[0] = next[0].copyWith(isDefault: true);
    }
    state = next;
  }

  void setDefault(String id) {
    state = [
      for (final m in state) m.copyWith(isDefault: m.id == id),
    ];
  }
}

final savedPaymentMethodsProvider = StateNotifierProvider<
    SavedPaymentMethodsNotifier, List<SavedPaymentMethod>>((ref) {
  return SavedPaymentMethodsNotifier();
});
