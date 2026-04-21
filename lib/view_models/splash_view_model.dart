import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/local_ai/local_ai_engine.dart';
import 'package:build_access/core/local_ai/model_downloader_service.dart';
import 'package:build_access/core/setups/permissions_setup.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/utils/navigator_service.dart';
import 'package:build_access/features/home_feature/home_features.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';

class SplashViewModel extends BaseModel{
  NavigatorService navigatorService = getIt<NavigatorService>();
  VoiceInteractionProvider voiceInteractionProvider = getIt<VoiceInteractionProvider>();
  LocalAIEngine localAIEngine = getIt<LocalAIEngine>();

  bool hasMicPermission = false;
  bool hasCameraPermission = false;

  Future<void> initializerApp() async{
    await voiceInteractionProvider.initializeVoice();

    hasCameraPermission = await PermissionsSetup.checkCameraPermissions(hasCameraPermission, voiceInteractionProvider.speak);
    hasMicPermission = await PermissionsSetup.checkMicPermissions(hasMicPermission, voiceInteractionProvider.speak);

    if (hasCameraPermission && hasMicPermission) {
      voiceInteractionProvider.speak("Hệ thống đã sẵn sàng.");
      voiceInteractionProvider.speak("Vuốt từ trên xuống để quét nhận diện mà không cần mạng");
      voiceInteractionProvider.speak("Vuốt từ dưới lên để quét thông minh");

      try {
        String getPathLocationModel = await getIt<ModelDownloaderService>().downloadModel(onProgress: voiceInteractionProvider.speak);
        await localAIEngine.initializeSystem(getPathLocationModel);
      } catch(e) {
        voiceInteractionProvider.speak("$e");
      }
      navigatorService.pushNamedAndRemoveUntil(HomeFeatures.routerName);
    } else {
      voiceInteractionProvider.speak("Vui lòng cấp quyền camera và micro trong cài đặt để sử dụng ứng dụng.");
    }
  }
}