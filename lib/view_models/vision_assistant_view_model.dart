import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/speech/speech_to_text/speech_to_text_engine.dart';
import 'package:build_access/core/vision_asisstant/vision_asisstant_engine.dart';
import 'package:build_access/core/widgets/voice_confirm_widget.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/models/scan/scan_result.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'dart:developer' as developer_log;

import 'package:get/get.dart';

class VisionAssistantViewModel extends BaseModel {
  final VoiceInteractionProvider voiceInteractionProvider =
      getIt<VoiceInteractionProvider>();
  final VisionAsisstantEngine _visionAsisstantEngine =
      getIt<VisionAsisstantEngine>();

  String rawText = '';
  String fullResponse = "";

  Future<void> init({
    required ScanResult scanResult,
    required AIType propType,
  }) async {
    await runSafe(() async {
      rawText = scanResult.textDetect.toString();
      notifyListeners();
      setState(ViewState.idle);
      await process(scanResult: scanResult, propType: propType);
      await voiceInteractionProvider.speak(
        'vision_asisstant_touch_to_speak_scan'.tr,
      );
    }, 'VisionAssistantViewModel.init');
  }

  Future<void> processAskAI() async {
    String userText = await getIt<SpeechToTextEngine>().stopWalkieTalkie();
    String commnandVoice =
        'confirm_general_request'.tr + userText + 'confirm_instruction'.tr;
    bool isConfirm =
        await VoiceConfirmWidget.show(message: commnandVoice) ?? false;
    if (!isConfirm) {
      return;
    }

    String result = await _visionAsisstantEngine.process(
      propType: AIType.VOICE_ASSISTANT,
      userChat: userText,
    );

    if (result.trim().isNotEmpty) {
      rawText = result;
      notifyListeners();
      developer_log.log('kết quả: $rawText', name: "VisionAssistantViewModel");
    }
    await voiceInteractionProvider.playSuccessSound();
    return;
  }

  Future<void> process({
    ScanResult? scanResult,
    String? userChat,
    required AIType propType,
  }) async {
    await voiceInteractionProvider.playProcessingSound();
    String result = await _visionAsisstantEngine.process(
      propType: propType,
      scanResult: scanResult,
    );
    if (result.trim().isNotEmpty) {
      rawText = result;
      notifyListeners();
      developer_log.log('kết quả: $rawText', name: "VisionAssistantViewModel");
    } else {
      developer_log.log(
        'kết quả rỗng: $rawText',
        name: "VisionAssistantViewModel",
      );
    }

    await voiceInteractionProvider.playSuccessSound();
  }
}
