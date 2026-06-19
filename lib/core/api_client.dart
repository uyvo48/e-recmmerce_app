import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'https://api.escuelajs.co/api/v1';
  final Dio dio;
  final FlutterSecureStorage storage;

  ApiClient({Dio? dio, FlutterSecureStorage? storage})
      : dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl)),
        storage = storage ?? const FlutterSecureStorage() {
    _setupInterceptor();
  }

  void _setupInterceptor() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshToken = await storage.read(key: 'refresh_token');
            if (refreshToken != null) {
              try {
                final response = await dio.post(
                  '/auth/refresh-token',
                  data: {'refreshToken': refreshToken},
                  options: Options(headers: {'Authorization': ''}),
                );

                final newAccessToken = response.data['access_token'];
                final newRefreshToken = response.data['refresh_token'];

                await storage.write(key: 'auth_token', value: newAccessToken);
                await storage.write(
                    key: 'refresh_token', value: newRefreshToken);

                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                return handler.resolve(await dio.fetch(error.requestOptions));
              } catch (_) {
                await storage.delete(key: 'auth_token');
                await storage.delete(key: 'refresh_token');
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }
}
