import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/enum/config.dart';

class CameraProvider extends BaseModel {
  CameraStatus cameraStatus = CameraStatus.uninitialized;
  DateTime lastScanTime = DateTime.now();

  int errorFrameBlur = 0;
  int errorFrameRecapture = 0;

  void setFrame({
    required bool resetFrame,
    int count = 1,
    ErrorFrame? isFrame,
  }) {
    if (resetFrame) {
      if (isFrame == ErrorFrame.blur) {
        errorFrameBlur = 0;
      } else if (isFrame == ErrorFrame.recapture) {
        errorFrameRecapture = 0;
      } else if (isFrame == null) {
        errorFrameBlur = 0;
        errorFrameRecapture = 0;
      }
    } else {
      if (isFrame == ErrorFrame.blur) {
        errorFrameBlur += count;
      } else if (isFrame == ErrorFrame.recapture) {
        errorFrameRecapture += count;
      }
    }
  }

  void setCameraStatus(CameraStatus status) {
    if (cameraStatus != status) {
      cameraStatus = status;
      notifyListeners();
    }
  }

  void setReady(bool isProp) {
    setCameraStatus(isProp ? CameraStatus.ready : CameraStatus.uninitialized);
  }

  void setProcessing(bool isProcess) {
    setCameraStatus(isProcess ? CameraStatus.processing : CameraStatus.ready);
  }

  void setDisposed() {
    setCameraStatus(CameraStatus.uninitialized);
  }

  void setLastScanTime() {
    lastScanTime = DateTime.now();
  }
}