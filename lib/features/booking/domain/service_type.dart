import 'package:flutter/foundation.dart';

/// A service the business offers. Mirrors the Firestore `service_types/{id}`
/// document in BuildSpec_MobileApp.md §3.1.
@immutable
class ServiceType {
  const ServiceType({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.priceCents,
    required this.description,
    required this.active,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final int priceCents;
  final String description;
  final bool active;
  final int sortOrder;

  factory ServiceType.fromMap(String id, Map<String, dynamic> data) {
    return ServiceType(
      id: id,
      name: data['name'] as String,
      durationMinutes: (data['duration_minutes'] as num).toInt(),
      priceCents: (data['price_cents'] as num).toInt(),
      description: data['description'] as String? ?? '',
      active: data['active'] as bool? ?? true,
      sortOrder: (data['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
