import 'package:build_access/view_models/history_view_model.dart';
import 'package:get/get.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryViewModel>(() => HistoryViewModel());
  }
}
