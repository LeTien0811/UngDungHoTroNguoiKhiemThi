import 'package:build_access/services/auth/passkey_auth_service.dart';
import 'package:build_access/services/auth/token_storage_service.dart';
import 'package:get_it/get_it.dart';

class SetupAuthDi {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<PasskeyAuthService>(() => PasskeyAuthService());
    getIt.registerLazySingleton<TokenStorageService>(() => TokenStorageService());
  }
}