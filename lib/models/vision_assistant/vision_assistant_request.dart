import 'package:build_access/enum/state.dart';

class VisionAssistantRequest {
  AIType type;
  String language;
  String? productInfo;
  String? userRequest;
  String? userProfile;
  String? imageBase64;
  String? history;

  VisionAssistantRequest({
    required this.type,
    required this.language,
    this.productInfo,
    this.userRequest,
    this.userProfile,
    this.imageBase64,
    this.history,
  });

  VisionAssistantRequest copyWith({
    AIType? type,
    String? language,
    String? productInfo,
    String? userRequest,
    String? userProfile,
    String? imageBase64,
  }) {
    return VisionAssistantRequest(
      type: type ?? this.type,
      language: language ?? this.language,
      productInfo: productInfo ?? this.productInfo,
      userRequest: userRequest ?? this.userRequest,
      userProfile: userProfile ?? this.userProfile,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }
}
