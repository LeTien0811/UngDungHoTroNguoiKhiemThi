import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/models/user/user_model.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:build_access/services/storage/secure_storage_service.dart';
import 'dart:developer' as developer_log;

class AuthStorageEngine {
  final SecureStorageService _storage = getIt<SecureStorageService>();
  final UserProfileProvider _provider = getIt<UserProfileProvider>();

  final String _key = "user_profile_key";

  Future<void> initializer() async {
    try {
      String storage = await _storage.readData(_key) ?? "";
      if (storage.trim().isEmpty) {
        _provider.setUninitialized();
        return;
      }

      UserModel newUser = UserModel.fromJson(storage);
      if (newUser.toString().trim().isNotEmpty) {
        _provider.setUserProfile(newUser);
        return;
      }
    } catch (e) {
      _provider.setError();
      developer_log.log("Lỗi khởi tạo user: $e", name: "UserProfileEngine");
    }
  }


  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if(_provider.userProfile != null) {
      _provider.userProfile = _provider.userProfile!.copyWith(
        secureAccessToken: accessToken,
        secureRefreshToken: refreshToken,
      );
    }
  }

  String? getAccessToken()  {
    if(_provider.userProfile != null) {
      return _provider.userProfile!.secureAccessToken;
    }
    return "";
  }

  String? getRefreshToken() {
    if(_provider.userProfile != null) {
      return _provider.userProfile!.secureRefreshToken;
    }
    return "";
  }

  Future<void> clearTokens() async {
    await _storage.deleteData(_key);
    _provider.userProfile = null;
  }
}
