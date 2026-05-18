import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/speech/speech_to_text/speech_to_text_engine.dart';
import 'package:build_access/core/vision_asisstant/vision_assistant_engine.dart';
import 'package:build_access/core/widgets/voice_confirm_widget.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/models/scan/scan_result.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/models/vision_assistant/vision_assistant_input.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'dart:developer' as developer_log;

import 'package:get/get.dart';

class VisionAssistantViewModel extends BaseModel {
  final VoiceInteractionProvider voiceInteractionProvider =
      getIt<VoiceInteractionProvider>();
  final VisionAssistantEngine _visionAssistantEngine =
      getIt<VisionAssistantEngine>();
  String result = "";
  Future<void> init({
    required ScanResult scanResult,
    required AIType propType,
  }) async {
    await runSafe(() async {
      VisionAssistantInput  visionAssistantInput = VisionAssistantInput(
        type: propType,
        ocrRaw: scanResult.textDetect,
        imageBase64: scanResult.base64Image,
        directoryPathImage: scanResult.directoryPath,
      );
      notifyListeners();
      setState(ViewState.idle);
      await process(visionAssistantInput: visionAssistantInput);
      await voiceInteractionProvider.speak(
        'vision_asisstant_touch_to_speak_scan'.tr,
      );
    }, 'VisionAssistantViewModel.init');
  }

  Future<void> stopUserAsking() async {
    String userText = await getIt<SpeechToTextEngine>().stopWalkieTalkie();
    String commandVoice =
        'confirm_general_request'.tr + userText + 'confirm_instruction'.tr;
    bool isConfirm =
        await VoiceConfirmWidget.show(message: commandVoice) ?? false;
    if (!isConfirm) {
      return;
    }
    VisionAssistantInput visionAssistantInput = VisionAssistantInput(type: AIType.VOICE_ASSISTANT, userRequest: userText);
    await process(visionAssistantInput: visionAssistantInput);
    return;
  }

  Future<void> process({required VisionAssistantInput visionAssistantInput}) async {
    await voiceInteractionProvider.playProcessingSound();
    result = await _visionAssistantEngine.process(visionAssistantInput);
    if (result.trim().isNotEmpty) {
      visionAssistantInput = visionAssistantInput.copyWith(
        productInfo: result,
      );
      notifyListeners();
      developer_log.log(
        'kết quả: ${visionAssistantInput.productInfo}',
        name: "VisionAssistantViewModel",
      );
    } else {
      developer_log.log('kết quả rỗng', name: "VisionAssistantViewModel");
    }

    await voiceInteractionProvider.playSuccessSound();
  }
}
