import 'package:build_access/core/onboarding//user_profile_engine.dart';
import 'package:build_access/core/onboarding/onboarding_engine.dart';
import 'package:get_it/get_it.dart';

class SetupCoreOnboardingEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<OnboardingEngine>(() => OnboardingEngine());
    getIt.registerLazySingleton<UserProfileEngine>(() => UserProfileEngine());
    return;
  }
}
