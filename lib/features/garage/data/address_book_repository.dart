import 'dart:async';

import '../../booking/domain/address.dart';

abstract class AddressBookRepository {
  Stream<List<Address>> watch();
  Future<List<Address>> list();
  Future<Address> add(Address a);
  Future<void> update(Address a);
  Future<void> remove(String id);
}

class InMemoryAddressBookRepository implements AddressBookRepository {
  InMemoryAddressBookRepository() {
    _seed();
  }

  final _byId = <String, Address>{};
  final _controller = StreamController<List<Address>>.broadcast();

  void _seed() {
    const seed = [
      Address(
        id: 'addr-1',
        label: 'Home',
        street: '24 Oak Lane',
        suburb: 'Sandton',
        city: 'Johannesburg',
        postalCode: '2196',
        notes: 'Gate code 1234, unit 12. Parking at the back.',
      ),
      Address(
        id: 'addr-2',
        label: 'Office',
        street: '12 West Street',
        suburb: 'Sandton',
        city: 'Johannesburg',
        postalCode: '2196',
        notes: 'Basement P2, bay 47. Ask reception for the boom.',
      ),
    ];
    for (final a in seed) {
      _byId[a.id!] = a;
    }
  }

  void _emit() {
    _controller.add(_sorted());
  }

  List<Address> _sorted() {
    final list = _byId.values.toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return list;
  }

  @override
  Stream<List<Address>> watch() async* {
    yield _sorted();
    yield* _controller.stream;
  }

  @override
  Future<List<Address>> list() async => _sorted();

  @override
  Future<Address> add(Address a) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final id = a.id ?? 'addr-${DateTime.now().millisecondsSinceEpoch}';
    final withId = a.copyWith(id: id);
    _byId[id] = withId;
    _emit();
    return withId;
  }

  @override
  Future<void> update(Address a) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (a.id == null) return;
    _byId[a.id!] = a;
    _emit();
  }

  @override
  Future<void> remove(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _byId.remove(id);
    _emit();
  }
}
