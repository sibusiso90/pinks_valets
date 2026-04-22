import 'package:flutter/foundation.dart';

@immutable
class CancellationRule {
  const CancellationRule({
    required this.hoursBefore,
    required this.feeType,
    required this.feeValue,
  });

  final int hoursBefore;       // cancelling >= this many hours before incurs the fee
  final String feeType;        // "percentage" | "fixed"
  final double feeValue;
}

/// Live copy of `system_settings/config`.
@immutable
class SystemSettings {
  const SystemSettings({
    required this.travelBufferMinutes,
    required this.slotIncrementMinutes,
    required this.bookingWindowDays,
    required this.minimumLeadHours,
    required this.serviceAreaSuburbs,
    required this.cancellationRules,
  });

  final int travelBufferMinutes;
  final int slotIncrementMinutes;
  final int bookingWindowDays;
  final int minimumLeadHours;
  final List<String> serviceAreaSuburbs;
  final List<CancellationRule> cancellationRules;

  static const SystemSettings defaults = SystemSettings(
    travelBufferMinutes: 20,
    slotIncrementMinutes: 30,
    bookingWindowDays: 30,
    minimumLeadHours: 2,
    serviceAreaSuburbs: [
      'Sandton',
      'Rosebank',
      'Morningside',
      'Bryanston',
      'Hyde Park',
      'Fourways',
      'Rivonia',
      'Parkhurst',
      'Melrose',
      'Illovo',
      'Craighall',
      'Dunkeld',
      'Parkmore',
      'Saxonwold',
    ],
    cancellationRules: [
      CancellationRule(hoursBefore: 24, feeType: 'fixed', feeValue: 0),
      CancellationRule(hoursBefore: 2, feeType: 'fixed', feeValue: 5000),
      CancellationRule(hoursBefore: 0, feeType: 'percentage', feeValue: 50),
    ],
  );
}
