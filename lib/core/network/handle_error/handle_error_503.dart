import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer_log;

import 'package:get/get.dart';

class HandleError503 {
  static Future<void> process(
    ErrorInterceptorHandler handler,
    DioException err,
  ) async {
    developer_log.log("Lỗi 504");

    int retryCount = err.requestOptions.extra['retry_count'] ?? 0;
    if (retryCount < 2) {
      retryCount++;
      await getIt<VoiceInteractionProvider>().speak(
        'voice_error_server_busy'.tr,
      );
      await Future.delayed(const Duration(seconds: 2));
      await getIt<VoiceInteractionProvider>().speak('voice_retry_call'.tr);

      final requestOptions = err.requestOptions;
      err.requestOptions.extra['retry_count'] = retryCount;

      final dio = Dio();

      try {
        final response = await dio.fetch(requestOptions);
        developer_log.log("thành công call lại");
        return handler.resolve(response);
      } catch (e) {
        developer_log.log("lỗi khi call lại: $e");
        return handler.next(err);
      }
    }
    return;
  }
}
