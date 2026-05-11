import 'package:build_access/services/AI_service/local_ai_service.dart';
import 'package:build_access/services/AI_service/network_service.dart';
import 'package:build_access/services/API_service/api_service.dart';
import 'package:build_access/services/hardware/haptic_hardware_service.dart';
import 'package:get_it/get_it.dart';

class SetupAIDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<HapticHardwareService>(() => HapticHardwareService());
    getIt.registerLazySingleton<LocalAIService>(() => LocalAIService());
    getIt.registerLazySingleton<NetworkService>(() => NetworkService());
  }
}