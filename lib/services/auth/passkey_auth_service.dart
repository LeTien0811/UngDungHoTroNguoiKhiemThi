import 'dart:convert';
import 'package:build_access/core/auth/auth_storage_engine.dart';
import 'package:build_access/enum/auth_api_config.dart';
import 'package:build_access/services/API_service/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer_log;

class PasskeyAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final VoiceInteractionProvider _voice = getIt<VoiceInteractionProvider>();
  final APIService _apiService = getIt<APIService>();

  Future<bool> checkStatusAccount(String email) async{
    try {
      final response = await _apiService.post(
        AuthApiConfig.checkStatusAccountEndpoint,
        data: {
          'email': email,
        },
      );
      if(response.statusCode == 200) {
        return response.data['isRegistered'];
      } else {
        developer_log.log("lỗi ${response.statusCode}, ${response.statusMessage}");
        return false;

      }
    } catch(e) {
      developer_log.log("lỗi $e");
      return false;
    }
  }

  Future<void> registerNewDeviceWithPasskey(
    User googleUser,
    String deviceName,
  ) async {
    try {
      await _voice.speak('auth_passkey_prep_create'.tr);
      final challengeResponse = await _apiService.post(
        AuthApiConfig.generateChallengeRegEndpoint,
        data: jsonEncode({'uid': googleUser.uid, 'email': googleUser.email}),
      );

      developer_log.log("dữ liệu challenge ${jsonEncode(challengeResponse.data)}");

      if (challengeResponse.statusCode != 200) {
        throw Exception('auth_passkey_error_challenge'.tr);
      }

      final optionsJson = challengeResponse.data;

      await _voice.speak('auth_passkey_prompt_fingerprint'.tr);

      final authenticator = PasskeyAuthenticator();
      final registerRequest = RegisterRequestType.fromJson(optionsJson as Map<String, dynamic>);
      final registrationResponse = await authenticator.register(registerRequest);

      await _voice.speak('auth_passkey_saving'.tr);

      final verifyResponse = await _apiService.post(
        Uri.parse(AuthApiConfig.verifyRegResponseEndpoint).toString(),
        data: {
          'uid': googleUser.uid,
          'email': googleUser.email,
          'registrationResponse': registrationResponse.toJson(),
          'deviceName': deviceName,
        },
      );

      if (verifyResponse.statusCode == 200) {
        final customToken = verifyResponse.data['customToken'];

        final String? accessToken = verifyResponse.data['access_token'];
        final String? refreshToken = verifyResponse.data['refresh_token'];

        // 5. Đăng nhập vào Firebase
        final UserCredential userCredential = await _auth.signInWithCustomToken(
          customToken,
        );
        final User? user = userCredential.user;
        if (user != null) {
          final authStorage = getIt<AuthStorageEngine>();

          if (accessToken != null && refreshToken != null) {
            await authStorage.saveTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
            );
          }

          await authStorage.saveUser(user);
        }
        await _voice.speak('auth_passkey_setup_success'.tr);
      } else {
        throw Exception('auth_passkey_server_rejected'.tr);
      }
    } catch (e) {
      await _voice.speak('auth_passkey_setup_error'.tr);
      rethrow;
    }
  }

  Future<void> loginWithPasskey(String email) async {
    try {
      await _voice.speak('auth_passkey_checking_info'.tr);

      // 1. Xin đề thi Đăng nhập
      final challengeResponse = await _apiService.post(
        AuthApiConfig.generateChallengeLogEndpoint,
        data: {'email': email},
      );
      final optionsJson = challengeResponse.data;

      await _voice.speak('auth_passkey_prompt_unlock'.tr);

      // 2. Gọi Chip bảo mật để Ký (Assertion)
      final authenticator = PasskeyAuthenticator();
      final authRequest = AuthenticateRequestType.fromJson(optionsJson as Map<String, dynamic>);
      final authenticationResponse = await authenticator.authenticate(
        authRequest,
      );

      await _voice.speak('auth_passkey_verifying'.tr);

      // 3. Nộp bài lên Backend chấm
      final verifyResponse = await _apiService.post(
        AuthApiConfig.verifyLogResponseEndpoint,
        data: {
          'email': email,
          'authenticationResponse': authenticationResponse.toJson(),
        },
      );

      // 4. Nhận Custom Token và vào Firebase
      final customToken = verifyResponse.data['customToken'];
      final String? accessToken = verifyResponse.data['access_token'];
      final String? refreshToken = verifyResponse.data['refresh_token'];

      // 5. Đăng nhập vào Firebase
      final UserCredential userCredential = await _auth.signInWithCustomToken(
        customToken,
      );
      final User? user = userCredential.user;
      if (user != null) {
        final authStorage = getIt<AuthStorageEngine>();

        if (accessToken != null && refreshToken != null) {
          await authStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }

        await authStorage.saveUser(user);
      }

      await _voice.speak('auth_login_success'.tr);
    } catch (e) {
      await _voice.speak('auth_login_failed'.tr);
      rethrow;
    }
  }
}
