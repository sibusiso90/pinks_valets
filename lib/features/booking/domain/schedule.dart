import 'package:flutter/foundation.dart';

@immutable
class TimeBlock {
  const TimeBlock({
    required this.startTime,
    required this.endTime,
    required this.reason,
  });

  final String startTime; // HH:mm
  final String endTime;   // HH:mm
  final String reason;
}

/// One day of working hours + any ad-hoc blocks.
/// Mirrors Firestore `daily_schedules/{YYYY-MM-DD}`.
@immutable
class DailySchedule {
  const DailySchedule({
    required this.date,
    required this.isClosed,
    required this.startTime,
    required this.endTime,
    required this.staffCount,
    required this.timeBlocks,
  });

  final DateTime date;
  final bool isClosed;
  final String startTime; // HH:mm
  final String endTime;   // HH:mm
  final int staffCount;
  final List<TimeBlock> timeBlocks;
}
