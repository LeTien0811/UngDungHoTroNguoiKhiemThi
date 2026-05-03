import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/models/setting/app_setting_model.dart';
import 'dart:developer' as developer_log;

class AppSettingProvider extends BaseModel {
  SettingStatus status = SettingStatus.uninitialized;
  AppSettingsModel appSetting = AppSettingsModel();

  void loadedAppSetting (AppSettingsModel propSettingApp) {
    try {
      setProcess();
      appSetting = propSettingApp;
      status = SettingStatus.idle;
      notifyListeners();
      developer_log.log("nạp thành công app Setting", name: "AppSettingProvider.loadedAppSetting");
    } catch(e) {
      developer_log.log("Lỗi nạp: $e", name: "AppSettingProvider.loadedAppSetting");
      setError();
    }
  }

  void updateSetting(AppSettingsModel newSetting) {
    appSetting = newSetting;
    notifyListeners();
  }

  void setProcess() {
    status = SettingStatus.processing;
    notifyListeners();
  }

  void setReady() {
    status = SettingStatus.idle;
    notifyListeners();
  }

  void setUninitialized() {
    status = SettingStatus.uninitialized;
    notifyListeners();
  }

  void setError() {
    status = SettingStatus.error;
    notifyListeners();
  }
}
