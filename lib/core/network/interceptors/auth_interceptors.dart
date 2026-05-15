import 'package:build_access/core/auth/auth_storage_engine.dart';
import 'package:build_access/core/network/handle_error/handle_error_404.dart';
import 'package:build_access/core/network/handle_error/handle_error_503.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:dio/dio.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthInterceptor extends Interceptor {
  final AuthStorageEngine _authStorage = getIt<AuthStorageEngine>();
  // ignore: unused_field
  final UserProfileProvider _userProfileProvider = getIt<UserProfileProvider>();
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    String? token = _authStorage.getAccessToken();

    // Tự động làm mới và lấy token từ Firebase (nếu đã đăng nhập Firebase)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      token = await user.getIdToken();
    }

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    switch (err.response?.statusCode) {
      case 401:
        await HandleError404.process(handler, err);
        break;
      case 503:
        await HandleError503.process(handler, err);
        break;
    }
    return handler.next(err);
  }
}
