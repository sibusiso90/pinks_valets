import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/address.dart';
import '../domain/service_type.dart';

/// In-memory snapshot of the booking the customer is currently building.
///
/// Each step (service → date → time → address) updates this, and the
/// summary / payment screens read it. It resets after a successful booking.
class BookingDraft {
  const BookingDraft({
    this.service,
    this.date,
    this.startTime,
    this.address,
  });

  final ServiceType? service;
  final DateTime? date;
  final String? startTime;
  final Address? address;

  BookingDraft copyWith({
    ServiceType? service,
    DateTime? date,
    String? startTime,
    Address? address,
  }) {
    return BookingDraft(
      service: service ?? this.service,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      address: address ?? this.address,
    );
  }

  BookingDraft cleared() => const BookingDraft();
}

class BookingDraftController extends StateNotifier<BookingDraft> {
  BookingDraftController() : super(const BookingDraft());

  void setService(ServiceType s) => state = state.copyWith(service: s);
  void setDate(DateTime d) =>
      state = state.copyWith(date: DateTime(d.year, d.month, d.day));
  void setStartTime(String t) => state = state.copyWith(startTime: t);
  void setAddress(Address a) => state = state.copyWith(address: a);
  void clear() => state = state.cleared();
}

final bookingDraftProvider =
    StateNotifierProvider<BookingDraftController, BookingDraft>((ref) {
  return BookingDraftController();
});
