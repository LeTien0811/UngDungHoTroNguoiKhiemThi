import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/enum/state.dart';

class APIAIProvider extends BaseModel {
  AIStatus status = AIStatus.uninitialized;

  void _setStatus(AIStatus newStatus) {
    if (status != newStatus) {
      status = newStatus;
      notifyListeners();
    }
  }

  void setReady(bool isReady) {
    _setStatus(isReady ? AIStatus.ready : AIStatus.uninitialized);
  }

  void setProcessing() {
    _setStatus(AIStatus.processing);
  }

  void setDisposed() {
    _setStatus(AIStatus.uninitialized);
  }

  void setError() {
    _setStatus(AIStatus.error);
  }
}
