import 'dart:io';

import 'package:build_access/core/auth/auth_storage_engine.dart';
import 'package:build_access/core/navigator/app_navigator.dart';
import 'package:build_access/features/home_feature/home_features.dart';
import 'package:build_access/features/onboarding_features/onboarding_feature.dart';
import 'package:build_access/features/splash_feature/splash_feature.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:build_access/services/auth/passkey_auth_service.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'dart:developer' as developer_log;

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final PasskeyAuthService _passkeyService = getIt<PasskeyAuthService>();
  final VoiceInteractionProvider _voice = getIt<VoiceInteractionProvider>();
  final UserProfileProvider _provider = getIt<UserProfileProvider>();
  final AuthStorageEngine _storage = getIt<AuthStorageEngine>();

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _googleSignIn.initialize();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  Future<void> checkInitialAuth() async {
    developer_log.log("Check Auth");
    await _storage.initializer();

    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _storage.saveUser(currentUser);
      getIt<AppNavigator>().pushNamedAndRemoveUntil(HomeFeatures.routerName);
      return;
    }

    String? savedEmail = _provider.userProfile?.email;
    if (savedEmail != null && savedEmail != "Không rõ") {
      await autoLoginWithPasskey(savedEmail);
    } else {
      getIt<AppNavigator>().pushNamedAndRemoveUntil(
        OnboardingFeature.routerName,
      );
    }
  }

  Future<void> autoLoginWithPasskey(String email, {bool isGo = true}) async {
    try {
      isLoading.value = true;
      await _passkeyService.loginWithPasskey(email);
      if (isGo) {
        getIt<AppNavigator>().pushNamedAndRemoveUntil(HomeFeatures.routerName);
      }
      return;
    } catch (e) {
      await _storage.deleteUser();
      await _voice.speak('auth_auto_login_failed'.tr);
      isLoading.value = false;
      rethrow;
    }
  }

  Future<void> handleGoogleAndPasskeyRegistration() async {
    try {
      isLoading.value = true;
      await _voice.speak('auth_opening_google'.tr);

      final GoogleSignInAccount? googleAccount = await _googleSignIn
          .authenticate();

      if (googleAccount == null) {
        await _voice.speak('auth_login_cancelled'.tr);
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      final GoogleSignInClientAuthorization clientAuth = await googleAccount
          .authorizationClient
          .authorizeScopes(['email', 'profile']);
      bool checkStatus = await _passkeyService.checkStatusAccount(
        googleAccount.email,
      );
      if (checkStatus) {
        developer_log.log(
          "đã tồn tại đăng nhập",
          name: "handleGoogleAndPasskeyRegistration",
        );
        await autoLoginWithPasskey(googleAccount.email);
        return;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: clientAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null && user.email != null) {
        String deviceName = "UngDungHoTroNguoiKhiemThi_Device";
        try {
          if (Platform.isAndroid) {
            AndroidDeviceInfo androidInfo =
                await DeviceInfoPlugin().androidInfo;
            developer_log.log('Tên thiết bị (Model): ${androidInfo.model}');
            developer_log.log('ID thiết bị (Android ID): ${androidInfo.id}');
            deviceName = androidInfo.id;
          } else if (Platform.isIOS) {
            IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
            developer_log.log('Tên thiết bị (Name): ${iosInfo.name}');
            developer_log.log(
              'ID thiết bị (UUID): ${iosInfo.identifierForVendor}',
            );
            deviceName = iosInfo.identifierForVendor ?? iosInfo.name;
          }
        } catch (e) {
          deviceName = "Mobile_Device_${user.uid.substring(0, 5)}";
          if (e.toString().contains('excludeCredentials') ||
              e.toString().contains("Null")) {
            developer_log.log(
              "thiết bị có thể đã có khóa",
              name: "handleGoogleAndPasskeyRegistration",
            );

            await autoLoginWithPasskey(user.email!);
          } else {
            rethrow;
          }
        }

        await _passkeyService.registerNewDeviceWithPasskey(user, deviceName);
        await _voice.speak(
          'auth_welcome_user'.trParams({'name': _provider.userProfile!.name}),
        );
        getIt<AppNavigator>().pushNamedAndRemoveUntil(HomeFeatures.routerName);
      }
    } catch (e) {
      developer_log.log(
        "lỗi liên kết google: $e",
        name: "handleGoogleAndPasskeyRegistration",
      );

      await _storage.deleteUser();
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _voice.speak('auth_link_error'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _voice.speak('auth_logging_out'.tr);
    await _storage.deleteUser();
    await _auth.signOut();
    await _googleSignIn.signOut();

    getIt<AppNavigator>().pushNamedAndRemoveUntil(SplashFeature.routerName);
    await Future.delayed(const Duration(milliseconds: 500));
    await _voice.speak('auth_logout_success'.tr);
  }
}
