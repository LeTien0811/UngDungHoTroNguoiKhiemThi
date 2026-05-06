import 'dart:async';
import 'dart:convert';

import 'package:build_access/core/AI/ai_orchestrator.dart';
import 'package:build_access/core/AI/local_ai/local_ai_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/utils/navigator_service.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/features/home_feature/home_features.dart';
import 'package:build_access/models/AI/ai_form_factory.dart';
import 'package:build_access/models/user/user_model.dart';
import 'package:build_access/providers/AI/local_ai_provider.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/secure_storage_service.dart';
import 'dart:developer' as developer_log;

class UserProfileEngine {
  final SecureStorageService _secureStorage = getIt<SecureStorageService>();
  final UserProfileProvider _provider = getIt<UserProfileProvider>();
  final AIOrchestrator _aiEngine = getIt<AIOrchestrator>();
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
      if (newUser.toString().trim().isNotEmpty) {
        _provider.setUserProfile(newUser);
        getIt<NavigatorService>().pushNamedAndRemoveUntil(
          HomeFeatures.routerName,
        );
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
    _inputCompleter = Completer<String>();
  }

  Future<bool> stopWalkieTalkieAndProcessAI() async {
    try {
      developer_log.log(
        "BỘ ĐÀM: Ngắt thu, bắt đầu xử lý AI...",
        name: "UserProfileEngine",
      );

      _voice.stopListening();
      String text = _voice.recognizedText ?? "";

      if (_inputCompleter != null && !_inputCompleter!.isCompleted) {
        _inputCompleter!.complete(text);
      }

      // 2. LẤY DỮ LIỆU TỪ COMPLETER (Của luồng startWalkieTalkie trước đó)
      String userVoice = await _inputCompleter!.future;

      developer_log.log(
        "Đamg đợi input complete",
        name: "UserProfileEngine.getUserProfile",
      );

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
        "BUILD_EXTRACT_BASIC_PROFILE",
        userVoice,
        [],
      );

      StringBuffer cleanContentBuffer = StringBuffer();
      await for (final chunk in aiStream) {
        try {
          // 1. Giải mã từng mảnh JSON nhỏ từ Server (mảnh có chứa trường "text")
          final Map<String, dynamic> chunkMap = jsonDecode(chunk);
          if (chunkMap.containsKey('text')) {
            // 2. Chỉ lấy phần ruột bên trong trường text và ghép lại
            cleanContentBuffer.write(chunkMap['text']);
          }
        } catch (e) {
          // Nếu mảnh đó không phải JSON (ví dụ text thuần), cứ ghi đè vào buffer
          cleanContentBuffer.write(chunk);
        }
      }
      String fullRawResponse = cleanContentBuffer.toString();
      developer_log.log(
        "Tổng nội dung đã ghép: $fullRawResponse",
        name: "UserProfileEngine",
      );
      String cleanJsonString = _extractJsonBlock(fullRawResponse);
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

      _voice.speak("Thiết lập thành công. Xin chào ${userFinal.name}.");

      getIt<NavigatorService>().pushNamedAndRemoveUntil(
        HomeFeatures.routerName,
      );

      return true;
    } catch (e) {
      developer_log.log(
        "Có lỗi xảy ra: $e",
        name: "UserProfileEngine.notifyUserInputreFinished",
      );
      return false;
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
