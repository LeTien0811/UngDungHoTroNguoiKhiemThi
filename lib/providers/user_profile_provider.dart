import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/models/user/user_model.dart';

class UserProfileProvider extends BaseModel{
  UserProfileState userState = UserProfileState.uninitialized;
  UserModel? userProfile;

  void deleteUserProfile() {
    userProfile = null;
    notifyListeners();
    setUninitialized();
    return;
  }

  void setUserProfile(UserModel propsUserProfile) {
    userProfile = propsUserProfile;
    userState = UserProfileState.idle;
    notifyListeners();
  }

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