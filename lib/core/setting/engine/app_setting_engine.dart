import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/models/setting/app_setting_model.dart';
import 'package:build_access/providers/app_setting_provider.dart';
import 'package:build_access/services/secure_storage_service.dart';
import 'dart:developer' as developer_log;

class AppSettingEngine {
  final SecureStorageService _storageService = getIt<SecureStorageService>();
  final AppSettingProvider settingProvider = getIt<AppSettingProvider>();

  final String _settingsKey = 'secure_app_settings';

  Future<void> initializeEngine() async {
    try {
      final String? rawJson = await _storageService.readData(_settingsKey);

      if (rawJson != null) {
        final AppSettingsModel loadedSettings = AppSettingsModel.fromJson(
          rawJson,
        );
        settingProvider.loadedAppSetting(loadedSettings);
      } else {
        developer_log.log(
          "Chưa có setting nào được lưu",
          name: "AppSettingsEngine",
        );
        settingProvider.setReady();
      }
    } catch (e) {
      developer_log.log("Lỗi nạp cấu hình: $e", name: "AppSettingsEngine");
    }
  }

  Future<void> saveSettings(AppSettingsModel newModel) async {
    try {
      await _storageService.saveData(_settingsKey, newModel.toJson());
      settingProvider.updateSetting(newModel);
    } catch (e) {
      developer_log.log("Lỗi ghi cấu hình: $e", name: "AppSettingEngine");
    }
  }
}
