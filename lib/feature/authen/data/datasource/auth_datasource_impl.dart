import 'package:dio/dio.dart';
import 'package:e_commerce_app/feature/authen/data/datasource/auth_datasource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthDataSourceImpl implements AuthDataSource {
  final Dio dio;
  final Dio loginDio;
  final FlutterSecureStorage secureStorage;

  AuthDataSourceImpl({
    Dio? dio,
    Dio? loginDio,
    FlutterSecureStorage? secureStorage,
  })  : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://ecommerce.routemisr.com/api/v1',
                headers: {'Content-Type': 'application/json'},
              ),
            ),
        loginDio = loginDio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.escuelajs.co/api/v1',
                headers: {'Content-Type': 'application/json'},
              ),
            ),
        secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _setupInterceptor();
  }

  void _setupInterceptor() {
    loginDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.path.contains('/auth/login') &&
              !options.path.contains('/auth/refresh-token')) {
            final token = await secureStorage.read(key: 'auth_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshToken = await secureStorage.read(key: 'refresh_token');
            if (refreshToken != null) {
              try {
                final response = await loginDio.post(
                  '/auth/refresh-token',
                  data: {'refreshToken': refreshToken},
                );

                final newAccessToken = response.data['access_token'];
                final newRefreshToken = response.data['refresh_token'];

                await secureStorage.write(
                    key: 'auth_token', value: newAccessToken);
                await secureStorage.write(
                    key: 'refresh_token', value: newRefreshToken);

                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                return handler.resolve(await loginDio.fetch(error.requestOptions));
              } catch (_) {
                await logout();
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  @override
  Future<void> logUp(
    String name,
    String email,
    String password,
    String rePassword,
    String phone,
  ) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final response = await dio.post(
        '/auth/signup',
        data: {
          'name': name.trim(),
          'email': normalizedEmail,
          'password': password,
          'rePassword': rePassword,
          'phone': phone.trim(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;

      if (token != null && token.isNotEmpty) {
        await secureStorage.write(key: 'auth_token', value: token);
        await secureStorage.write(
          key: 'current_user_email',
          value: normalizedEmail,
        );
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['errors']?['msg'];
        if (message != null) {
          throw Exception(message.toString());
        }
      }
      throw Exception('Dang ky that bai. Vui long thu lai.');
    }
  }

  @override
  Future<void> login(String email, String password) async {
    try {
      final response = await loginDio.post(
        '/auth/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;

      if (token == null || token.isEmpty) {
        throw Exception('Khong nhan duoc token dang nhap.');
      }

      await secureStorage.write(key: 'auth_token', value: token);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await secureStorage.write(key: 'refresh_token', value: refreshToken);
      }
      await secureStorage.write(
        key: 'current_user_email',
        value: email.trim().toLowerCase(),
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['errors']?['msg'];
        if (message != null) {
          throw Exception(message.toString());
        }
      }
      throw Exception('Dang nhap that bai. Vui long thu lai.');
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'refresh_token');
    await secureStorage.delete(key: 'current_user_email');
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await loginDio.get('/auth/profile');
      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message != null) {
          throw Exception(message.toString());
        }
      }
      throw Exception('Khong the lay thong tin nguoi dung.');
    }
  }
}
