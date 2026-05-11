import 'package:build_access/services/hardware/camera_hardware_service.dart';
import 'package:build_access/services/hardware/flash_light_hardware_service.dart';
import 'package:build_access/services/hardware/haptic_hardware_service.dart';
import 'package:build_access/services/intent_classifier/intent_ffi_service.dart';
import 'package:get_it/get_it.dart';

class SetupServiceIntentClassifierDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<IntentFFIService>(() => IntentFFIService());
  }
}