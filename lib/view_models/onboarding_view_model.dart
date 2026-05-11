import 'package:build_access/core/auth/auth_controller.dart';
import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/onboarding/onboarding_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/services/hardware/haptic_hardware_service.dart';
import 'package:get/get.dart';

class OnboardingViewModel extends BaseModel {
  final OnboardingEngine _onboardingEngine = getIt<OnboardingEngine>();
  // ignore: unused_field
  final AuthController _authController = Get.find<AuthController>();
  final HapticHardwareService _haptic = getIt<HapticHardwareService>();

  bool isHolding = false;
  bool isAiProcessing = false;
  int step = 0;

  Future<void> initializer() async {
    await _onboardingEngine.playWelcomeSequence();
  }

  Future<void> handleAction() async {
    if (isAiProcessing) return;

    _haptic.executeSystemVibration();

    if (step == 0) {
      await _onboardingEngine.playSecurityInstruction();
      step = 1;
      notifyListeners();
    } else {
      isAiProcessing = true;
      notifyListeners();

      await Get.find<AuthController>().handleGoogleAndPasskeyRegistration();

      isAiProcessing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
