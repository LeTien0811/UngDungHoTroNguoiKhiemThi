import 'package:build_access/core/image/frame_quality_evaluator.dart';
import 'package:build_access/core/image/mlkit_image_adapter.dart';
import 'package:build_access/core/image/opencv_vision_algorithm.dart';
import 'package:get_it/get_it.dart';

class SetupCoreImageEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<FrameQualityEvaluator>(
      () => FrameQualityEvaluator(),
    );
    getIt.registerLazySingleton<MlKitImageAdapter>(() => MlKitImageAdapter());
    getIt.registerLazySingleton<OpenCVVisionAlgorithm>(
      () => OpenCVVisionAlgorithm(),
    );
  }
}
