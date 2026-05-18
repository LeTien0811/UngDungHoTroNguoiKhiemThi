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
import 'package:get/get.dart';

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
    await _voice.speak('onboarding_hold_to_talk'.tr);
  }

  void startWalkieTalkie() {
    developer_log.log("BỘ ĐÀM: Bắt đầu thu...", name: "UserProfileEngine");
    _voice.stopSpeaking();
    _voice.startListening();
  }

}
