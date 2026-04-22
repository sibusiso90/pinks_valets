/// Small helpers for "HH:mm" time strings.
///
/// We represent times in the booking system as 24-hour "HH:mm" strings because
/// Firestore is happier with them than with raw Dart `DateTime`s and the
/// admin portal uses the same representation. We always interpret them in
/// Africa/Johannesburg (handled at the edges).
int parseMinutes(String hhmm) {
  final parts = hhmm.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

String formatMinutes(int minutesFromMidnight) {
  final h = (minutesFromMidnight ~/ 60).toString().padLeft(2, '0');
  final m = (minutesFromMidnight % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

String formatDurationShort(int minutes) {
  if (minutes < 60) return '${minutes}min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}
