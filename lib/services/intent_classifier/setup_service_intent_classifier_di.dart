import 'package:build_access/services/hardware/camera_hardware_service.dart';
import 'package:build_access/services/hardware/flash_light_hardware_service.dart';
import 'package:build_access/services/hardware/haptic_hardware_service.dart';
import 'package:get_it/get_it.dart';

class SetupHardwareDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<CameraHardwareService>(() => CameraHardwareService());
    getIt.registerLazySingleton<FlashLightHardwareService>(() => FlashLightHardwareService());
    getIt.registerLazySingleton<HapticHardwareService>(() => HapticHardwareService());
  }
}