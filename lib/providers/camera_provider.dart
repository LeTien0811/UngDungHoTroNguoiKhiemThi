import 'package:build_access/config/base_model.dart';
import 'package:build_access/enum/config.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraProvider extends BaseModel{
  bool isProcessing = false;
  bool isReady = false;
  bool isDisposed = false;
  CameraStatus cameraStatus = CameraStatus.uninitialized;
  DateTime lastScanTime = DateTime.now();
  InputImage? inputImage;


  void setReady(bool isProp) {
    if(isProp) {
      // trang thai san sang
      isReady = isProp;
      cameraStatus = CameraStatus.idle;

      // cho dispose bang false
      isDisposed = !isProp;
      notifyListeners();
      return;
    }
    // chua san sang
    isReady = isProp;
    cameraStatus = CameraStatus.uninitialized;

    notifyListeners();
    return;
  }

  void setProcessing(bool isProp) {
    isProcessing = isProp;
    notifyListeners();
    return;
  }

  void setDisposed(bool isProp) {
    isDisposed = isProp;
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

  void setDispose() {
    isDisposed = true;
    isProcessing = false;
    isReady = false;
    cameraStatus = CameraStatus.idle;
  }

}