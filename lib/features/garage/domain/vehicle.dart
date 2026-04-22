import 'package:flutter/foundation.dart';

/// A customer's vehicle in the garage.
/// `id` is local-only for now; swap to Firestore doc id when wiring Firebase.
@immutable
class Vehicle {
  const Vehicle({
    required this.id,
    required this.nickname,
    required this.make,
    required this.model,
    required this.year,
    required this.colour,
    required this.registration,
    required this.size,
    this.isDefault = false,
  });

  final String id;
  final String nickname; // "Daily driver", "Sunday car"
  final String make;
  final String model;
  final int year;
  final String colour;
  final String registration;
  final VehicleSize size;
  final bool isDefault;

  String get display => '$make $model';
  String get subtitle => '$year · $colour · ${registration.toUpperCase()}';

  Vehicle copyWith({
    String? nickname,
    String? make,
    String? model,
    int? year,
    String? colour,
    String? registration,
    VehicleSize? size,
    bool? isDefault,
  }) {
    return Vehicle(
      id: id,
      nickname: nickname ?? this.nickname,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      colour: colour ?? this.colour,
      registration: registration ?? this.registration,
      size: size ?? this.size,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nickname': nickname,
        'make': make,
        'model': model,
        'year': year,
        'colour': colour,
        'registration': registration,
        'size': size.name,
        'is_default': isDefault,
      };
}

enum VehicleSize {
  hatchback('Hatchback'),
  sedan('Sedan'),
  suv('SUV'),
  bakkie('Bakkie'),
  other('Other');

  const VehicleSize(this.label);
  final String label;
}
