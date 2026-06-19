import 'package:e_commerce_app/feature/authen/data/datasource/auth_datasource.dart';
import 'package:e_commerce_app/feature/authen/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});
  @override
  Future<void> logUp(
    String name,
    String email,
    String password,
    String rePassword,
    String phone,
  ) {
    return dataSource.logUp(
      name,
      email,
      password,
      rePassword,
      phone,
    );
  }

  @override
  Future<void> login(String email, String password) {
    return dataSource.login(email, password);
  }

  @override
  Future<void> logout() {
    return dataSource.logout();
  }
}
