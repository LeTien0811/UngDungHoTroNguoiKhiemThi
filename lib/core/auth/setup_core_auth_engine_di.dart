import 'package:build_access/core/auth/auth_storage_engine.dart';
import 'package:get_it/get_it.dart';

class SetupCoreAuthEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<AuthStorageEngine>(() => AuthStorageEngine());
  }
}
