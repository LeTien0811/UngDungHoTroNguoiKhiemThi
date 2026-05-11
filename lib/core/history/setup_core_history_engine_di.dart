import 'package:build_access/core/history/history_engine.dart';
import 'package:get_it/get_it.dart';

class SetupCoreHistoryEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<HistoryEngine>(
      () => HistoryEngine(),
    );
  }
}
