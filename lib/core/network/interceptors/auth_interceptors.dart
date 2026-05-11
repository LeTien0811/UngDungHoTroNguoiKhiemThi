import 'package:build_access/core/auth/auth_storage_engine.dart';
import 'package:dio/dio.dart';
import 'package:build_access/core/utils/dependency_injection.dart';

class AuthInterceptor extends Interceptor {
  final AuthStorageEngine _authStorage = getIt<AuthStorageEngine>();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authStorage.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _authStorage.deleteUser();
    }
    return handler.next(err);
  }
}
