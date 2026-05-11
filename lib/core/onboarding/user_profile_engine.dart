import 'dart:async';
import 'package:build_access/core/AI/ai_orchestrator.dart';
import 'package:build_access/core/speech/speech_to_text/speech_to_text_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/utils/extract_json_block.dart';
import 'package:build_access/core/navigator/app_navigator.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/features/home_feature/home_features.dart';
import 'package:build_access/models/user/user_model.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/storage/secure_storage_service.dart';
import 'dart:developer' as developer_log;

class UserProfileEngine {
  final SecureStorageService _secureStorage = getIt<SecureStorageService>();
  final UserProfileProvider _provider = getIt<UserProfileProvider>();
  final AIOrchestrator _aiEngine = getIt<AIOrchestrator>();
  final VoiceInteractionProvider _voice = getIt<VoiceInteractionProvider>();
  final SpeechToTextEngine _speechToTextEngine = getIt<SpeechToTextEngine>();
  final String _key = "user_profile_key";
  Future<void> initializer() async {
    try {
      String storage = await _secureStorage.readData(_key) ?? "";
      if (storage.trim().isEmpty) {
        _provider.setUninitialized();
        return;
      }

      UserModel newUser = UserModel.fromJson(storage);
      if (newUser.toString().trim().isNotEmpty) {
        _provider.setUserProfile(newUser);
        getIt<AppNavigator>().pushNamedAndRemoveUntil(HomeFeatures.routerName);
        return;
      }
    } catch (e) {
      _provider.setError();
      developer_log.log("Lỗi khởi tạo user: $e", name: "UserProfileEngine");
    }
  }

  Future<void> speakInstruction() async {
    await _voice.speak(
      "Nhấn giữ vòng tròn trên màn hình để nói, thả tay ra khi bạn đã nói xong.",
    );
  }

  void startWalkieTalkie() {
    developer_log.log("BỘ ĐÀM: Bắt đầu thu...", name: "UserProfileEngine");
    _voice.stopSpeaking();
    _voice.startListening();
  }

  Future<bool> stopWalkieTalkieAndProcessAI() async {
    try {
      String userVoice = await _speechToTextEngine.stopWalkieTalkie();

      if (userVoice.trim().isEmpty) {
        await _voice.speak("Tôi chưa nghe rõ, vui lòng nhấn giữ và thử lại.");
        developer_log.log("User Voice Rỗng", name: "UserProfileEngine");
        return false;
      }

      developer_log.log(
        "Tiến hành phân tích AI $userVoice",
        name: "UserProfileEngine.getUserProfile",
      );

      await _voice.speak("Đang phân tích dữ liệu, vui lòng đợi...");

      final Stream<String> aiStream = _aiEngine.executeAiTask(
        type: AIType.BUILD_EXTRACT_BASIC_PROFILE,
        data: userVoice,
        userText: "",
        userProfile: "",
        history: "",
      );

      StringBuffer cleanContentBuffer = StringBuffer();
      await for (final chunk in aiStream) {
        cleanContentBuffer.write(chunk);
      }
      String fullRawResponse = cleanContentBuffer.toString();
      developer_log.log(
        "Tổng nội dung đã ghép: $fullRawResponse",
        name: "UserProfileEngine",
      );
      String cleanJsonString = extractJsonBlock(fullRawResponse);
      developer_log.log(
        "Kết quả JSON: $cleanJsonString",
        name: "UserProfileEngine",
      );

      developer_log.log(
        "Kết quả trả về: $cleanJsonString",
        name: "UserProfileEngine.getUserProfile",
      );

      UserModel userFinal = UserModel.fromJson(cleanJsonString);
      await _secureStorage.saveData(_key, cleanJsonString);
      _provider.setUserProfile(userFinal);

      await _voice.speak("Thiết lập thành công. Xin chào ${userFinal.name}.");

      getIt<AppNavigator>().pushNamedAndRemoveUntil(HomeFeatures.routerName);

      return true;
    } catch (e) {
      developer_log.log(
        "Có lỗi xảy ra: $e",
        name: "UserProfileEngine.notifyUserInputreFinished",
      );
      return false;
    }
  }
}
