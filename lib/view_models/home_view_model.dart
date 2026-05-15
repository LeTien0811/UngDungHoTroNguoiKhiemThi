import 'package:build_access/core/VoiceCommand/voice_command_engine.dart';
import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/speech/speech_to_text/speech_to_text_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/hardware/haptic_hardware_service.dart';
import 'package:get/get.dart';

class HomeViewModel extends BaseModel {
  bool isHolding = false;
  bool isAIProcessing = false;
  final VoiceCommandEngine _engine = getIt<VoiceCommandEngine>();

  Future<void> init() async {
    await getIt<VoiceInteractionProvider>().speak('home_welcome_instruction'.tr);
  }

  Future<void> startRecording() async {
    if (isAIProcessing) {
      return;
    }

    isHolding = true;
    notifyListeners();
    await getIt<SpeechToTextEngine>().startWalkieTalkie();
    return;
  }

  Future<void> stopRecording() async {
    if (!isHolding || isAIProcessing) return;
    getIt<HapticHardwareService>().executeSystemVibration();
    isHolding = false;
    isAIProcessing = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    await _engine.stopWalkieTalkieAndProcessAI();
    isAIProcessing = false;
    notifyListeners();
    return;
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }
}
