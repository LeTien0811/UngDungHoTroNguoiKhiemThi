import 'dart:developer' as developer_log;
import 'package:build_access/providers/locator.dart';
import 'package:build_access/providers/service_provider.dart';
import 'package:flutter_leap_sdk/flutter_leap_sdk.dart';

class LocalEngineService {
  bool _isReady = false;
  bool get isReady => _isReady;

  Future<void> initializeSystem() async {
    try {
      final modelName = 'LFM2-350M';
      final isExists = await FlutterLeapSdkService.checkModelExists(modelName);

      if (!isExists) {
        getIt<ProviderSevice>().speakQueue(
          "Bắt đầu tải dữ liệu trí tuệ nhân tạo. Vui lòng giữ kết nối mạng.",
        );

        await FlutterLeapSdkService.downloadModel(
          modelName: modelName,
          onProgress: (progress) {
            if (progress.percentage.toInt() % 20 == 0) {
              getIt<ProviderSevice>().speakQueue(
                "Đã tải được ${progress.percentage.toInt()} phần trăm.",
              );
            }
          },
        );

        getIt<ProviderSevice>().speakQueue(
          "Tải dữ liệu hoàn tất. Hệ thống sẵn sàng.",
        );
      }

      // Nạp model vào RAM
      await FlutterLeapSdkService.loadModel(modelPath: modelName);
      _isReady = true;
    } catch (e) {
      getIt<ProviderSevice>().speakQueue(
        "Lỗi khởi tạo hệ thống. Vui lòng thử lại sau.",
      );
      rethrow;
    }
  }

  Future<String> processAndCorrectText(String rawOcrText) async {
    if (!_isReady) return "Hệ thống đang khởi động, vui lòng chờ.";

    // Ép Prompt bằng tiếng Việt để thử thách khả năng đa ngôn ngữ của Liquid AI
    final prompt =
        "Đây là nội dung quét từ hộp thuốc: $rawOcrText. Hãy tóm tắt tên thuốc và cách dùng bằng tiếng Việt.";

    try {
      final response = await FlutterLeapSdkService.generateResponse(
        prompt,
        systemPrompt: "Bạn là trợ lý y tế chuyên nghiệp.",
      );
      return response;
    } catch (e) {
      return "Lỗi xử lý AI: $e";
    }
  }
}
