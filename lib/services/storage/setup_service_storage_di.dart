import 'package:build_access/services/storage/app_preferences.dart';
import 'package:build_access/services/storage/database_helper.dart';
import 'package:build_access/services/storage/secure_storage_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupServiceStorageDI {
  static Future<void> setupDependency(GetIt getIt) async {
    getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper(),
      dispose: (e) => e.close(),);
    final sharedPrefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<AppPreferences>(AppPreferences(sharedPrefs));
    getIt.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService(),
    );
  }
}
