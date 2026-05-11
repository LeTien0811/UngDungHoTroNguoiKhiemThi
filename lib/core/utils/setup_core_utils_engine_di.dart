import 'package:build_access/core/utils/image_debug_utils.dart';
import 'package:build_access/core/utils/stream_voice_helper.dart';
import 'package:get_it/get_it.dart';
// chua su dung getIt
class SetupCoreUtilsEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<ImageDebugUtils>(() => ImageDebugUtils());
    getIt.registerLazySingleton<StreamVoiceHelper>(() => StreamVoiceHelper());
    return;
  }
}
