import '../../../core/utils/money.dart';
import '../domain/service_type.dart';

abstract class ServiceCatalogRepository {
  Future<List<ServiceType>> listActive();
  Future<ServiceType?> getById(String id);
}

class InMemoryServiceCatalogRepository implements ServiceCatalogRepository {
  static final _catalog = <ServiceType>[
    ServiceType(
      id: 'exterior-wash',
      name: 'Exterior Wash',
      durationMinutes: 30,
      priceCents: rands(150),
      description: 'A thorough hand wash — body, wheels, tyres & windows.',
      active: true,
      sortOrder: 10,
    ),
    ServiceType(
      id: 'interior-detail',
      name: 'Interior Detail',
      durationMinutes: 45,
      priceCents: rands(220),
      description: 'Vacuum, dash & trim wipe-down, interior glass.',
      active: true,
      sortOrder: 20,
    ),
    ServiceType(
      id: 'full-valet',
      name: 'Full Valet',
      durationMinutes: 90,
      priceCents: rands(350),
      description: 'Exterior + interior — our most booked service.',
      active: true,
      sortOrder: 30,
    ),
    ServiceType(
      id: 'premium-detail',
      name: 'Premium Detail',
      durationMinutes: 180,
      priceCents: rands(650),
      description: 'Clay bar, polish, hand wax, interior deep clean.',
      active: true,
      sortOrder: 40,
    ),
    ServiceType(
      id: 'ceramic-refresh',
      name: 'Ceramic Refresh',
      durationMinutes: 120,
      priceCents: rands(890),
      description: 'Maintenance treatment for ceramic-coated vehicles.',
      active: true,
      sortOrder: 50,
    ),
  ];

  @override
  Future<List<ServiceType>> listActive() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final active = _catalog.where((s) => s.active).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return active;
  }

  @override
  Future<ServiceType?> getById(String id) async {
    return _catalog.firstWhere(
      (s) => s.id == id,
      orElse: () => _catalog.first,
    );
  }
}
