import 'package:build_access/core/setting/engine/app_setting_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/models/setting/app_setting_model.dart';
import 'dart:developer' as developer_log;

class AiSetting {
  final AppSettingEngine _appSettingEngine = getIt<AppSettingEngine>();

  Future<void> process() async {
    final currentSetting = _appSettingEngine.settingProvider.appSetting;
    final AppSettingsModel newModel = currentSetting.copyWith(
      aiShortResponse: !currentSetting.aiShortResponse,
    );

    await _appSettingEngine.saveSettings(newModel);

    developer_log.log(
      "Đã đổi chế độ phản hồi ngắn thành: ${newModel.aiShortResponse}",
      name: "AppSettingEngine",
    );
  }
}
