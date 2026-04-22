import 'package:flutter_test/flutter_test.dart';
import 'package:pinks_valets/features/booking/data/slot_calculator.dart';
import 'package:pinks_valets/features/booking/domain/booking.dart';
import 'package:pinks_valets/features/booking/domain/address.dart';
import 'package:pinks_valets/features/booking/domain/schedule.dart';

DailySchedule _schedule({
  DateTime? date,
  bool closed = false,
  String start = '08:00',
  String end = '17:00',
  List<TimeBlock> blocks = const [],
}) {
  return DailySchedule(
    date: date ?? DateTime(2026, 4, 15),
    isClosed: closed,
    startTime: start,
    endTime: end,
    staffCount: 2,
    timeBlocks: blocks,
  );
}

Booking _booking({
  required String startTime,
  required int durationMinutes,
  DateTime? date,
}) {
  final start = startTime;
  final startMin = int.parse(start.split(':')[0]) * 60 +
      int.parse(start.split(':')[1]);
  final endMin = startMin + durationMinutes;
  final endH = (endMin ~/ 60).toString().padLeft(2, '0');
  final endM = (endMin % 60).toString().padLeft(2, '0');
  return Booking(
    id: 'b',
    customerId: 'c',
    serviceId: 's',
    serviceName: 'Full Valet',
    serviceDurationMinutes: durationMinutes,
    date: date ?? DateTime(2026, 4, 15),
    startTime: start,
    endTime: '$endH:$endM',
    address: const Address(
      label: 'Home',
      street: '1 A',
      suburb: 'Sandton',
      city: 'Johannesburg',
      postalCode: '2196',
    ),
    status: BookingStatus.confirmed,
    priceCents: 35000,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  const calc = SlotCalculator();
  // Pin "now" far in the past so we never trip the lead-time filter unless
  // a specific test wants to.
  final longAgo = DateTime(2020, 1, 1, 6);

  group('SlotCalculator', () {
    test('empty day returns full set of slots in 30-min increments', () {
      final slots = calc.calculateAvailableStartTimes(
        schedule: _schedule(),
        existingBookings: const [],
        serviceDurationMinutes: 90,
        travelBufferMinutes: 20,
        slotIncrementMinutes: 30,
        now: longAgo,
      );

      // Working 08:00–17:00, service 90min + 20min buffer = 110min span
      // required. Last valid start = 17:00 - 110 = 15:10 → rounded down to
      // last 30-min boundary that fits = 15:00.
      expect(slots.first, '08:00');
      expect(slots.last, '15:00');
      expect(slots.contains('10:30'), true);
      expect(slots.contains('15:30'), false);
    });

    test('day with a lunch block excludes overlap', () {
      final slots = calc.calculateAvailableStartTimes(
        schedule: _schedule(
          blocks: const [
            TimeBlock(
              startTime: '12:00',
              endTime: '13:00',
              reason: 'Lunch',
            ),
          ],
        ),
        existingBookings: const [],
        serviceDurationMinutes: 60,
        travelBufferMinutes: 20,
        slotIncrementMinutes: 30,
        now: longAgo,
      );

      // A 60+20 job starting at 11:00 would finish 12:20 — overlaps lunch.
      expect(slots.contains('11:00'), false);
      // 10:30 → finishes 11:50. Fits before lunch. ✅
      expect(slots.contains('10:30'), true);
      // 13:00 → finishes 14:20. Fits after lunch. ✅
      expect(slots.contains('13:00'), true);
    });

    test('existing booking carves out time + travel buffer', () {
      final slots = calc.calculateAvailableStartTimes(
        schedule: _schedule(),
        existingBookings: [
          _booking(startTime: '10:00', durationMinutes: 90),
        ],
        serviceDurationMinutes: 60,
        travelBufferMinutes: 20,
        slotIncrementMinutes: 30,
        now: longAgo,
      );

      // Booking 10:00–11:30, buffer +20 → 11:50 free.
      // Rounded up to 12:00 slot boundary.
      expect(slots.contains('10:00'), false);
      expect(slots.contains('11:00'), false);
      expect(slots.contains('11:30'), false);
      expect(slots.contains('12:00'), true);
    });

    test('fully booked day returns empty list', () {
      final slots = calc.calculateAvailableStartTimes(
        schedule: _schedule(start: '08:00', end: '10:00'),
        existingBookings: [
          _booking(startTime: '08:00', durationMinutes: 90),
        ],
        serviceDurationMinutes: 30,
        travelBufferMinutes: 20,
        slotIncrementMinutes: 30,
        now: longAgo,
      );

      // Booking 08:00–09:30 + 20min buffer reaches 09:50. Day ends 10:00.
      // A 30-min service + 20-min buffer (50 min total) can't start by 09:50.
      expect(slots, isEmpty);
    });

    test('service longer than day returns empty', () {
      final slots = calc.calculateAvailableStartTimes(
        schedule: _schedule(start: '09:00', end: '10:00'),
        existingBookings: const [],
        serviceDurationMinutes: 180,
        travelBufferMinutes: 0,
        slotIncrementMinutes: 30,
        now: longAgo,
      );
      expect(slots, isEmpty);
    });

    test('"today" respects minimum 2h lead time', () {
      final today = DateTime(2026, 4, 15);
      final now = DateTime(2026, 4, 15, 9, 31);

      final slots = calc.calculateAvailableStartTimes(
        schedule: _schedule(date: today),
        existingBookings: const [],
        serviceDurationMinutes: 60,
        travelBufferMinutes: 20,
        slotIncrementMinutes: 30,
        now: now,
      );

      // 9:31 + 2h = 11:31 earliest → next 30-min boundary is 12:00.
      expect(slots.first, '12:00');
      // 11:30 would violate the lead time (< 2h away) so must be excluded.
      expect(slots.contains('11:30'), false);
    });

    test('"today" allows slot exactly at lead-time boundary', () {
      final today = DateTime(2026, 4, 15);
      final now = DateTime(2026, 4, 15, 9, 30);

      final slots = calc.calculateAvailableStartTimes(
        schedule: _schedule(date: today),
        existingBookings: const [],
        serviceDurationMinutes: 60,
        travelBufferMinutes: 20,
        slotIncrementMinutes: 30,
        now: now,
      );

      // 11:30 is exactly 2h away — inclusive — so it's valid.
      expect(slots.first, '11:30');
    });

    test('closed day returns empty list', () {
      final slots = calc.calculateAvailableStartTimes(
        schedule: _schedule(closed: true),
        existingBookings: const [],
        serviceDurationMinutes: 60,
        travelBufferMinutes: 20,
        slotIncrementMinutes: 30,
        now: longAgo,
      );
      expect(slots, isEmpty);
    });

    test('15-min increments produce denser slots than 30-min', () {
      final at15 = calc.calculateAvailableStartTimes(
        schedule: _schedule(),
        existingBookings: const [],
        serviceDurationMinutes: 60,
        travelBufferMinutes: 20,
        slotIncrementMinutes: 15,
        now: longAgo,
      );
      final at30 = calc.calculateAvailableStartTimes(
        schedule: _schedule(),
        existingBookings: const [],
        serviceDurationMinutes: 60,
        travelBufferMinutes: 20,
        slotIncrementMinutes: 30,
        now: longAgo,
      );

      // The 15-min set should be a strict superset of the 30-min set.
      for (final slot in at30) {
        expect(at15, contains(slot));
      }
      expect(at15.length, greaterThan(at30.length));
    });
  });
}
