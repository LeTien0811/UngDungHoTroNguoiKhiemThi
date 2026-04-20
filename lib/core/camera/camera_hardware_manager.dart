import 'dart:io';
import 'package:camera/camera.dart';
import 'dart:developer' as developer_log;


class CameraHardwareManager {
  CameraController? controller;
  CameraDescription? camera;

  bool get isCameraStream => controller?.value.isStreamingImages ?? false;
  bool get isInitialized => controller?.value.isInitialized ?? false;

  Future<CameraDescription?> getBackCamera() async {
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
      developer_log.log(
        "Lỗi khởi tạo Camera: $e",
        name: 'CameraService.getFirstCamera',
      );
      return null;
    }
    return null;
  }

  Future<bool> init() async {
      try {
        if (controller != null) {
          if (controller!.value.isInitialized) return true;

          await controller!.dispose();
          controller = null;
        }

        camera = await getBackCamera();
        if (camera == null) return false;

        controller = CameraController(
          camera!,
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: Platform.isAndroid
              ? ImageFormatGroup.nv21
              : ImageFormatGroup.bgra8888,
        );

        await controller!.initialize();
        return true;
      } catch(e) {
        developer_log.log('crash init camera', name: "cameraHardwareManager.init");
        return false;
      }
  }

  Future<bool> startFocus() async {
    try {
      if(!isInitialized) return false;
      await controller?.setFocusMode(FocusMode.auto);
      return true;
    } catch(e) {
      developer_log.log('error on startFocus HardWare: $e', name: 'CameraHardwareManager.startFocus');
      return false;
    }
  }

  Future<void> startRawStream<T>(Future<T> Function({required CameraImage image}) onProcessFrame) async{
    try {
      if(isInitialized) {
        throw Exception("Chưa khởi tạo camera");
      }

      await controller!.startImageStream((CameraImage imageOnFrame) async{
        await onProcessFrame(image: imageOnFrame);
      });

    } catch(e) {
      developer_log.log('error on Start RawStream HardWare: $e', name: 'CameraHardwareManager.startRawStream');
      return;
    }
  }

  Future<bool> stopStream() async {
    try {
      if (controller != null && controller!.value.isStreamingImages) {
        await controller!.stopImageStream();
        developer_log.log(
          'Dừng camera',
          name: 'CameraViewModel.stopStream',
        );
        return true;
      }
      return false;
    } catch (e) {
      developer_log.log(
        'Lỗi dừng stream: $e',
        name: 'CameraViewModel.stopStream',
      );
      return false;
    }
  }

  Future<bool> dispose() async {
    try {
      developer_log.log(
        'Hủy camera',
        name: 'CameraViewModel.stopStream',
      );
      if (controller != null) {
        if (controller!.value.isStreamingImages) {
          await controller!.stopImageStream();
        }
        await controller!.dispose();
        controller = null;
        return true;
      }
      return false;
    } catch (e) {
      developer_log.log("Dispose error: $e", name: 'CameraViewModel.dispose',);
      return false;
    }
  }
}
