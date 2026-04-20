import 'package:build_access/core/camera/camera_hardware_manager.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/camera_provider.dart';
import 'dart:developer' as developer_log;

class VisionStreamCoordinator {
  final CameraHardwareManager cameraHardwareManager = getIt<CameraHardwareManager>();
  final CameraProvider cameraProvider = getIt<CameraProvider>();

  Future<bool> prepareCamera() async{
      try {
        if(!cameraHardwareManager.isInitialized) {
          bool isInitHardWare = await cameraHardwareManager.init();
          if(!isInitHardWare) return false;

          cameraProvider.setReady(true);
          return true;
        }
        cameraProvider.setReady(true);
        return true;
      } catch (e) {
        cameraProvider.setReady(false);
        developer_log.log('prepareCamera error: $e', name: "Vision Stream Coordinator > prepareCamera");
        return false;
      }
  }

  Future<void> startVisionLoop() async{
    
  }

}