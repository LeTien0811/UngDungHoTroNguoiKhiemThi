import 'dart:convert';
import 'package:build_access/core/auth/auth_storage_engine.dart';
import 'package:build_access/enum/auth_api_config.dart';
import 'package:build_access/services/API_service/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'dart:developer' as developer_log;

class PasskeyAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final VoiceInteractionProvider _voice = getIt<VoiceInteractionProvider>();
  final APIService _apiService = getIt<APIService>();

  Future<void> registerNewDeviceWithPasskey(
    User googleUser,
    String deviceName,
  ) async {
    try {
      await _voice.speak(
        "Đang chuẩn bị tạo khóa bảo mật. Vui lòng giữ mạng ổn định.",
      );
      final challengeResponse = await _apiService.postConfig(
        AuthApiConfig.generateChallengeRegEndpoint,
        data: jsonEncode({'uid': googleUser.uid, 'email': googleUser.email}),
      );

      developer_log.log("dữ liệu challenge ${jsonEncode(challengeResponse.data)}");

      if (challengeResponse.statusCode != 200) {
        throw Exception("Lỗi nhận đề thi");
      }

      final optionsJson = challengeResponse.data;

      await _voice.speak(
        "Hãy đặt vân tay hoặc khuôn mặt vào cảm biến để tạo khóa.",
      );

      final authenticator = PasskeyAuthenticator();
      final registerRequest = RegisterRequestType.fromJson(optionsJson as Map<String, dynamic>);
      final registrationResponse = await authenticator.register(registerRequest);

      await _voice.speak("Đang lưu khóa vào máy chủ...");

      final verifyResponse = await _apiService.postConfig(
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
        await _voice.speak(
          "Thiết lập thành công. Bạn đã có thể sử dụng ứng dụng an toàn.",
        );
      } else {
        throw Exception("Server từ chối khóa bảo mật.");
      }
    } catch (e) {
      await _voice.speak("Lỗi thiết lập khóa. Vui lòng thử lại sau.");
      rethrow;
    }
  }

  Future<void> loginWithPasskey(String email) async {
    try {
      await _voice.speak("Đang kiểm tra thông tin. Vui lòng giữ máy.");

      // 1. Xin đề thi Đăng nhập
      final challengeResponse = await _apiService.postConfig(
        AuthApiConfig.generateChallengeLogEndpoint,
        data: {'email': email},
      );
      final optionsJson = challengeResponse.data;

      await _voice.speak("Hãy quét vân tay hoặc khuôn mặt để mở khóa.");

      // 2. Gọi Chip bảo mật để Ký (Assertion)
      final authenticator = PasskeyAuthenticator();
      final authRequest = AuthenticateRequestType.fromJson(optionsJson as Map<String, dynamic>);
      final authenticationResponse = await authenticator.authenticate(
        authRequest,
      );

      await _voice.speak("Đang xác minh chữ ký an toàn...");

      // 3. Nộp bài lên Backend chấm
      final verifyResponse = await _apiService.postConfig(
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

      await _voice.speak("Đăng nhập thành công. Chào mừng bạn trở lại.");
    } catch (e) {
      await _voice.speak(
        "Không thể đăng nhập. Có thể khóa của bạn đã bị xóa hoặc sai thiết bị.",
      );
      rethrow;
    }
  }
}
