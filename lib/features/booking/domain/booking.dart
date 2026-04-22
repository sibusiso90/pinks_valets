import 'package:flutter/foundation.dart';

import 'address.dart';

/// Booking status — matches the string enum in BuildSpec_MobileApp.md §3.1.
enum BookingStatus {
  pendingPayment('pending_payment'),
  confirmed('confirmed'),
  inProgress('in_progress'),
  completed('completed'),
  cancelledByCustomer('cancelled_by_customer'),
  cancelledByAdmin('cancelled_by_admin'),
  refunded('refunded'),
  noShow('no_show');

  const BookingStatus(this.wire);
  final String wire;

  static BookingStatus fromWire(String s) {
    return BookingStatus.values.firstWhere(
      (v) => v.wire == s,
      orElse: () => BookingStatus.pendingPayment,
    );
  }

  bool get isUpcoming =>
      this == BookingStatus.confirmed ||
      this == BookingStatus.pendingPayment ||
      this == BookingStatus.inProgress;

  bool get isDone =>
      this == BookingStatus.completed || this == BookingStatus.refunded;

  bool get isCancelled =>
      this == BookingStatus.cancelledByCustomer ||
      this == BookingStatus.cancelledByAdmin ||
      this == BookingStatus.noShow;
}

@immutable
class Booking {
  const Booking({
    required this.id,
    required this.customerId,
    required this.serviceId,
    required this.serviceName,
    required this.serviceDurationMinutes,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.address,
    required this.status,
    required this.priceCents,
    this.paymentId,
    this.cancellationFeeCents,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String serviceId;
  final String serviceName;
  final int serviceDurationMinutes;
  final DateTime date;
  final String startTime;
  final String endTime;
  final Address address;
  final BookingStatus status;
  final int priceCents;
  final String? paymentId;
  final int? cancellationFeeCents;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking copyWith({
    BookingStatus? status,
    int? cancellationFeeCents,
    String? paymentId,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id,
      customerId: customerId,
      serviceId: serviceId,
      serviceName: serviceName,
      serviceDurationMinutes: serviceDurationMinutes,
      date: date,
      startTime: startTime,
      endTime: endTime,
      address: address,
      status: status ?? this.status,
      priceCents: priceCents,
      paymentId: paymentId ?? this.paymentId,
      cancellationFeeCents: cancellationFeeCents ?? this.cancellationFeeCents,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
