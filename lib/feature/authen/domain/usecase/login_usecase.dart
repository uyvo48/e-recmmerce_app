import 'package:e_commerce_app/feature/authen/domain/repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<void> call(String email, String password) {
    return repository.login(email, password);
  }
}
