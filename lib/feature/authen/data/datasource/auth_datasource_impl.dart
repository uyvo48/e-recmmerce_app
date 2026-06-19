import 'dart:convert';

import 'package:e_commerce_app/feature/authen/data/datasource/auth_datasource.dart';
import 'package:e_commerce_app/feature/authen/data/model/log_up_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthDataSourceImpl implements AuthDataSource {
  static const _usersKey = 'registered_users';

  final FlutterSecureStorage secureStorage;

  AuthDataSourceImpl({
    FlutterSecureStorage? secureStorage,
  }) : secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> logUp(
    String name,
    String email,
    String password,
    String rePassword,
    String phone,
  ) async {
    final normalizedEmail = email.trim().toLowerCase();
    final storedUsers = await secureStorage.read(key: _usersKey);
    final users = storedUsers == null
        ? <String, dynamic>{}
        : jsonDecode(storedUsers) as Map<String, dynamic>;

    if (users.containsKey(normalizedEmail)) {
      throw Exception('Email nay da duoc dang ky.');
    }

    final user = LogUpModel(
      name: name.trim(),
      email: normalizedEmail,
      password: password,
      rePassword: rePassword,
      phone: phone.trim(),
    );

    users[normalizedEmail] = user.toJson();

    await secureStorage.write(
      key: _usersKey,
      value: jsonEncode(users),
    );
    await secureStorage.write(
        key: 'current_user_email', value: normalizedEmail);
  }
}
