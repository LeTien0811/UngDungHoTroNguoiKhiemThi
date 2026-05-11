import 'package:build_access/core/lifecycle/app_lifecycle_supervisor.dart';
import 'package:build_access/core/navigator/app_router.dart';
import 'package:build_access/core/navigator/binding/auth_binding.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: AuthBinding(),
      initialRoute: AppRouter.splash,
      getPages: AppRouter.routes,
    );
  }
}
