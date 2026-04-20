import 'dart:developer' as developer_log;
import 'package:build_access/models/scan/process_format_input_image_result.dart';
import 'package:build_access/models/scan/process_image_result.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/providers/camera_provider.dart';
import 'package:build_access/core/utils/dependency_injection.dart';

class ProcessCaseResult {
  final CameraProvider cameraProvider = getIt<CameraProvider>();
  static const int _blurFrameThreshold = 5;
  static const int _blurRefocusCooldownMs = 2000;
  static int _lastBlurRefocusTimeMs = 0;

  static const int _recaptureFrameThreshold = 5;
  static const int _recaptureSpeechCooldownMs = 2000;
  static int _lastRecaptureSpeechTimeMs = 0;

  bool shouldHandleBlurRecovery() {
    final int currentMs = DateTime.now().millisecondsSinceEpoch;
    final bool reachedThreshold =
        cameraProvider.errorFrameBlur >= _blurFrameThreshold;
    final bool passedCooldown =
        currentMs - _lastBlurRefocusTimeMs >= _blurRefocusCooldownMs;

    return reachedThreshold && passedCooldown;
  }

  void markBlurRecoveryHandled() {
    _lastBlurRefocusTimeMs = DateTime.now().millisecondsSinceEpoch;
    cameraProvider.setFrame(resetFrame: true, isFrame: ErrorFrame.blur);
  }

  bool shouldHandleRecaptureRecovery() {
    final int currentMs = DateTime.now().millisecondsSinceEpoch;
    final bool reachedThreshold =
        cameraProvider.errorFrameRecapture >= _recaptureFrameThreshold;
    final bool passedCooldown =
        currentMs - _lastRecaptureSpeechTimeMs >= _recaptureSpeechCooldownMs;

    return reachedThreshold && passedCooldown;
  }

  void markRecaptureRecoveryHandled() {
    _lastRecaptureSpeechTimeMs = DateTime.now().millisecondsSinceEpoch;
    cameraProvider.setFrame(resetFrame: true, isFrame: ErrorFrame.recapture);
  }

  Future<bool> handleProcessResult<T>({required T result}) async {
    try {
      ProcessStatus status;
      if (result is ProcessImageResult) {
        status = result.status;
      } else if (result is ProcessFormatInputImageResult) {
        status = result.status;
      } else {
        throw Exception("Kiểu dữ liệu truyền vào không đúng!");
      }

      switch (status) {
        case ProcessStatus.blur:
          cameraProvider.setFrame(resetFrame: false, isFrame: ErrorFrame.blur);
          cameraProvider.setFrame(
            resetFrame: true,
            isFrame: ErrorFrame.recapture,
          );
          return false;

        case ProcessStatus.recapture:
          cameraProvider.setFrame(
            resetFrame: true,
            isFrame: ErrorFrame.blur,
          );
          cameraProvider.setFrame(
            resetFrame: false,
            isFrame: ErrorFrame.recapture,
          );
          return false;

        case ProcessStatus.error:
          developer_log.log(
            'Lỗi xử lý ảnh',
            name: 'ProcessCaseResult.handleBlur',
          );
          return false;

        case ProcessStatus.ok:
          cameraProvider.setCameraStatus(CameraStatus.success);
          cameraProvider.setFrame(resetFrame: true);
          return true;
      }
    } catch (e) {
      developer_log.log('lỗi $e', name: 'ProcessCaseResult.handleProcessResult');
      rethrow;
    }
  }
}
