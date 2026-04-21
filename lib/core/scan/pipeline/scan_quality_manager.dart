import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/providers/camera_provider.dart';
import 'dart:developer' as developer_log;

class ScanQualityManager {
  final CameraProvider _cameraProvider = getIt<CameraProvider>();

  static const int _blurFrameThreshold = 5;
  static const int _blurRefocusCooldownMs = 2000;
  int _lastBlurRefocusTimeMs = 0;

  static const int _recaptureFrameThreshold = 5;
  static const int _recaptureSpeechCooldownMs = 2000;
  int _lastRecaptureSpeechTimeMs = 0;

  bool shouldHandleBlurRecovery() {
    final int currentMs = DateTime.now().millisecondsSinceEpoch;
    final bool reachedThreshold = _cameraProvider.errorFrameBlur >= _blurFrameThreshold;
    final bool passedCooldown = currentMs - _lastBlurRefocusTimeMs >= _blurRefocusCooldownMs;

    return reachedThreshold && passedCooldown;
  }

  void markBlurRecoveryHandled() {
    _lastBlurRefocusTimeMs = DateTime.now().millisecondsSinceEpoch;
    _cameraProvider.setFrame(resetFrame: true, isFrame: ErrorFrame.blur);
  }

  bool shouldHandleRecaptureRecovery() {
    final int currentMs = DateTime.now().millisecondsSinceEpoch;
    final bool reachedThreshold = _cameraProvider.errorFrameRecapture >= _recaptureFrameThreshold;
    final bool passedCooldown = currentMs - _lastRecaptureSpeechTimeMs >= _recaptureSpeechCooldownMs;

    return reachedThreshold && passedCooldown;
  }

  void markRecaptureRecoveryHandled() {
    _lastRecaptureSpeechTimeMs = DateTime.now().millisecondsSinceEpoch;
    _cameraProvider.setFrame(resetFrame: true, isFrame: ErrorFrame.recapture);
  }

  bool handleProcessStatus(ScanStatus status) {
    try {
      switch (status) {
        case ScanStatus.blur:
          _cameraProvider.setFrame(resetFrame: false, isFrame: ErrorFrame.blur);
          _cameraProvider.setFrame(resetFrame: true, isFrame: ErrorFrame.recapture);
          return false;

        case ScanStatus.recapture:
          _cameraProvider.setFrame(resetFrame: true, isFrame: ErrorFrame.blur);
          _cameraProvider.setFrame(resetFrame: false, isFrame: ErrorFrame.recapture);
          return false;

        case ScanStatus.error:
          developer_log.log('Lỗi xử lý ảnh', name: 'ScanQualityManager');
          return false;

        case ScanStatus.ok:
          _cameraProvider.setCameraStatus(CameraStatus.success);
          _cameraProvider.setFrame(resetFrame: true);
          return true;

        case ScanStatus.notFoundObject:
          // TODO: Handle this case.
          throw UnimplementedError();
        case ScanStatus.notFoundText:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    } catch (e) {
      developer_log.log('Lỗi cập nhật trạng thái: $e', name: 'ScanQualityManager');
      return false;
    }
  }
}