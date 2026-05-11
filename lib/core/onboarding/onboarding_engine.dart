import 'package:build_access/core/onboarding/onboarding_scripts.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';

class OnboardingEngine {
  final VoiceInteractionProvider _voice = getIt<VoiceInteractionProvider>();

  Future<void> playWelcomeSequence() async {
    await _voice.speak(OnboardingScripts.welcome);
  }

  Future<void> playSecurityInstruction() async {
    await _voice.speak(OnboardingScripts.security);
  }

  Future<void> playProcessingAlert() async {
    await _voice.speak(OnboardingScripts.processing);
  }
}
