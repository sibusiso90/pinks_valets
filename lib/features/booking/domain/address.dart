import 'package:flutter/foundation.dart';

@immutable
class Address {
  const Address({
    this.id,
    required this.label,
    required this.street,
    required this.suburb,
    required this.city,
    required this.postalCode,
    this.notes,
  });

  /// Null for ad-hoc addresses typed during a booking.
  /// Populated when saved in the customer's address book.
  final String? id;
  final String label;      // "Home", "Office" (customer-friendly)
  final String street;
  final String suburb;
  final String city;
  final String postalCode;
  final String? notes;     // "Gate code 1234, unit 12"

  String get oneLine => '$street, $suburb, $postalCode';

  Address copyWith({
    String? id,
    String? label,
    String? street,
    String? suburb,
    String? city,
    String? postalCode,
    String? notes,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      street: street ?? this.street,
      suburb: suburb ?? this.suburb,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'label': label,
        'street': street,
        'suburb': suburb,
        'city': city,
        'postal_code': postalCode,
        'notes': notes,
      };
}
