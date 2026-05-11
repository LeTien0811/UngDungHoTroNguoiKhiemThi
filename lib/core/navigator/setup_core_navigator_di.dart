import 'package:build_access/core/navigator/app_navigator.dart';
import 'package:get_it/get_it.dart';

class SetupCoreNavigatorDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<AppNavigator>(() => AppNavigator());
  }
}