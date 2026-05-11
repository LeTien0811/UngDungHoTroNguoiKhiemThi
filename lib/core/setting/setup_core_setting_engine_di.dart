import 'package:build_access/core/setting/engine/AI/ai_setting.dart';
import 'package:build_access/core/setting/engine/app_setting_engine.dart';
import 'package:build_access/core/setting/engine/hardware/flash_setting.dart';
import 'package:build_access/core/setting/engine/hardware/haptic_setting.dart';
import 'package:build_access/core/setting/engine/speech/speech_setting.dart';
import 'package:build_access/core/setting/setting_orchestrator.dart';
import 'package:get_it/get_it.dart';

class SetupCoreSettingEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<AiSetting>(() => AiSetting());
    getIt.registerLazySingleton<FlashSetting>(() => FlashSetting());
    getIt.registerLazySingleton<HapticSetting>(() => HapticSetting());
    getIt.registerLazySingleton<SpeechSetting>(() => SpeechSetting());

    getIt.registerLazySingleton<AppSettingEngine>(() => AppSettingEngine());
    getIt.registerLazySingleton<SettingOrchestrator>(
      () => SettingOrchestrator(),
    );
    return;
  }
}
