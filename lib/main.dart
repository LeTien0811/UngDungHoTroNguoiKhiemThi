import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/utils/navigator_service.dart';
import 'package:build_access/features/camera_feature/camera_features.dart';
import 'package:build_access/features/home_feature/home_features.dart';
import 'package:build_access/features/reading_result_feature/reading_result_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setupDependency();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: getIt<NavigatorService>().navigatorKey,
      home: const HomeFeatures(),
      routes: {
        CameraFeatures.routerName: (context) => const CameraFeatures(),
        HomeFeatures.routerName: (context) => const HomeFeatures(),
        ReadingResultFeatures.routeName: (context) =>
            const ReadingResultFeatures(),
      },
    );
  }
}
