import 'package:build_access/view_models/camera_view_model.dart';
import 'package:get/get.dart';

class CameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraViewModel>(() => CameraViewModel());
  }
}
