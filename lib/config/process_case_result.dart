import 'dart:developer' as developer_log;
import 'package:build_access/config/process_format_input_image_result.dart';
import 'package:build_access/config/process_image_result.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/providers/camera_provider.dart';
import 'package:build_access/providers/global_provider.dart';
import 'package:build_access/providers/locator.dart';
import 'package:build_access/services/camera_service.dart';

class ProcessCaseResult {
  final CameraService cameraService = getIt<CameraService>();
  final GlobalProvider globalProvider = getIt<GlobalProvider>();
  final CameraProvider cameraProvider = getIt<CameraProvider>();

  Future<void> handleBlur() async{
    globalProvider.speakQueue(
      "Ảnh mờ vui lòng giữ yên điện thoại hoặc di chuyển để lấy nét",
    );
    await cameraService.refocus();
    cameraProvider.setCameraStatus(CameraStatus.recapture);
  }

  Future<bool> handleProcessResult<T>({required T result, bool isPropFuncRecapture = false,Future<void> Function()? onReCapture}) async {
    try {
      if(result is! ProcessImageResult || result is! ProcessFormatInputImageResult) throw Exception("Sai kiểu dữ liệu");

      switch (result.status) {
        case ProcessStatus.blur:
          await handleBlur();
          return false;

        case ProcessStatus.recapture:
          (!isPropFuncRecapture) ?  cameraProvider.setCameraStatus(CameraStatus.recapture) : onReCapture!() ;
          return false;

        case ProcessStatus.error:
          developer_log.log(
            'Lỗi xử lý ảnh',
            name: 'ProcessCaseResult.handleBlur',
          );
          return false;

        case ProcessStatus.ok:
          cameraProvider.setCameraStatus(CameraStatus.success);
          return true;
      }
    } catch (e) {
      rethrow;
    }
  }
}