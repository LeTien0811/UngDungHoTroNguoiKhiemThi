import 'dart:convert';
import 'package:build_access/core/AI/ai_orchestrator.dart';
import 'package:build_access/core/history/history_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/utils/stream_voice_helper.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/models/history/history_model.dart';
import 'package:build_access/models/vision_assistant/vision_assistant_input.dart';
import 'package:build_access/models/vision_assistant/vision_assistant_request.dart';
import 'package:build_access/providers/app_setting_provider.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer_log;

class VisionAssistantEngine {
  final HistoryEngine _historyEngine = getIt<HistoryEngine>();
  final AppSettingProvider _appSettingProvider = getIt<AppSettingProvider>();
  final UserProfileProvider _userProfileProvider = getIt<UserProfileProvider>();
  final AIOrchestrator _aiEngine = getIt<AIOrchestrator>();
  final VoiceInteractionProvider voiceProvider =
      getIt<VoiceInteractionProvider>();

  Future<String> process(VisionAssistantInput visionAssistantInput) async {
    try {
      AIType propType = visionAssistantInput.type;
      String userRequest = visionAssistantInput.userRequest ?? "";
      String productInfo = visionAssistantInput.productInfo ?? "";
      String imageBase64 =
          visionAssistantInput.imageBase64 ?? "no_image_attached".tr;
      String language = _appSettingProvider.appSetting.ttsLanguage;

      if (propType == AIType.VOICE_ASSISTANT) {
        final latest = await _historyEngine.getLatestHistory();
        if (latest != null) {
          productInfo = latest.aiSummary;
        }
        developer_log.log(
          "Voice Assistant: $latest",
          name: "VisionAsisstantEngine",
        );
      }

      String userProfile = '';
      if (visionAssistantInput.type != AIType.DIRECT_VISION) {
        userProfile =
            visionAssistantInput.userProfile ??
            jsonEncode(_userProfileProvider.userProfile!.toMap());
      }
      String history = "";

      final VisionAssistantRequest visionAssistantRequest =
          VisionAssistantRequest(
            type: propType,
            language: language,
            userRequest: userRequest,
            userProfile: userProfile,
            productInfo: productInfo,
            imageBase64: imageBase64,
            history: history,
          );

      final Stream<String> aiStream = _aiEngine.executeAiTask(
        visionAssistantRequest: visionAssistantRequest,
      );

      String aiRaw = await StreamVoiceHelper.speakStreamBySentence(
        stream: aiStream,
        voiceProvider: voiceProvider,
      );

      if (propType == AIType.OCR_SCAN || propType == AIType.DIRECT_VISION) {
        String displayTitle = aiRaw.trim();
        if (displayTitle.length > 20) {
          displayTitle = "${displayTitle.substring(0, 20)}...";
        } else if (displayTitle.isEmpty) {
          displayTitle = 'untitled_scan'.tr;
        }
        developer_log.log(aiRaw, name: 'VisionAsisstantEngine');
        final HistoryModel historyModel = HistoryModel(
          directoryPath: visionAssistantInput.directoryPathImage ?? "NONE",
          rawOcrText: visionAssistantInput.ocrRaw ?? "",
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
      return visionAssistantInput.ocrRaw ?? 'process_failed_retry'.tr;
    }
  }
}
