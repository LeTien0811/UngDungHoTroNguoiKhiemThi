import 'dart:async';

import 'package:build_access/core/local_ai/local_ai_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/utils/navigator_service.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/features/home_feature/home_features.dart';
import 'package:build_access/models/AI/ai_form_factory.dart';
import 'package:build_access/models/user/user_model.dart';
import 'package:build_access/providers/local_ai_provider.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/secure_storage_service.dart';
import 'dart:developer' as developer_log;

class UserProfileEngine {
  final SecureStorageService _secureStorage = getIt<SecureStorageService>();
  final UserProfileProvider _provider = getIt<UserProfileProvider>();
  final LocalAIEngine _localAIEngine = getIt<LocalAIEngine>();
  final LocalAiProvider _aiProvider = getIt<LocalAiProvider>();
  final VoiceInteractionProvider _voice = getIt<VoiceInteractionProvider>();

  final String _key = "user_profile_key";

  Completer<String>? _inputCompleter;

  Future<void> initializer() async {
    try {
      String storage = await _secureStorage.readData(_key) ?? "";
      if (storage.trim().isEmpty) {
        _provider.setUninitialized();
        return;
      }
      UserModel newUser = UserModel.fromJson(storage);
      if(newUser.toString().trim().isNotEmpty) {
        _provider.setUserProfile(newUser);
        developer_log.log("Đã có thông tin người dùng ");
        getIt<NavigatorService>().pushNamedAndRemoveUntil(HomeFeatures.routerName);
        return;
      }

      await _voice.speak(
        "Chưa có thông tin người dùng bạn hãy cung cấp 1 số thông tin để ứng dụng có thể hoạt động tốt hơn sau khi tôi nói xong hãy ấn giữ giữa màn hình và đọc to Họ Tên, Số Điện Thoại và Địa chỉ nhé.",
      );
      return;
    } catch (e) {
      _provider.setError();
      developer_log.log(
        "lỗi xảy ra khi init user: $e",
        name: "UserProfileEngine.initializer",
      );
    }
  }

  Future<bool> getUserProfile() async {
    try {
      if (_aiProvider.status != AIStatus.ready) {
        await _voice.speak(
          "Hệ thống chưa sẵn sàng, vui lòng khởi động lại ứng dụng!",
        );

        developer_log.log(
          "Hệ thống cưa sẵn sàng khởi động lại!",
          name: "UserProfileEngine.getUserProfile",
        );

        return false;
      }

      await _voice.speak(
        "Đến nơi yên tĩnh đọc to rõ thông tin Họ Tên, Số Điện Thoại, và địa chỉ.",
      );

      if(!_voice.isSpeaking) {
        _voice.startListening();
        _inputCompleter = Completer<String>();

        developer_log.log(
          "Chờ người dùng nói!",
          name: "UserProfileEngine.getUserProfile",
        );

        String userVoice = await _inputCompleter!.future;
        String fullPromt = AiPromptFactory.buildExtractBasicProfilePrompt(
          voiceText: userVoice,
        );

        String aiResult = await _localAIEngine.executeTask(fullPromt);
        String cleanJsonString = _extractJsonBlock(aiResult);

        developer_log.log(
          "Kết quả trả về: $cleanJsonString",
          name: "UserProfileEngine.getUserProfile",
        );

        UserModel userFinal = UserModel.fromJson(aiResult);
        await _secureStorage.saveData(_key, aiResult);
        _provider.setUserProfile(userFinal);

        _voice.speak("Thiết lập thành công. Xin chào ${userFinal.name}.");
      }
      return true;
    } catch (e) {
      developer_log.log(
        "Có lỗi xảy ra: $e",
        name: "UserProfileEngine.notifyUserInputreFinished",
      );
      return false;
    }
  }

  void notifyUserInputFinished() {
    try {
      _voice.stopListening();
      String text = _voice.recognizedText;
      if (_inputCompleter != null && !_inputCompleter!.isCompleted) {
        _inputCompleter!.complete(text);
        _inputCompleter = null;
      }

      return;
    } catch (e) {
      developer_log.log(
        "Có lỗi xảy ra khi yêu cầu thông báo hoàn thành: $e",
        name: "UserProfileEngine.notifyUserInputreFinished",
      );
      return;
    }
  }

  String _extractJsonBlock(String rawText) {
    final RegExp jsonRegex = RegExp(r'\{[\s\S]*\}');
    final match = jsonRegex.firstMatch(rawText);

    if (match != null) {
      return match.group(0)!;
    }

    throw const FormatException("AI không trả về đúng định dạng JSON.");
  }

  void dispose() {
    try {
      // 1. Kiểm tra nếu Completer đang đợi mà chưa hoàn thành
      if (_inputCompleter != null && !_inputCompleter!.isCompleted) {
        // Hoàn thành nó với một chuỗi rỗng hoặc báo lỗi để giải phóng các hàm await
        _inputCompleter!.complete("");
        developer_log.log(
          "Đã giải phóng Completer đang chờ",
          name: "UserProfileEngine.dispose",
        );
      }

      // 2. Gán về null để Garbage Collector dọn dẹp
      _inputCompleter = null;

      developer_log.log(
        "Đã dọn dẹp UserProfileEngine",
        name: "UserProfileEngine.dispose",
      );
    } catch (e) {
      developer_log.log(
        "Lỗi khi dispose UserProfileEngine: $e",
        name: "UserProfileEngine.dispose",
      );
    }
  }
}
