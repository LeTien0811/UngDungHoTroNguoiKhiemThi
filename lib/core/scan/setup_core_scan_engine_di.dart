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
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class SetupCoreImageEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<CoordinateMapper>(() => CoordinateMapper());
    getIt.registerLazySingleton<FrameQualityEvaluator>(
      () => FrameQualityEvaluator(),
    );
    getIt.registerLazySingleton<MlKitImageAdapter>(() => MlKitImageAdapter());
    getIt.registerLazySingleton<OpenCVVisionAlgorithm>(
      () => OpenCVVisionAlgorithm(),
    );
  }
}
