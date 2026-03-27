import 'dart:io';
import 'package:camera/camera.dart';
import 'dart:developer' as developer_log;

class CameraService {
  CameraController? controller;

  Future<CameraDescription?> getFirstCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final backCamera = cameras.firstWhere(
              (cam) => cam.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );

        return backCamera;
      }
    } catch (e) {
      developer_log.log("Lỗi khởi tạo Camera: $e", name: 'CameraService.getFirstCamera');
      return null;
    }
    return null;
  }

  Future<void> init(CameraDescription camera) async {
    controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await controller!.initialize();
  }


  void dispose() {
    controller?.dispose();
  }
}
