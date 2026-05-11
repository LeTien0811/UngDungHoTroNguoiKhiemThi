class AuthApiConfig {
  static const String projectId = "hotronguoikhiemthi-bfa20";
  static const String region = "asia-east1";

  static const String ip = "192.168.1.8:5001";

  static const String baseFunctionUrl = "http://$ip/$projectId/$region";

  static const String passkeyApi = "$baseFunctionUrl/passkeyApi";

  static const String generateChallengeRegEndpoint =
      "$passkeyApi/generate-register-challenge";
  static const String generateChallengeLogEndpoint =
      "$passkeyApi/generate-login-challenge";
  static const String verifyRegResponseEndpoint =
      "$passkeyApi/verify-register-response";
  static const String verifyLogResponseEndpoint =
      "$passkeyApi/verify-login-response";
}
