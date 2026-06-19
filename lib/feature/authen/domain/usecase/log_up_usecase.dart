import 'package:e_commerce_app/feature/authen/domain/repository/auth_repository.dart';

class LogUpUseCase {
  final AuthRepository repository;

  LogUpUseCase({required this.repository});
  Future<void> call(
    String name,
    String email,
    String password,
    String rePassword,
    String phone,
  ) {
    return repository.logUp(name, email, password, rePassword, phone);
  }
}
