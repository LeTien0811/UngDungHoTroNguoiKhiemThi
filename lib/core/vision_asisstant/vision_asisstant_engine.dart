import 'dart:convert';
import 'package:build_access/core/AI/ai_orchestrator.dart';
import 'package:build_access/core/history/history_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/utils/stream_voice_helper.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/models/history/history_model.dart';
import 'package:build_access/models/scan/scan_result.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer_log;

class VisionAsisstantEngine {
  final HistoryEngine _historyEngine = getIt<HistoryEngine>();
  final UserProfileProvider _userProfileProvider = getIt<UserProfileProvider>();
  final AIOrchestrator _aiEngine = getIt<AIOrchestrator>();
  final VoiceInteractionProvider voiceProvider =
      getIt<VoiceInteractionProvider>();

  Future<String> process({
    ScanResult? scanResult,
    String? userChat,
    required AIType propType,
  }) async {
    try {
      String userText = "";
      String textDetection = "";
      String imageBase64 = 'no_image_attached'.tr;
      if (propType == AIType.OCR_SCAN || propType == AIType.DIRECT_VISION) {
        textDetection = scanResult!.textDetect ?? "";
        imageBase64 = scanResult.base64Image ?? "";
      }
      if (propType == AIType.VOICE_ASSISTANT) {
        userText = userChat ?? "";
        final latest = await _historyEngine.getLatestHistory();
        if (latest != null) {
          textDetection = latest.aiSummary;
        }
        developer_log.log(
          "Voice Assistant: $latest",
          name: "VisionAsisstantEngine",
        );
      }
      String userProfile = jsonEncode(
        _userProfileProvider.userProfile!.toMap(),
      );

      final Stream<String> aiStream = _aiEngine.executeAiTask(
        type: propType,
        data: textDetection,
        userProfile: userProfile,
        userText: userText,
        imageBase64: imageBase64,
      );

      String aiRaw = await StreamVoiceHelper.speakStreamBySentence(
        stream: aiStream,
        voiceProvider: voiceProvider,
      );

      if (propType == AIType.OCR_SCAN || propType == AIType.DIRECT_VISION) {
        String displayTitle = aiRaw.trim();
        if (displayTitle.length > 20) {
          displayTitle =
              "${displayTitle.substring(0, 10)}..."; // Lấy 10 ký tự cho rõ nghĩa hơn
        } else if (displayTitle.isEmpty) {
          displayTitle = 'untitled_scan'.tr; // Phòng trường hợp AI không trả về gì
        }
        final HistoryModel historyModel = HistoryModel(
          directoryPath: scanResult!.directoryPath ?? "NONE",
          rawOcrText: scanResult.textDetect ?? "",
          aiSummary: aiRaw,
          createdTime: DateTime.now(),
          title: displayTitle, // Dùng biến đã xử lý an toàn
        );
        bool isSave = await getIt<HistoryEngine>().saveScan(historyModel);
        if (isSave) {
          developer_log.log(
            "lưu dữ liệu quét thành công",
            name: "VisionAsisstantEngine",
          );
        }
      }
      return aiRaw;
    } catch (e) {
      developer_log.log(
        "Lỗi khi xử lý dữ liệu: $e",
        name: "VisionAsisstantEngine",
      );
      return scanResult!.textDetect ?? 'process_failed_retry'.tr;
    }
  }
}
