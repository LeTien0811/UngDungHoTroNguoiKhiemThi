import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hotronguoikhiemthi_app/services/log_error_services.dart';
import 'package:hotronguoikhiemthi_app/util/algorithm_image.dart';
import 'package:hotronguoikhiemthi_app/util/ml_process.dart';

class CameraServices {
  final CameraDescription camera;
  late CameraController? _controller;


  bool _isProcessing = false;
  bool _isAutoCapturing = false;
  DateTime _lastScanTime = DateTime.now();
  final int _throttleDuration = 500;

  final Function(String message) onGuidance;

  CameraServices(this.camera, this.onGuidance);

  Future<void> initialize() async {
    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
  }

  CameraController get cameraController => _controller!;

  bool get isProcessing => _isProcessing;

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  void startImageStream() {
    _controller!.startImageStream((CameraImage image) {
      if (_isProcessing || _isAutoCapturing) return;

      if (DateTime.now().difference(_lastScanTime).inMilliseconds <
          _throttleDuration) {
        return;
      }

      _lastScanTime = DateTime.now();
      _processFrame(image);
    });
  }

  Future<void> _triggerAutoCapture() async {
    _isAutoCapturing = true;
    onGuidance("Đang chụp, giữ yên...");
    await _controller!.stopImageStream();
    try {
      final XFile image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await MlProcess.textRecognizer.processImage(inputImage);
      LogErrorServices.showLog(where: 'CameraService', type: 'Du lieu tra ve', message: '$recognizedText');
    } catch (e) {
      _isAutoCapturing = false;
      startImageStream(); // Thử lại nếu lỗi
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessing || _isAutoCapturing) return;
    _isProcessing = true;
    try {
      double blurScore = AlgorithmImage.calculateBlurScore(image);
      if (blurScore < 500) {
        LogErrorServices.showLog(
          where: 'CameraService',
          type: 'xử lý ảnh',
          message: 'Ảnh mờ dưới 500',
        );
        _isProcessing = false;
        return;
      }
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final recognizedText = await MlProcess.textRecognizer.processImage(inputImage);

      if (recognizedText.blocks.isEmpty) {
      } else {
        AlgorithmImage.analyzeTextPosition(
          recognizedText,
          image.width,
          image.height,
          onGuidance,
          _triggerAutoCapture,
        );
      }
    } catch (e) {
      LogErrorServices.showLog(
        where: 'CameraService',
        type: 'xử lý ảnh',
        message: 'lỗi khi quét $e',
      );
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || (Platform.isAndroid && format != InputImageFormat.nv21) || (Platform.isIOS && format != InputImageFormat.bgra8888))  return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<void> stopStream() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) return;

      await _controller!.stopImageStream();
      await _controller!.dispose();
      _controller = null;
    } catch (e) {
      LogErrorServices.showLog(
        where: 'CameraService -> stopStream',
        type: 'xử lý ảnh',
        message: 'lỗi dừng quét $e',
      );
      _isProcessing = false;
    }
  }

  void dispose() {
    _controller!.dispose();
  }
}
