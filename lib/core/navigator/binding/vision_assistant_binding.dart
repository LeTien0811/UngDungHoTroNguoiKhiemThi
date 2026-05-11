import 'package:build_access/view_models/vision_assistant_view_model.dart';
import 'package:get/get.dart';

class VisionAssistantBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<VisionAssistantViewModel>(() => VisionAssistantViewModel());
  }
}