import 'dart:async';

import '../../../core/utils/time_of_day.dart';
import '../domain/address.dart';
import '../domain/booking.dart';
import '../domain/service_type.dart';

abstract class BookingRepository {
  Stream<List<Booking>> watchForCustomer(String customerId);
  Future<List<Booking>> listForDate(DateTime date);
  Future<Booking> getById(String id);
  Future<Booking> create({
    required String customerId,
    required ServiceType service,
    required DateTime date,
    required String startTime,
    required Address address,
  });
  Future<Booking> cancel({
    required String id,
    required int feeCents,
  });
}

class InMemoryBookingRepository implements BookingRepository {
  InMemoryBookingRepository() {
    // Seed a demo upcoming booking for the default user so the home screen
    // and "My bookings" look alive before the first booking is made.
    _seed();
  }

  final _bookings = <String, Booking>{};
  final _controller = StreamController<List<Booking>>.broadcast();

  void _seed() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final lastMonth = DateTime(now.year, now.month - 1, 18);

    final demo1 = Booking(
      id: 'seed-1',
      customerId: 'uid_demo',
      serviceId: 'full-valet',
      serviceName: 'Full Valet',
      serviceDurationMinutes: 90,
      date: tomorrow,
      startTime: '10:30',
      endTime: '12:00',
      address: const Address(
        label: 'Home',
        street: '24 Oak Lane',
        suburb: 'Sandton',
        city: 'Johannesburg',
        postalCode: '2196',
      ),
      status: BookingStatus.confirmed,
      priceCents: 35000,
      paymentId: 'pay-seed-1',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 2)),
    );

    final demo2 = Booking(
      id: 'seed-2',
      customerId: 'uid_demo',
      serviceId: 'premium-detail',
      serviceName: 'Premium Detail',
      serviceDurationMinutes: 180,
      date: lastMonth,
      startTime: '09:00',
      endTime: '12:00',
      address: const Address(
        label: 'Home',
        street: '24 Oak Lane',
        suburb: 'Sandton',
        city: 'Johannesburg',
        postalCode: '2196',
      ),
      status: BookingStatus.completed,
      priceCents: 65000,
      paymentId: 'pay-seed-2',
      createdAt: lastMonth.subtract(const Duration(days: 5)),
      updatedAt: lastMonth,
    );

    _bookings[demo1.id] = demo1;
    _bookings[demo2.id] = demo2;
  }

  void _emit() {
    _controller.add(_bookings.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)));
  }

  @override
  Stream<List<Booking>> watchForCustomer(String customerId) async* {
    yield _bookings.values.where((b) => b.customerId == customerId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    yield* _controller.stream.map(
      (all) => all.where((b) => b.customerId == customerId).toList()
        ..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  @override
  Future<List<Booking>> listForDate(DateTime date) async {
    return _bookings.values
        .where((b) =>
            b.date.year == date.year &&
            b.date.month == date.month &&
            b.date.day == date.day &&
            !b.status.isCancelled)
        .toList();
  }

  @override
  Future<Booking> getById(String id) async {
    final b = _bookings[id];
    if (b == null) throw Exception('Booking $id not found');
    return b;
  }

  @override
  Future<Booking> create({
    required String customerId,
    required ServiceType service,
    required DateTime date,
    required String startTime,
    required Address address,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final startMin = parseMinutes(startTime);
    final endMin = startMin + service.durationMinutes;
    final endTime = formatMinutes(endMin);
    final id = 'bk-${DateTime.now().millisecondsSinceEpoch}';

    final b = Booking(
      id: id,
      customerId: customerId,
      serviceId: service.id,
      serviceName: service.name,
      serviceDurationMinutes: service.durationMinutes,
      date: DateTime(date.year, date.month, date.day),
      startTime: startTime,
      endTime: endTime,
      address: address,
      status: BookingStatus.pendingPayment,
      priceCents: service.priceCents,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _bookings[id] = b;
    _emit();
    return b;
  }

  @override
  Future<Booking> cancel({
    required String id,
    required int feeCents,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final existing = _bookings[id];
    if (existing == null) throw Exception('Booking $id not found');
    final updated = existing.copyWith(
      status: BookingStatus.cancelledByCustomer,
      cancellationFeeCents: feeCents,
      updatedAt: DateTime.now(),
    );
    _bookings[id] = updated;
    _emit();
    return updated;
  }

  /// Used internally by PaymentService after a successful payment.
  Future<Booking> markConfirmed(String id, String paymentId) async {
    final existing = _bookings[id];
    if (existing == null) throw Exception('Booking $id not found');
    final updated = existing.copyWith(
      status: BookingStatus.confirmed,
      paymentId: paymentId,
      updatedAt: DateTime.now(),
    );
    _bookings[id] = updated;
    _emit();
    return updated;
  }
}
