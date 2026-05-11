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
import 'package:build_access/core/setting/engine/AI/ai_setting.dart';
import 'package:build_access/core/setting/engine/app_setting_engine.dart';
import 'package:build_access/core/setting/engine/hardware/flash_setting.dart';
import 'package:build_access/core/setting/engine/hardware/haptic_setting.dart';
import 'package:build_access/core/setting/engine/speech/speech_setting.dart';
import 'package:build_access/core/setting/setting_orchestrator.dart';
import 'package:build_access/core/setups/permissions_setup.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class SetupCoreSettingEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerFactory<PermissionsSetup>(() => PermissionsSetup());
    return;
  }
}
