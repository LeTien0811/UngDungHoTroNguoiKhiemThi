import 'dart:typed_data';
import 'dart:ui';
import 'package:build_access/services/camera_hardware_serivce.dart';
import 'package:build_access/core/image/coordinate_mapper.dart';
import 'package:build_access/core/image/device_orientation.dart';
import 'package:build_access/core/image/frame_quality_evaluator.dart';
import 'package:build_access/core/scan/analyzer/spatial_text_analyzer.dart';
import 'package:build_access/core/scan/engine/object_detection_engine.dart';
import 'package:build_access/core/scan/engine/text_scan_engine.dart';
import 'package:build_access/core/scan/pipeline/ocr_preprocessor.dart';
import 'package:build_access/core/scan/pipeline/scan_quality_manager.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/utils/file_utils.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/models/scan/frame_quality_evaluator_result.dart';
import 'package:build_access/models/scan/scan_result.dart';
import 'package:camera/camera.dart';
import 'dart:developer' as developer_log;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScanOrchestrator {
  final ObjectDetectionEngine _objectDetectionEngine =
      getIt<ObjectDetectionEngine>();

  final ScanTextEngine _scanTextEngine = getIt<ScanTextEngine>();

  final OcrPreprocessor _ocrPreprocessor = getIt<OcrPreprocessor>();

  final CameraHardwareService _cameraHardwareManager =
      getIt<CameraHardwareService>();

  final ScanQualityManager _scanQualityManager = getIt<ScanQualityManager>();

  final SpatialTextAnalyzer _spatialTextAnalyzer = SpatialTextAnalyzer();

  Future<ScanResult> process(CameraImage imageFromFrame) async {
    try {
      FrameQualityEvaluatorResult resultFormat = await FrameQualityEvaluator()
          .processImageFromFrame(
            imageFromFrame,
            _cameraHardwareManager.camera!,
            _cameraHardwareManager.controller!,
          );

      bool qualityChecker = _scanQualityManager.handleProcessStatus(
        resultFormat.status,
      );

      if (!qualityChecker) {
        return ScanResult(
          resultFormat.status,
          command: "Ảnh mờ vui lòng thử lại",
        );
      }

      InputImage inputImage = resultFormat.image!;
      Rect? bestObject = await _objectDetectionEngine.detectBestObject(
        inputImage,
      );

      if (bestObject == null) {
        return ScanResult(
          ScanStatus.notFoundObject,
          command:
              "Không nhìn thấy vật thể nào phía trước!. Vui lòng đưa điện thoại chạm vào vật muốn quét rồi từ từ đưa ra xa theo đường thẳng tầm 2 gang tay",
        );
      }

      final mappedCrop = CoordinateMapper.mapRotatedMlKitToRawSensor(
        mlKitRect: bestObject,
        imageSize: Size(
          imageFromFrame.width.toDouble(),
          imageFromFrame.height.toDouble(),
        ),
        sensorOrientation: _cameraHardwareManager.camera!.sensorOrientation,
      );

      dynamic openCvPreproces = await _ocrPreprocessor.processImage(
        imageFromFrame.planes[0].bytes,
        imageFromFrame.width,
        imageFromFrame.height,
        crop: mappedCrop,
      );

      if (openCvPreproces == null || openCvPreproces is! Map) {
        developer_log.log("LỖI VĂNG APP NGẦM: Isolate trả về String -> $openCvPreproces");
        return ScanResult(
          ScanStatus.recapture,
          command: "Ảnh mờ vui lòng thử lại",
        );
      }

      Uint8List optimizerdBytes = openCvPreproces['ocrBytes'];
      final Uint8List debugBytes = openCvPreproces['debugBytes'];
      final int outW = openCvPreproces['outW'];
      final int outH = openCvPreproces['outH'];

      if (optimizerdBytes.isEmpty) {
        return ScanResult(
          ScanStatus.recapture,
          command: "Ảnh quá mờ bạn vui lòng giữ yên điện thoại. hoặc đi đến nơi có ánh sáng tốt hơn",
        );
      }

      final int rotationDegree = resolveRotationDegree(_cameraHardwareManager);

      if (debugBytes.isNotEmpty) {
        ImageDebugUtils.saveDebugImage(
          debugBytes,
          rotationDegree: rotationDegree,
        );
      }

      final InputImage ocrInputImage = InputImage.fromBytes(
        bytes: optimizerdBytes,
        metadata: InputImageMetadata(
          size: Size(outW.toDouble(), outH.toDouble()),
          rotation:
              InputImageRotationValue.fromRawValue(rotationDegree) ??
              InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: outW,
        ),
      );

      RecognizedText recognizedText = await _scanTextEngine.processImage(
        ocrInputImage,
      );

      ScanResult spatialResult = _spatialTextAnalyzer.process(
        recognizedText,
        outW,
        outH,
        rotationDegree,
      );

      bool spatialCheck = _scanQualityManager.handleProcessStatus(
        spatialResult.status,
      );

      if (!spatialCheck) {
        return ScanResult(
          spatialResult.status,
          command: spatialResult.command!,
        );
      }

      return spatialResult;
    } catch (e) {
      developer_log.log(
        "lỗi ở ScanOrchestrator: $e",
        name: "ScanOrchestrator.process",
      );
      return ScanResult(ScanStatus.error, command: "Ứng dụng gặp xí lỗi rùi, bạn vui lòng thoát ứng dụn và mở lại nhe");
    }
  }
}
