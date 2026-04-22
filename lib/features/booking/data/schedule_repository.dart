import '../domain/schedule.dart';

abstract class ScheduleRepository {
  /// Returns the day's working hours + blocks. In v1 this is a simple
  /// function of the weekday — the admin portal will override days later.
  Future<DailySchedule> forDate(DateTime date);
}

class InMemoryScheduleRepository implements ScheduleRepository {
  @override
  Future<DailySchedule> forDate(DateTime date) async {
    // Weekly template: Mon–Fri 07:00–18:00 with a 12:00–13:00 lunch,
    // Sat 08:00–15:00 no lunch, Sun closed.
    final wd = date.weekday; // Mon = 1, Sun = 7
    if (wd == DateTime.sunday) {
      return DailySchedule(
        date: DateTime(date.year, date.month, date.day),
        isClosed: true,
        startTime: '00:00',
        endTime: '00:00',
        staffCount: 0,
        timeBlocks: const [],
      );
    }
    if (wd == DateTime.saturday) {
      return DailySchedule(
        date: DateTime(date.year, date.month, date.day),
        isClosed: false,
        startTime: '08:00',
        endTime: '15:00',
        staffCount: 2,
        timeBlocks: const [],
      );
    }
    return DailySchedule(
      date: DateTime(date.year, date.month, date.day),
      isClosed: false,
      startTime: '07:00',
      endTime: '18:00',
      staffCount: 2,
      timeBlocks: const [
        TimeBlock(
          startTime: '12:00',
          endTime: '13:00',
          reason: 'Lunch',
        ),
      ],
    );
  }
}
