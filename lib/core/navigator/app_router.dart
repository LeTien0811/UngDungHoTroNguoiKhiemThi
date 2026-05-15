import 'package:build_access/core/navigator/binding/camera_binding.dart';
import 'package:build_access/core/navigator/binding/home_binding.dart';
import 'package:build_access/core/navigator/binding/onboarding_binding.dart';
import 'package:build_access/core/navigator/binding/splash_binding.dart';
import 'package:build_access/core/navigator/binding/vision_assistant_binding.dart';
import 'package:build_access/features/camera_feature/camera_features.dart';
import 'package:build_access/features/home_feature/home_features.dart';
import 'package:build_access/features/onboarding_features/onboarding_feature.dart';
import 'package:build_access/features/splash_feature/splash_feature.dart';
import 'package:build_access/features/vision_asisstant_features/vision_asisstant_feature.dart';
import 'package:build_access/features/history_feature/history_feature.dart';
import 'package:build_access/core/navigator/binding/history_binding.dart';
import 'package:get/get.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String camera = '/camera';
  static const String visionAssistant = '/vision_assistant';
  static const String history = '/history';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashFeature(),
      binding: SplashBinding()
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingFeature(),
      binding: OnboardingBinding()
    ),
    GetPage(
      name: home,
      page: () => const HomeFeatures(),
      binding: HomeBinding()
    ),
    GetPage(
      name: camera,
      page: () => const CameraFeatures(),
      binding: CameraBinding()
    ),
    GetPage(
      name: visionAssistant,
      page: () => const VisionAsisstantFeature(),
      binding: VisionAssistantBinding()
    ),
    GetPage(
      name: history,
      page: () => const HistoryFeature(),
      binding: HistoryBinding()
    ),
  ];
}