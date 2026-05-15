import 'package:build_access/core/auth/auth_controller.dart';
import 'package:build_access/core/auth/auth_storage_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer_log;

import 'package:get/get.dart';

class HandleError404 {
  static Future<void> process(
    ErrorInterceptorHandler handler,
    DioException err,
  ) async {
    int retryCount = err.requestOptions.extra['retry_count'] ?? 0;
    if (retryCount < 2) {
      retryCount++;
      final AuthStorageEngine authStorage = getIt<AuthStorageEngine>();
      final UserProfileProvider userProfileProvider =
          getIt<UserProfileProvider>();
      developer_log.log("Lỗi 401");
      final authController = Get.find<AuthController>();
      final profile = userProfileProvider.userProfile;
      if (profile != null &&
          profile.email.isNotEmpty &&
          profile.email != "Không rõ") {
        try {
          developer_log.log("tụ động đăng nhập lại");
          await authController.autoLoginWithPasskey(
            userProfileProvider.userProfile!.email,
            isGo: false,
          );

          final requestOptions = err.requestOptions;
          err.requestOptions.extra['retry_count'] = retryCount;
          String? newAuthToken = authStorage.getAccessToken();
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            newAuthToken = await user.getIdToken();
          }
          requestOptions.headers['Authorization'] = 'Bearer $newAuthToken';

          final dio = Dio();
          final response = await dio.fetch(requestOptions);
          developer_log.log("thành công call lại");
          return handler.resolve(response);
        } catch (e) {
          developer_log.log("lỗi đăng xuất: $e");
          await authController.logout();
          authController.checkInitialAuth();
        }
      } else {
        developer_log.log("ko co người dùng đăng xuất");
        await authController.logout();
        authController.checkInitialAuth();
      }
      return;
    }
  }
}
