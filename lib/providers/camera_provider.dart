import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/enum/config.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraProvider extends BaseModel {
  CameraStatus cameraStatus = CameraStatus.uninitialized;
  DateTime lastScanTime = DateTime.now();
  InputImage? inputImage;

  int errorFrameBlur = 0;
  int errorFrameRecapture = 0;

  void setFrame({
    required bool resetFrame,
    int? count = 1,
    ErrorFrame? isFrame,
  }) {
    if (!resetFrame) {
      switch (isFrame) {
        case ErrorFrame.blur:
          errorFrameBlur += count!;
          break;
        case ErrorFrame.recapture:
          errorFrameRecapture += count!;
          break;
        case null:
          break;
      }
    } else {
      switch (isFrame) {
        case ErrorFrame.blur:
          errorFrameBlur = 0;
          break;
        case ErrorFrame.recapture:
          errorFrameRecapture = 0;
          break;
        case null:
          errorFrameBlur = 0;
          errorFrameRecapture = 0;
          break;
      }
    }
    notifyListeners();
    return;
  }

  void setReady(bool isProp) {
    if (isProp) {
      // trang thai san sang
      cameraStatus = CameraStatus.ready;
      notifyListeners();
      return;
    }
    cameraStatus = CameraStatus.uninitialized;

    notifyListeners();
    return;
  }

  void setProcessing(bool isProp) {
    cameraStatus = CameraStatus.processing;
    notifyListeners();
    return;
  }

  void setDisposed(bool isProp) {
    cameraStatus = CameraStatus.uninitialized;
    notifyListeners();
    return;
  }

  void setCameraStatus(CameraStatus status) {
    cameraStatus = status;
    notifyListeners();
    return;
  }

  void setLastScanTime() {
    lastScanTime = DateTime.now();
    notifyListeners();
    return;
  }
}
