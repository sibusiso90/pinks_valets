import 'dart:async';

import '../domain/auth_user.dart';

/// Interface. A real implementation will call Firebase Auth; for v1 we keep
/// the repository in-memory so the app is fully navigable without a backend.
abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();
  AuthUser? get currentUser;
  Future<AuthUser> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  });
  Future<AuthUser> signIn({
    required String identifier, // email or phone
    required String password,
  });
  Future<void> signOut();
  Future<void> verifyOtp(String code);
  Future<void> requestPasswordReset(String email);
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
  });
}

class InMemoryAuthRepository implements AuthRepository {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _current;

  @override
  AuthUser? get currentUser => _current;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<AuthUser> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _current = AuthUser(
      uid: 'uid_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      email: email,
    );
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<AuthUser> signIn({
    required String identifier,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _current = AuthUser(
      uid: 'uid_demo',
      name: 'Thandi Mahlangu',
      phone: '+27823456789',
      email: identifier.contains('@') ? identifier : 'thandi@mail.co.za',
    );
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _current = null;
    _controller.add(null);
  }

  @override
  Future<void> verifyOtp(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (code.length != 6) {
      throw Exception('OTP must be 6 digits');
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
  }) async {
    if (_current == null) return;
    _current = _current!.copyWith(name: name, phone: phone, email: email);
    _controller.add(_current);
  }
}
