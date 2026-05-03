import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/user_profile/user_profile_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';

class OnboardingViewModel extends BaseModel{
  final UserProfileEngine _engine = getIt<UserProfileEngine>();

  Future<void> initializer() async{
    await _engine.initializer();
  }

  Future<void> startVoiceOnboarding() async {
    await _engine.getUserProfile();
  }

  void onUserFinishedSpeaking() {
    _engine.notifyUserInputFinished();
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }
}