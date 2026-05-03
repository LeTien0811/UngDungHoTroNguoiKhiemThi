import 'dart:ui';
import 'package:build_access/core/scan/pipeline/vision_debug_painter.dart';
import 'package:build_access/services/camera_hardware_service.dart';
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
import 'package:build_access/enum/state.dart';
import 'package:build_access/models/scan/frame_quality_evaluator_result.dart';
import 'package:build_access/models/scan/scan_result.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
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

  final SpatialTextAnalyzer _spatialTextAnalyzer = getIt<SpatialTextAnalyzer>();

  final FrameQualityEvaluator _frameQualityEvaluator = getIt<FrameQualityEvaluator>();

  Future<ScanResult> _handleErrorResult(
    ScanStatus status,
    String command,
  ) async {
    bool isThresholdReached = _scanQualityManager.isThresholdReached(status);

    if (isThresholdReached) {
      if (status == ScanStatus.blur) {
        await _cameraHardwareManager.startFocus();
      }
      return ScanResult(status, command: command);
    }

    return ScanResult(status, command: "");
  }

  void _exportDebugImageInBackground(Uint8List debugBytes, RecognizedText text, int rotationDegree) {
    Future.microtask(() async {
      try {
        final Uint8List? boxedImageBytes = await VisionDebugPainter.drawTextBoundingBoxes(
          debugBytes,
          text,
        );

        if (boxedImageBytes != null) {
          ImageDebugUtils.saveDebugImage(
            boxedImageBytes,
            rotationDegree: rotationDegree,
          );
        }
      } catch (e) {
        developer_log.log("Lỗi ghi file debug: $e", name: "ScanOrchestrator");
      }
    });
  }

  Future<ScanResult> process(CameraImage imageFromFrame) async {
    try {
      FrameQualityEvaluatorResult resultFormat = await _frameQualityEvaluator.
          processImageFromFrame(
            imageFromFrame,
            _cameraHardwareManager.camera!,
            _cameraHardwareManager.controller!,
          );

      if (resultFormat.status != ScanStatus.ok) {
        return await _handleErrorResult(
          resultFormat.status,
          "Ảnh mờ vui lòng thử lại",
        );
      }

      InputImage inputImage = resultFormat.image!;
      Rect? bestObject = await _objectDetectionEngine.detectBestObject(
        inputImage,
      );

      if (bestObject == null) {
        return await _handleErrorResult(
          ScanStatus.notFoundObject,
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

      final Map<String, dynamic>? openCvPreprocess = await _ocrPreprocessor.processImage(
        imageFromFrame.planes[0].bytes,
        imageFromFrame.width,
        imageFromFrame.height,
        crop: mappedCrop,
      ) as Map<String, dynamic>?;

      if (openCvPreprocess == null) {
        developer_log.log("Lỗi: Isolate OpenCV trả về null", name: "ScanOrchestrator");
        return await _handleErrorResult(
          ScanStatus.recapture,
          "Ảnh không rõ nét, vui lòng thử lại.",
        );
      }

      final Uint8List optimizedBytes = openCvPreprocess['ocrBytes'] as Uint8List;
      final Uint8List debugBytes = openCvPreprocess['debugBytes'] as Uint8List;
      final int outW = openCvPreprocess['outW'] as int;
      final int outH = openCvPreprocess['outH'] as int;

      if (optimizedBytes.isEmpty) {
        return await _handleErrorResult(
          ScanStatus.recapture,
          "Ánh sáng yếu hoặc ảnh mờ, vui lòng thử lại.",
        );
      }

      final int rotationDegree = resolveRotationDegree(_cameraHardwareManager);

      final InputImage ocrInputImage = InputImage.fromBytes(
        bytes: optimizedBytes,
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

      if (spatialResult.status != ScanStatus.ok) {
        return await _handleErrorResult(
          spatialResult.status,
          spatialResult.command ??
              "Không nhận diện được nội dung, vui lòng thử lại",
        );
      }

      _scanQualityManager.isThresholdReached(ScanStatus.ok);

      if (kDebugMode && debugBytes.isNotEmpty) {
        _exportDebugImageInBackground(debugBytes, recognizedText, rotationDegree);
      }


      return spatialResult;
    } catch (e) {
      developer_log.log(
        "lỗi ở ScanOrchestrator: $e",
        name: "ScanOrchestrator.process",
      );
      return await _handleErrorResult(
        ScanStatus.error,
        "Ứng dụng gặp xí lỗi rùi, bạn vui lòng thoát ứng dụn và mở lại nhe",
      );
    }
  }

}
