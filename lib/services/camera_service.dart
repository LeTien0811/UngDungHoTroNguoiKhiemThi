import 'dart:io';
import 'package:build_access/enum/config.dart';
import 'package:build_access/providers/camera_provider.dart';
import 'package:build_access/providers/locator.dart';
import 'package:camera/camera.dart';
import 'dart:developer' as developer_log;


class CameraService {
  CameraProvider cameraProvider = getIt<CameraProvider>();

  CameraController? controller;
  CameraDescription? camera;

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
      developer_log.log(
        "Lỗi khởi tạo Camera: $e",
        name: 'CameraService.getFirstCamera',
      );
      return null;
    }
    return null;
  }

  Future<void> init() async {
    await cameraProvider.runSafe(() async{
      if (controller != null) {
        if (controller!.value.isInitialized) return;

        await controller!.dispose();
        controller = null;
      }

      camera = await getFirstCamera();
      if (camera == null) return;

      controller = CameraController(
        camera!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller!.initialize();
      await controller!.setFocusMode(FocusMode.auto);

      await Future.delayed(const Duration(milliseconds: 1500));

      cameraProvider.setReady(true);
    }, 'CameraService.init');
  }

  Future<void> refocus() async {
    await controller?.setFocusMode(FocusMode.auto);
  }

  Future<void> startStream(Future<bool> Function(CameraImage imageFromeFrame) processDetech) async{
    await cameraProvider.runSafe(() async{

      if (controller!.value.isStreamingImages) return;

      if (cameraProvider.cameraStatus != CameraStatus.ready || controller == null) {
        throw Exception('Camera đang bận hoặc chưa sẵn sàng');
      }

      await controller!.startImageStream((
          CameraImage image,
          ) async {

        if (cameraProvider.cameraStatus == CameraStatus.uninitialized || cameraProvider.cameraStatus != CameraStatus.processing) return;

        final int currentMs = DateTime.now().millisecondsSinceEpoch;

        if (currentMs - cameraProvider.lastScanTime.millisecondsSinceEpoch < 150) {
          return;
        }

        cameraProvider.setLastScanTime();
        cameraProvider.setProcessing(true);

        try {

          bool isProcess = await processDetech(image);

          if(isProcess) {
            await stopStream();
            return;
          }

        } catch (e) {
            developer_log.log('Lỗi luồng: $e', name: 'stream.camera_service');
        } finally {
          cameraProvider.setProcessing(false);
        }
      });
    }, 'CameraService.startImageStream');
  }

  Future<void> stopStream() async {
    try {
      if (controller != null && controller!.value.isStreamingImages) {
        await controller!.stopImageStream();
        cameraProvider.setProcessing(false);
        cameraProvider.setCameraStatus(CameraStatus.idle);
        return;
      }
      developer_log.log(
        'Dừng camera',
        name: 'CameraViewModel.stopStream',
      );
      return;
    } catch (e) {
      developer_log.log(
        'Lỗi dừng stream: $e',
        name: 'CameraViewModel.stopStream',
      );
    }
  }

  Future<void> dispose() async {
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
        cameraProvider.setDisposed(true);
      }
    } catch (e) {
      developer_log.log("Dispose error: $e");
    }
  }
}
