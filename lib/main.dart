import 'package:build_access/core/lifecycle/app_lifecycle_supervisor.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/utils/navigator_service.dart';
import 'package:build_access/features/camera_feature/camera_features.dart';
import 'package:build_access/features/home_feature/home_features.dart';
import 'package:build_access/features/onboarding_features/onboarding_feature.dart';
import 'package:build_access/features/vision_asisstant_features/vision_asisstant_feature.dart';
import 'package:build_access/features/splash_feature/splash_feature.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  setupDependency();

  final AppLifecycleSupervisor _appLifecycleSupervisor =
      AppLifecycleSupervisor();

  _appLifecycleSupervisor.startSupervising();
  runApp(const HoTroNguoiKhiemThiApp());
}

class HoTroNguoiKhiemThiApp extends StatelessWidget {
  const HoTroNguoiKhiemThiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: getIt<NavigatorService>().navigatorKey,
      home: const SplashFeature(),
      routes: {
        CameraFeatures.routerName: (context) => const CameraFeatures(),
        HomeFeatures.routerName: (context) => const HomeFeatures(),
        VisionAsisstantFeature.routeName: (context) =>
            const VisionAsisstantFeature(),
        SplashFeature.routerName: (context) => const SplashFeature(),
        OnboardingFeature.routerName: (context) => const OnboardingFeature()
      },
    );
  }
}
