import 'package:collection/collection.dart';

import '../../../core/utils/time_of_day.dart';
import '../domain/booking.dart';
import '../domain/schedule.dart';

/// Calculates which start times a customer can pick for a given date and
/// service, given the day's working hours, blocks, and existing bookings.
///
/// Algorithm (from BuildSpec_MobileApp.md §5):
///   1. If the day is closed, return empty.
///   2. Build free-time intervals = [start_time, end_time] minus each
///      time block AND each existing booking (with travel buffer appended).
///   3. For each free interval, generate candidate starts at slot_increment
///      steps. Keep a candidate if start + duration + buffer fits inside.
///   4. For "today", respect a minimum lead time (default 2h from now).
class SlotCalculator {
  const SlotCalculator();

  List<String> calculateAvailableStartTimes({
    required DailySchedule schedule,
    required List<Booking> existingBookings,
    required int serviceDurationMinutes,
    required int travelBufferMinutes,
    required int slotIncrementMinutes,
    DateTime? now,
    int minimumLeadHours = 2,
  }) {
    if (schedule.isClosed) return const [];

    final dayStart = parseMinutes(schedule.startTime);
    final dayEnd = parseMinutes(schedule.endTime);
    if (dayEnd <= dayStart) return const [];

    // 1. Start with one free interval — the full working day.
    var intervals = <_Interval>[_Interval(dayStart, dayEnd)];

    // 2. Subtract time blocks.
    for (final block in schedule.timeBlocks) {
      final bStart = parseMinutes(block.startTime);
      final bEnd = parseMinutes(block.endTime);
      intervals = _subtract(intervals, bStart, bEnd);
    }

    // 3. Subtract bookings + travel buffer.
    // (Travel buffer is time the team needs to pack up and drive to the next
    // job — so we reserve it AFTER each booking.)
    for (final booking in existingBookings) {
      if (!_sameDate(booking.date, schedule.date)) continue;
      final s = parseMinutes(booking.startTime);
      final e = parseMinutes(booking.endTime) + travelBufferMinutes;
      intervals = _subtract(intervals, s, e);
    }

    // 4. If the calendar date is today, also subtract everything before
    //    (now + minimum lead time).
    final today = now ?? DateTime.now();
    if (_sameDate(today, schedule.date)) {
      final earliest =
          today.hour * 60 + today.minute + minimumLeadHours * 60;
      intervals = _subtract(intervals, -1, earliest);
    }

    // 5. Walk each interval and pull out candidate start times.
    //    A candidate is valid if start + duration + buffer fits.
    final slots = <int>[];
    final requiredSpan = serviceDurationMinutes + travelBufferMinutes;
    for (final iv in intervals) {
      // Round candidate start up to the next slot increment boundary.
      final firstCandidate =
          _ceilToIncrement(iv.start, slotIncrementMinutes);
      for (var t = firstCandidate;
          t + requiredSpan <= iv.end;
          t += slotIncrementMinutes) {
        slots.add(t);
      }
    }

    slots.sort();
    return slots.map(formatMinutes).toList(growable: false);
  }

  // Given a list of intervals and a (start, end) to remove, split any
  // intervals that overlap with it and drop any that are wholly inside.
  List<_Interval> _subtract(
    List<_Interval> intervals,
    int removeStart,
    int removeEnd,
  ) {
    final out = <_Interval>[];
    for (final iv in intervals) {
      if (removeEnd <= iv.start || removeStart >= iv.end) {
        // No overlap.
        out.add(iv);
      } else if (removeStart <= iv.start && removeEnd >= iv.end) {
        // Removal swallows the interval entirely — drop it.
      } else if (removeStart > iv.start && removeEnd < iv.end) {
        // Removal splits the interval into two pieces.
        out.add(_Interval(iv.start, removeStart));
        out.add(_Interval(removeEnd, iv.end));
      } else if (removeStart <= iv.start) {
        // Trim the front.
        out.add(_Interval(removeEnd, iv.end));
      } else {
        // Trim the back.
        out.add(_Interval(iv.start, removeStart));
      }
    }
    return out.sorted((a, b) => a.start.compareTo(b.start));
  }

  int _ceilToIncrement(int value, int increment) {
    if (increment <= 0) return value;
    final r = value % increment;
    if (r == 0) return value;
    return value + (increment - r);
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _Interval {
  const _Interval(this.start, this.end);
  final int start; // minutes from midnight
  final int end;
}
