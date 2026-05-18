import 'package:build_access/core/scan/analyzer/spatial_text_analyzer.dart';
import 'package:build_access/core/scan/engine/object_detection_engine.dart';
import 'package:build_access/core/scan/engine/scan_text_engine.dart';
import 'package:build_access/core/scan/pipeline/ocr_preprocessor.dart';
import 'package:build_access/core/scan/pipeline/scan_quality_manager.dart';
import 'package:build_access/core/scan/scan_orchestrator.dart';
import 'package:get_it/get_it.dart';

class SetupCoreScanEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<SpatialTextAnalyzer>(
      () => SpatialTextAnalyzer(),
    );
    getIt.registerLazySingleton<ObjectDetectionEngine>(
      () => ObjectDetectionEngine(),
      dispose: (param) => param.dispose(),
    );
    getIt.registerLazySingleton<ScanTextEngine>(
      () => ScanTextEngine(),
      dispose: (param) => param.dispose(),
    );
    getIt.registerLazySingleton<OcrPreprocessor>(
      () => OcrPreprocessor(),
      dispose: (param) => param.dispose(),
    );
    getIt.registerLazySingleton<ScanQualityManager>(() => ScanQualityManager());
    getIt.registerLazySingleton<ScanOrchestrator>(() => ScanOrchestrator());
    return;
  }
}
