import 'package:build_access/core/localization/translations/err_network_translations.dart';
import 'package:build_access/core/localization/translations/vision_asisstant_translations.dart';
import 'package:build_access/core/localization/translations/voice_confirm_translations.dart';
import 'package:get/get.dart';
import 'translations/common_translations.dart';
import 'translations/setting_translations.dart';
import 'translations/voice_command_translations.dart';
import 'translations/scan_translations.dart';
import 'translations/ai_translations.dart';
import 'translations/auth_translations.dart';
import 'translations/onboarding_translations.dart';
import 'translations/home_translations.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': _mergeMaps([
      CommonTranslations.enUS,
      SettingTranslations.enUS,
      VoiceCommandTranslations.enUS,
      ScanTranslations.enUS,
      AiTranslations.enUS,
      AuthTranslations.enUS,
      OnboardingTranslations.enUS,
      HomeTranslations.enUS,
      ErrNetworkTranslations.enUS,
      VisionAsisstantTranslations.enUS,
      VoiceConfirmTranslations.enUS,
    ]),
    'vi_VN': _mergeMaps([
      CommonTranslations.viVN,
      SettingTranslations.viVN,
      VoiceCommandTranslations.viVN,
      ScanTranslations.viVN,
      AiTranslations.viVN,
      AuthTranslations.viVN,
      OnboardingTranslations.viVN,
      HomeTranslations.viVN,
      ErrNetworkTranslations.viVN,
      VisionAsisstantTranslations.viVN,
      VoiceConfirmTranslations.viVN,
    ]),
  };

  Map<String, String> _mergeMaps(List<Map<String, String>> maps) {
    return maps.fold({}, (map1, map2) => map1..addAll(map2));
  }
}
