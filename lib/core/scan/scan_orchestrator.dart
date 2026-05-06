import 'dart:ui';
import 'package:build_access/core/scan/pipeline/vision_debug_painter.dart';
import 'package:build_access/services/scan/camera_hardware_service.dart';
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

  // AI-added: Siết vùng OCR về nhãn chính ở giữa vật thể để giảm đọc rác từ
  // mép gói, nền phía sau và phần gập hai bên bao bì.
  Rect _focusPrimaryLabelRegion(Rect objectBox, Size imageSize) {
    final bool isPortraitObject = objectBox.height >= objectBox.width;
    final double horizontalInsetRatio = isPortraitObject ? 0.18 : 0.14;
    final double verticalInsetRatio = isPortraitObject ? 0.08 : 0.12;

    final double insetX = objectBox.width * horizontalInsetRatio;
    final double insetY = objectBox.height * verticalInsetRatio;

    final Rect focused = Rect.fromLTRB(
      objectBox.left + insetX,
      objectBox.top + insetY,
      objectBox.right - insetX,
      objectBox.bottom - insetY,
    );

    return Rect.fromLTRB(
      focused.left.clamp(0.0, imageSize.width),
      focused.top.clamp(0.0, imageSize.height),
      focused.right.clamp(0.0, imageSize.width),
      focused.bottom.clamp(0.0, imageSize.height),
    );
  }

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

  void _exportDebugImageInBackground({
    required Uint8List sceneLumaBytes,
    required int sceneWidth,
    required int sceneHeight,
    required int sceneStride,
    required Rect objectBox,
    required Rect cropBox,
    required Uint8List ocrDebugBytes,
    required RecognizedText text,
    required int rotationDegree,
  }) {
    Future.microtask(() async {
      try {
        final Uint8List? sceneDebugBytes = VisionDebugPainter.drawSceneBoundingBoxes(
          lumaBytes: sceneLumaBytes,
          width: sceneWidth,
          height: sceneHeight,
          stride: sceneStride,
          rotationDegree: rotationDegree,
          objectBox: objectBox,
          cropBox: cropBox,
        );

        if (sceneDebugBytes != null) {
          ImageDebugUtils.saveDebugImage(
            sceneDebugBytes,
            filePrefix: 'scene_debug',
          );
        }

        final Uint8List? boxedImageBytes = await VisionDebugPainter.drawTextBoundingBoxes(
          ocrDebugBytes,
          text,
        );

        if (boxedImageBytes != null) {
          ImageDebugUtils.saveDebugImage(
            boxedImageBytes,
            rotationDegree: rotationDegree,
            filePrefix: 'ocr_crop',
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

      final int objectRotationDegree = resolveRotationDegree(
        _cameraHardwareManager,
      );
      final bool isQuarterTurn =
          objectRotationDegree == 90 || objectRotationDegree == 270;
      final Size mlKitVisibleSize = isQuarterTurn
          ? Size(
              imageFromFrame.height.toDouble(),
              imageFromFrame.width.toDouble(),
            )
          : Size(
            imageFromFrame.width.toDouble(),
            imageFromFrame.height.toDouble(),
            );

      final Rect focusedLabelRegion = _focusPrimaryLabelRegion(
        bestObject,
        mlKitVisibleSize,
      );

      final mappedCrop = CoordinateMapper.mapRotatedMlKitToRawSensor(
        mlKitRect: focusedLabelRegion,
        mlKitImageSize: mlKitVisibleSize,
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

      final int rotationDegree = objectRotationDegree;

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
        _exportDebugImageInBackground(
          sceneLumaBytes: imageFromFrame.planes[0].bytes,
          sceneWidth: imageFromFrame.width,
          sceneHeight: imageFromFrame.height,
          sceneStride: imageFromFrame.planes[0].bytesPerRow,
          objectBox: bestObject,
          cropBox: focusedLabelRegion,
          ocrDebugBytes: debugBytes,
          text: recognizedText,
          rotationDegree: rotationDegree,
        );
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
