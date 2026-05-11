import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/models/setting/app_setting_model.dart';
import 'package:build_access/providers/app_setting_provider.dart';
import 'package:build_access/services/storage/app_preferences.dart';
import 'dart:developer' as developer_log;

class AppSettingEngine {
  final AppPreferences _storageService = getIt<AppPreferences>();
  final AppSettingProvider settingProvider = getIt<AppSettingProvider>();

  final String _settingsKey = 'secure_app_settings';

  Future<void> initializeEngine() async {
    try {
      final Map<String, dynamic>? rawJson = _storageService.readObject(
        _settingsKey,
      );

      if (rawJson != null) {
        final AppSettingsModel loadedSettings = AppSettingsModel.fromMap(
          rawJson,
        );
        settingProvider.loadedAppSetting(loadedSettings);
        return;
      } else {
        final AppSettingsModel loadedSettings = AppSettingsModel();
        await _storageService.saveObject(_settingsKey, loadedSettings.toMap());
        settingProvider.loadedAppSetting(loadedSettings);
        return;
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
