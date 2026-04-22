import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  const AuthUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
  });

  final String uid;
  final String name;
  final String phone;
  final String email;

  AuthUser copyWith({String? name, String? phone, String? email}) => AuthUser(
        uid: uid,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
      );
}
