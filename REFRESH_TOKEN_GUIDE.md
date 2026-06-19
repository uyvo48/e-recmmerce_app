# Auto Refresh Token Implementation

## 🔄 LUỒNG HOẠT ĐỘNG

```
Login → Lưu access_token + refresh_token
  ↓
Gọi API (getProfile)
  ↓
Token hết hạn? (401)
  ↓
Interceptor tự động:
  1. Gọi /auth/refresh-token
  2. Lưu token mới
  3. Retry request ban đầu
  ↓
SUCCESS!
```

## 🧪 CÁCH TEST

### 1. Đăng nhập với tài khoản test:
```
Email: john@mail.com
Password: changeme
```

### 2. Sau khi login, bạn sẽ vào màn hình "Test Refresh Token API"

### 3. Click nút "Test Get Profile API" để:
- Gọi API `GET /auth/profile`
- Nếu token hết hạn (401) → Interceptor tự động refresh
- Hiển thị thông tin profile nếu thành công

## 📝 CODE IMPLEMENTATION

### 1. Dio Interceptor (AuthDataSourceImpl)

```dart
void _setupInterceptor() {
  loginDio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Tự động thêm Bearer token vào header
        final token = await secureStorage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Khi nhận 401 → Auto refresh
        if (error.response?.statusCode == 401) {
          final refreshToken = await secureStorage.read(key: 'refresh_token');
          if (refreshToken != null) {
            try {
              // Gọi refresh token API
              final response = await loginDio.post(
                '/auth/refresh-token',
                data: {'refreshToken': refreshToken},
              );

              // Lưu token mới
              final newAccessToken = response.data['access_token'];
              final newRefreshToken = response.data['refresh_token'];
              await secureStorage.write(key: 'auth_token', value: newAccessToken);
              await secureStorage.write(key: 'refresh_token', value: newRefreshToken);

              // Retry request ban đầu với token mới
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              return handler.resolve(await loginDio.fetch(error.requestOptions));
            } catch (_) {
              // Nếu refresh fail → Logout
              await logout();
            }
          }
        }
        handler.next(error);
      },
    ),
  );
}
```

### 2. Login Flow

```dart
Future<void> login(String email, String password) async {
  final response = await loginDio.post(
    '/auth/login',
    data: {
      'email': email.trim().toLowerCase(),
      'password': password,
    },
  );

  final token = response.data['access_token'];
  final refreshToken = response.data['refresh_token'];

  // Lưu cả 2 token
  await secureStorage.write(key: 'auth_token', value: token);
  await secureStorage.write(key: 'refresh_token', value: refreshToken);
}
```

### 3. Get Profile (Protected API)

```dart
Future<Map<String, dynamic>> getProfile() async {
  // Interceptor tự động thêm Bearer token
  // Nếu 401 → Tự động refresh và retry
  final response = await loginDio.get('/auth/profile');
  return response.data as Map<String, dynamic>;
}
```

## 🎯 KEY POINTS

1. **Access Token**: Valid 20 days
2. **Refresh Token**: Valid 10 hours
3. **Auto Refresh**: Xảy ra tự động khi nhận 401
4. **Transparent**: Developer không cần handle refresh manually
5. **Retry**: Request gốc được retry tự động với token mới

## 📦 API ENDPOINTS

- Login: `POST /auth/login`
- Refresh: `POST /auth/refresh-token`
- Profile: `GET /auth/profile` (protected)

## ✅ ADVANTAGES

- ✨ Transparent cho developer
- 🔄 Auto retry failed requests
- 🔒 Secure token storage
- 💪 Robust error handling
- 🚀 No manual token management
