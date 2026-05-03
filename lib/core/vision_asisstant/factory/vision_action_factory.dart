import 'package:build_access/core/vision_asisstant/strategy/ocr_correction_strategy.dart';
import 'package:build_access/core/vision_asisstant/strategy/raw_text_strategy.dart';
import 'package:build_access/core/vision_asisstant/strategy/vision_action_strategy.dart';
import 'package:build_access/enum/state.dart';

class VisionActionFactory {
  static VisionActionStrategy getVisionActionStrategy(AIType type) {
    switch (type) {
      case AIType.ocrCorrection:
        return OcrCorrectionStrategy();
      case AIType.voiceAssistantQA:
        return RawTextStrategy();
      default:
        throw Exception('Invalid AI type');
    }
  }
}
