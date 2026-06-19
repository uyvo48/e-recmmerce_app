part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class LogUpSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String rePassword;
  final String phone;

  LogUpSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.rePassword,
    required this.phone,
  });
}
