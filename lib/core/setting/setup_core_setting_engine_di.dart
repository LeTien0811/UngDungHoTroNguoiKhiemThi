import 'package:build_access/core/AI/ai_orchestrator.dart';
import 'package:build_access/core/AI/api_ai/api_ai_engine.dart';
import 'package:build_access/core/AI/local_ai/local_ai_engine.dart';
import 'package:build_access/core/AI/local_ai/model_downloader_service.dart';
import 'package:build_access/core/camera/vision_stream_coordinator.dart';
import 'package:build_access/core/history/history_engine.dart';
import 'package:build_access/core/image/coordinate_mapper.dart';
import 'package:build_access/core/image/frame_quality_evaluator.dart';
import 'package:build_access/core/image/mlkit_image_adapter.dart';
import 'package:build_access/core/image/opencv_vision_algorithm.dart';
import 'package:build_access/core/scan/analyzer/document_layout_analyzer.dart';
import 'package:build_access/core/scan/analyzer/spatial_text_analyzer.dart';
import 'package:build_access/core/scan/engine/object_detection_engine.dart';
import 'package:build_access/core/scan/engine/paddle_ocr_service.dart';
import 'package:build_access/core/scan/engine/scan_text_engine.dart';
import 'package:build_access/core/scan/enhancer/scan_text_ai_enhancer.dart';
import 'package:build_access/core/scan/pipeline/ocr_preprocessor.dart';
import 'package:build_access/core/scan/pipeline/scan_quality_manager.dart';
import 'package:build_access/core/scan/pipeline/vision_debug_painter.dart';
import 'package:build_access/core/scan/scan_orchestrator.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class SetupCoreScanEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<DocumentLayoutAnalyzer>(
      () => DocumentLayoutAnalyzer(),
    );
    getIt.registerLazySingleton<SpatialTextAnalyzer>(
      () => SpatialTextAnalyzer(),
    );
    getIt.registerLazySingleton<ObjectDetectionEngine>(
      () => ObjectDetectionEngine(),
      dispose: (param) => param.dispose(),
    );
    getIt.registerLazySingleton<PaddleOcrService>(() => PaddleOcrService());
    getIt.registerLazySingleton<ScanTextEngine>(
      () => ScanTextEngine(),
      dispose: (param) => param.dispose(),
    );
    getIt.registerLazySingleton<ScanTextAiEnhancer>(() => ScanTextAiEnhancer());
    getIt.registerLazySingleton<OcrPreprocessor>(
      () => OcrPreprocessor(),
      dispose: (param) => param.dispose(),
    );
    getIt.registerLazySingleton<ScanQualityManager>(() => ScanQualityManager());
    getIt.registerLazySingleton<VisionDebugPainter>(() => VisionDebugPainter());
    getIt.registerLazySingleton<ScanOrchestrator>(() => ScanOrchestrator());
    return;
  }
}
