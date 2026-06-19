abstract class AuthDataSource {
  Future<void> logUp(String name, String email, String password,
      String rePassword, String phone);
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<Map<String, dynamic>> getProfile();
}
