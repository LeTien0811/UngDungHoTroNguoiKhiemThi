import 'package:build_access/services/auth/passkey_auth_service.dart';
import 'package:get_it/get_it.dart';

class SetupServiceAuthDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<PasskeyAuthService>(() => PasskeyAuthService());

  }
}