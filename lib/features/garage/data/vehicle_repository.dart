import 'dart:async';

import '../domain/vehicle.dart';

abstract class VehicleRepository {
  Stream<List<Vehicle>> watch();
  Future<List<Vehicle>> list();
  Future<Vehicle> add(Vehicle v);
  Future<void> update(Vehicle v);
  Future<void> remove(String id);
  Future<void> setDefault(String id);
}

class InMemoryVehicleRepository implements VehicleRepository {
  InMemoryVehicleRepository() {
    _seed();
  }

  final _byId = <String, Vehicle>{};
  final _controller = StreamController<List<Vehicle>>.broadcast();

  void _seed() {
    const seed = [
      Vehicle(
        id: 'veh-1',
        nickname: 'Daily driver',
        make: 'BMW',
        model: '320i',
        year: 2021,
        colour: 'Alpine White',
        registration: 'CA 123 456',
        size: VehicleSize.sedan,
        isDefault: true,
      ),
      Vehicle(
        id: 'veh-2',
        nickname: 'Weekend car',
        make: 'Mini',
        model: 'Cooper S',
        year: 2019,
        colour: 'British Racing Green',
        registration: 'GP 987 654',
        size: VehicleSize.hatchback,
      ),
    ];
    for (final v in seed) {
      _byId[v.id] = v;
    }
  }

  void _emit() {
    final list = _byId.values.toList()
      ..sort((a, b) {
        if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
        return a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase());
      });
    _controller.add(list);
  }

  @override
  Stream<List<Vehicle>> watch() async* {
    yield _sorted();
    yield* _controller.stream;
  }

  List<Vehicle> _sorted() {
    final list = _byId.values.toList()
      ..sort((a, b) {
        if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
        return a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase());
      });
    return list;
  }

  @override
  Future<List<Vehicle>> list() async => _sorted();

  @override
  Future<Vehicle> add(Vehicle v) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final id = v.id.isEmpty ? 'veh-${DateTime.now().millisecondsSinceEpoch}' : v.id;
    final withId = Vehicle(
      id: id,
      nickname: v.nickname,
      make: v.make,
      model: v.model,
      year: v.year,
      colour: v.colour,
      registration: v.registration,
      size: v.size,
      isDefault: _byId.isEmpty ? true : v.isDefault,
    );
    if (withId.isDefault) _clearDefault();
    _byId[id] = withId;
    _emit();
    return withId;
  }

  @override
  Future<void> update(Vehicle v) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (v.isDefault) _clearDefault();
    _byId[v.id] = v;
    _emit();
  }

  @override
  Future<void> remove(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final removed = _byId.remove(id);
    // If we removed the default, promote whoever's first.
    if (removed?.isDefault == true && _byId.isNotEmpty) {
      final first = _byId.values.first;
      _byId[first.id] = first.copyWith(isDefault: true);
    }
    _emit();
  }

  @override
  Future<void> setDefault(String id) async {
    final target = _byId[id];
    if (target == null) return;
    _clearDefault();
    _byId[id] = target.copyWith(isDefault: true);
    _emit();
  }

  void _clearDefault() {
    for (final entry in _byId.entries.toList()) {
      if (entry.value.isDefault) {
        _byId[entry.key] = entry.value.copyWith(isDefault: false);
      }
    }
  }
}
