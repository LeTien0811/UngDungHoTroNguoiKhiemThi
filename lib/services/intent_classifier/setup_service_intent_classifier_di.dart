import 'package:build_access/services/intent_classifier/intent_ffi_service.dart';
import 'package:get_it/get_it.dart';

class SetupServiceIntentClassifierDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<IntentFFIService>(
      () => IntentFFIService(),
      dispose: (e) => e.dispose(),
    );
  }
}
