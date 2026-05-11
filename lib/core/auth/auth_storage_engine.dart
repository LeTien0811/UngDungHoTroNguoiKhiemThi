import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/models/user/user_model.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:build_access/services/storage/secure_storage_service.dart';
import 'dart:developer' as developer_log;

import 'package:firebase_auth/firebase_auth.dart';

class AuthStorageEngine {
  final SecureStorageService _storage = getIt<SecureStorageService>();
  final UserProfileProvider _provider = getIt<UserProfileProvider>();

  final String _key = "user_profile_key";

  Future<void> initializer() async {
    try {
      String storage = await _storage.readData(_key) ?? "";
      if (storage == "" || storage.trim().isEmpty) {
        _provider.setUninitialized();
        return;
      }

      UserModel newUser = UserModel.fromJson(storage);
      if (newUser.email != "Không rõ") {
        _provider.setUserProfile(newUser);
        return;
      } else {
        _provider.setUninitialized();
      }
    } catch (e) {
      _provider.setError();
      developer_log.log("Lỗi khởi tạo user: $e", name: "UserProfileEngine");
    }
  }

  Future<void> saveUser(User user) async {
    if (_provider.userProfile != null) {
      _provider.userProfile = _provider.userProfile!.copyWith(
        name: user.displayName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        imageUrl: user.photoURL,
      );
    } else {
      UserModel newUser = UserModel(
        name: user.displayName ?? "Không rõ",
        email: user.email ?? "Không rõ",
        phoneNumber: user.phoneNumber ?? "Không rõ",
        imageUrl: user.photoURL ?? "Không rõ",
      );
      _provider.setUserProfile(newUser);
    }

    await _storage.saveData(_key, _provider.userProfile!.toJson());
    return;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (_provider.userProfile != null) {
      _provider.setUserProfile(
        _provider.userProfile!.copyWith(
          secureAccessToken: accessToken,
          secureRefreshToken: refreshToken,
        ),
      );
    }

    await _storage.saveData(_key, _provider.userProfile!.toJson());
  }

  String? getAccessToken() => _provider.userProfile?.secureAccessToken;

  String? getRefreshToken() => _provider.userProfile?.secureRefreshToken;

  Future<void> deleteUser() async {
    await _storage.deleteData(_key);
    _provider.deleteUserProfile();
  }
}
