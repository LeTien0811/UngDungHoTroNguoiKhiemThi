import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/enum/state.dart';

class OnboardingProvider extends BaseModel{
  UserProfileState userState = UserProfileState.uninitialized;

  void setChecking() {
    userState = UserProfileState.checking;
    notifyListeners();
  }

  void setUninitialized() {
    userState = UserProfileState.uninitialized;
    notifyListeners();
  }

  void setError() {
    userState = UserProfileState.error;
    notifyListeners();
  }
}