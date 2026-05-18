import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/onboarding/user_profile_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';

class SetupProfileViewModel extends BaseModel {
  final UserProfileEngine _engine = getIt<UserProfileEngine>();
  bool isHolding = false;
  bool isAiProcessing = false;

  Future<void> initializer() async {
    // Không gọi thu âm ngay, chỉ đọc hướng dẫn
    await _engine.speakInstruction();
  }

  Future<void> startRecording() async{
    _engine.startWalkieTalkie();
  }

}
