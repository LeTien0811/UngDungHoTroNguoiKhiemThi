import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/user_profile/user_profile_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';

class OnboardingViewModel extends BaseModel {
  final UserProfileEngine _engine = getIt<UserProfileEngine>();

  Future<void> initializer() async {
    // Không gọi thu âm ngay, chỉ đọc hướng dẫn
    await _engine.speakInstruction();
  }

  void startRecording() {
    _engine.startWalkieTalkie();
  }

  Future<bool> stopRecordingAndProcess() async {
    await Future.delayed(const Duration(seconds: 2));
    return await _engine.stopWalkieTalkieAndProcessAI();
  }
}