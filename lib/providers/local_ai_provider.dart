import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/enum/config.dart';

class LocalAiProvider extends BaseModel {
  LocalAiStatus status = LocalAiStatus.uninitialized;

  void _setStatus(LocalAiStatus newStatus) {
    if (status != newStatus) {
      status = newStatus;
      notifyListeners();
    }
  }

  void setReady(bool isReady) {
    _setStatus(isReady ? LocalAiStatus.ready : LocalAiStatus.uninitialized);
  }

  void setProcessing() {
    _setStatus(LocalAiStatus.processing);
  }

  void setDisposed() {
    _setStatus(LocalAiStatus.uninitialized);
  }

  void setError() {
    _setStatus(LocalAiStatus.error);
  }
}