import 'package:build_access/services/API_service/api_service.dart';
import 'package:get_it/get_it.dart';

class SetupServiceNetworkDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<APIService>(() => APIService());
  }
}