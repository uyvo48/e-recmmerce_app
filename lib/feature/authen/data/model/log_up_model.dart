import 'package:e_commerce_app/feature/authen/domain/entity/loup_entity.dart';

class LogUpModel extends LogUpEntity {
  LogUpModel({
    required super.email,
    required super.password,
    required super.name,
    required super.rePassword,
    required super.phone,
  });

  factory LogUpModel.fromJson(Map<String, dynamic> json) {
    return LogUpModel(
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      name: json['name'] as String? ?? '',
      rePassword: json['rePassword'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
    };
  }
}
