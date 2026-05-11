import 'dart:io';
import 'package:camera/camera.dart';
import 'dart:developer' as developer_log;

class CameraHardwareService {
  CameraController? controller;
  CameraDescription? camera;
  bool _isDisposing = false;
  static const ResolutionPreset _previewResolutionPreset = ResolutionPreset.high;

  bool get isCameraStream => controller?.value.isStreamingImages ?? false;
  bool get isInitialized => controller?.value.isInitialized ?? false;
  bool get isDisposing => _isDisposing;

  // AI-added: Flutter camera không nói rõ lens nào là main-wide, nên tạm thời
  // ưu tiên camera sau có id "0" hoặc id số nhỏ nhất. Trên đa số máy Android,
  // đây là lựa chọn gần với camera chính hơn cách lấy "camera sau đầu tiên".
  CameraDescription? _pickPreferredBackCamera(List<CameraDescription> cameras) {
    final backCameras = cameras
        .where((cam) => cam.lensDirection == CameraLensDirection.back)
        .toList();

    if (backCameras.isEmpty) return cameras.isNotEmpty ? cameras.first : null;

    backCameras.sort((a, b) {
      final int scoreA = _cameraPreferenceScore(a);
      final int scoreB = _cameraPreferenceScore(b);
      return scoreA.compareTo(scoreB);
    });

    return backCameras.first;
  }

  // AI-added: score nhỏ hơn thì ưu tiên hơn. Name "0" thường là main camera.
  int _cameraPreferenceScore(CameraDescription camera) {
    final String name = camera.name.trim();
    final int? numericId = int.tryParse(name);
    if (numericId != null) {
      return numericId;
    }
    if (name == '0') return 0;
    return 1000;
  }

  Future<CameraDescription?> getBackCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // AI-added: Log toàn bộ camera để xác định máy đang trả về những lens nào.
        for (final cam in cameras) {
          developer_log.log(
            'camera=${cam.name} lens=${cam.lensDirection} sensorOrientation=${cam.sensorOrientation}',
            name: 'CameraHardwareService.getBackCamera',
          );
        }

        final backCamera = _pickPreferredBackCamera(cameras);

        if (backCamera != null) {
          developer_log.log(
            'Chọn camera=${backCamera.name} lens=${backCamera.lensDirection} sensorOrientation=${backCamera.sensorOrientation}',
            name: 'CameraHardwareService.getBackCamera',
          );
        }

        return backCamera;
      }
    } catch (e) {
      developer_log.log(
        "Lỗi khởi tạo Camera: $e",
        name: 'CameraHardwareService.getFirstCamera',
      );
      return null;
    }
    return null;
  }

  Future<bool> init() async {
    try {
      if (_isDisposing) return false;

      if (controller != null) {
        if (controller!.value.isInitialized) return true;

        await controller!.dispose();
        controller = null;
      }

      camera = await getBackCamera();
      if (camera == null) return false;

      controller = CameraController(
        camera!,
        _previewResolutionPreset,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller!.initialize();
      developer_log.log(
        'Khởi tạo camera xong: preset=$_previewResolutionPreset previewSize=${controller!.value.previewSize} aspectRatio=${controller!.value.aspectRatio}',
        name: 'CameraHardwareService.init',
      );
      return true;
    } catch (e) {
      developer_log.log(
        'crash init camera',
        name: "CameraHardwareService.init",
      );
      return false;
    }
  }

  Future<bool> startFocus() async {
    try {
      final CameraController? activeController = controller;
      if (_isDisposing || activeController == null || !activeController.value.isInitialized) {
        return false;
      }
      await activeController.setFocusMode(FocusMode.auto);
      return true;
    } catch (e) {
      developer_log.log(
        'error on startFocus HardWare: $e',
        name: 'CameraHardwareService.startFocus',
      );
      return false;
    }
  }

  Future<void> startRawStream<T>(
    Future<T> Function(CameraImage image) onProcessFrame,
  ) async {
    try {
      final CameraController? activeController = controller;
      if (_isDisposing || activeController == null || !activeController.value.isInitialized) {
        return;
      }

      if (activeController.value.isStreamingImages) {
        return;
      }

      await activeController.startImageStream((CameraImage imageOnFrame) async {
        if (_isDisposing || controller != activeController) {
          return;
        }
        await onProcessFrame(imageOnFrame);
      });
    } catch (e) {
      developer_log.log(
        'error on Start RawStream HardWare: $e',
        name: 'CameraHardwareService.startRawStream',
      );
      return;
    }
  }

  Future<bool> stopStream() async {
    try {
      final CameraController? activeController = controller;
      if (activeController != null && activeController.value.isStreamingImages) {
        await activeController.stopImageStream();
        developer_log.log(
          'Dừng camera',
          name: 'CameraHardwareService.stopStream',
        );
        return true;
      }
      return false;
    } catch (e) {
      developer_log.log(
        'Lỗi dừng stream: $e',
        name: 'CameraHardwareService.stopStream',
      );
      return false;
    }
  }

  Future<bool> dispose() async {
    if (_isDisposing) return false;
    try {
      _isDisposing = true;
      developer_log.log('Hủy camera', name: 'CameraHardwareService.stopStream');
      final CameraController? activeController = controller;
      controller = null;
      camera = null;

      if (activeController != null) {
        if (activeController.value.isStreamingImages) {
          await activeController.stopImageStream();
        }
        await activeController.dispose().then((_) {
          developer_log.log('Hủy camera xong', name: 'CameraHardwareService.stopStream');
        });
        return true;
      }
      return false;
    } catch (e) {
      developer_log.log(
        "Dispose error: $e",
        name: 'CameraHardwareService.dispose',
      );
      return false;
    } finally {
      _isDisposing = false;
    }
  }
}
