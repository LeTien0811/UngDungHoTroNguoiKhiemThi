import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/vision_asisstant/factory/vision_action_factory.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/providers/AI/local_ai_provider.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'dart:developer' as developer_log;

class VisionAssistantViewModel extends BaseModel {
  final VoiceInteractionProvider voiceInteractionProvider =
      getIt<VoiceInteractionProvider>();
  final LocalAiProvider localAiProvider = getIt<LocalAiProvider>();

  String rawText = '';
  AIType type = AIType.error;
  String fullResponse = "";

  Future<void> init({
    required String propRawText,
    required AIType propType,
  }) async {
    await runSafe(() async {
      rawText = propRawText;
      type = propType;
      notifyListeners();

      await voiceInteractionProvider.playProcessingSound();
      final strategy = VisionActionFactory.getVisionActionStrategy(type);
      String result = await strategy.execute(rawText);

      if (result.trim().isNotEmpty) {
        rawText = result;
        notifyListeners();
        developer_log.log('kết quả rỗng: $rawText', name: "VisionAssistantViewModel.init");
      } else {
        developer_log.log('kết quả rỗng: $rawText', name: "VisionAssistantViewModel.init");
      }

      await voiceInteractionProvider.playSuccessSound();
      await voiceInteractionProvider.speak(rawText);
    }, 'VisionAssistantViewModel.init');
  }
}
