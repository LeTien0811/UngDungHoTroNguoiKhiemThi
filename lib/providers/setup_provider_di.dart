import 'package:build_access/providers/AI/api_ai_provider.dart';
import 'package:build_access/providers/AI/local_ai_provider.dart';
import 'package:build_access/providers/app_setting_provider.dart';
import 'package:build_access/providers/camera_provider.dart';
import 'package:build_access/providers/intent_classifier_provider.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:get_it/get_it.dart';

class SetupProviderDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<VoiceInteractionProvider>(
      () => VoiceInteractionProvider(),
      dispose: (e) => e.dispose(),
    );
    getIt.registerLazySingleton<AppSettingProvider>(
      () => AppSettingProvider(),
      dispose: (e) => e.dispose(),
    );
    getIt.registerLazySingleton<UserProfileProvider>(
      () => UserProfileProvider(),
    );
    getIt.registerLazySingleton<CameraProvider>(
      () => CameraProvider(),
      dispose: (e) => e.dispose(),
    );
    getIt.registerLazySingleton<IntentClassifierProvider>(
      () => IntentClassifierProvider(),
        dispose: (e) => e.dispose(),
    );
    getIt.registerLazySingleton<APIAIProvider>(() => APIAIProvider());
    getIt.registerLazySingleton<LocalAiProvider>(
      () => LocalAiProvider(),
      dispose: (e) => e.dispose(),
    );
  }
}
