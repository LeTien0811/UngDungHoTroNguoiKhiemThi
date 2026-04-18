import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/enum/config.dart';

class LocalAiProvider extends BaseModel {
  LocalAiStatus status = LocalAiStatus.uninitialized;

  void setReady(bool isProp) {
    if (isProp) {
      status = LocalAiStatus.ready;
      notifyListeners();
      return;
    }
    status = LocalAiStatus.uninitialized;
    notifyListeners();
    return;
  }

  void setProcessing() {
    status = LocalAiStatus.processing;
    notifyListeners();
    return;
  }

  void setDisposed() {
    status = LocalAiStatus.uninitialized;
    notifyListeners();
    return;
  }

  void setError() {
    status = LocalAiStatus.error;
    notifyListeners();
    return;
  }
}
