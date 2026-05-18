import 'package:build_access/core/lifecycle/app_lifecycle_supervisor.dart';
import 'package:build_access/core/navigator/app_router.dart';
import 'package:build_access/core/navigator/binding/auth_binding.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:build_access/core/localization/app_translations.dart';
import 'package:build_access/providers/app_setting_provider.dart';
import 'dart:developer' as developer_log;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp();

  await setupDependency();

  final AppLifecycleSupervisor _appLifecycleSupervisor =
      AppLifecycleSupervisor();

  _appLifecycleSupervisor.startSupervising();
  runApp(const HoTroNguoiKhiemThiApp());
}

class HoTroNguoiKhiemThiApp extends StatelessWidget {
  const HoTroNguoiKhiemThiApp({super.key});
  @override
  Widget build(BuildContext context) {
    final appSetting = getIt<AppSettingProvider>().appSetting;
    final localeParts = appSetting.ttsLanguage.split('-');
    final locale = localeParts.length == 2
        ? Locale(localeParts[0], localeParts[1])
        : const Locale('vi', 'VN');
    developer_log.log("Ngôn ngữ: ${locale.toLanguageTag()}", name: "main");

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: locale,
      fallbackLocale: const Locale('vi', 'VN'),
      initialBinding: AuthBinding(),
      initialRoute: AppRouter.splash,
      getPages: AppRouter.routes,
    );
  }
}
