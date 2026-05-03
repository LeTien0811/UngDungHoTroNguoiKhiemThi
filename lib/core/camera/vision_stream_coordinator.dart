import 'package:build_access/services/camera_hardware_service.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/providers/camera_provider.dart';
import 'dart:developer' as developer_log;
import 'package:camera/camera.dart';

class VisionStreamCoordinator {
  final CameraHardwareService cameraHardwareManager =
      getIt<CameraHardwareService>();
  final CameraProvider cameraProvider = getIt<CameraProvider>();

  Future<bool> initCamera() async {
    try {
      if (!cameraHardwareManager.isInitialized) {
        bool isInitHardWare = await cameraHardwareManager.init();
        if (!isInitHardWare) return false;

        cameraProvider.setReady(true);
        return true;
      }
      cameraProvider.setReady(true);
      return true;
    } catch (e) {
      cameraProvider.setReady(false);
      developer_log.log(
        'prepareCamera error: $e',
        name: "Vision Stream Coordinator > prepareCamera",
      );
      return false;
    }
  }

  Future<void> startVisionLoop(
    Future<bool> Function(CameraImage image) onProcessFrame,
  ) async {
    if (cameraProvider.cameraStatus != CameraStatus.ready ||
        !cameraHardwareManager.isInitialized) {
      return;
    }

    try {
      await cameraHardwareManager.startFocus();
      await cameraHardwareManager.startRawStream((
        CameraImage imageOnFrame,
      ) async {
        try {
          if (cameraProvider.cameraStatus == CameraStatus.uninitialized ||
              cameraProvider.cameraStatus == CameraStatus.processing) {
            return;
          }

          final int currentTimeScan = DateTime.now().millisecondsSinceEpoch;
          if (currentTimeScan -
                  cameraProvider.lastScanTime.millisecondsSinceEpoch <
              2500) {
            return;
          }

          cameraProvider.setLastScanTime();
          cameraProvider.setProcessing(true);

          bool isProcess = await onProcessFrame(imageOnFrame);

          if (isProcess) {
            cameraHardwareManager.stopStream();
          }
        } catch (e) {
          developer_log.log(
            'Lỗi xử lý khung hình (Đã bỏ qua để quét tiếp): $e',
            name: 'VisionStreamCoordinator.startVisionLoop',
          );
        } finally {
          if (cameraProvider.cameraStatus == CameraStatus.processing) {
            cameraProvider.setProcessing(false);
          }
        }
      });
    } catch (e) {
      developer_log.log(
        'error on startVisionLoop: $e',
        name: 'VisionStreamCoordinator.startVisionLoop',
      );
      return;
    }
  }
}
