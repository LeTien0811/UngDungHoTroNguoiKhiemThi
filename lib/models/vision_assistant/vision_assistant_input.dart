import 'package:build_access/enum/state.dart';

class VisionAssistantInput {
  AIType type;
  String? userRequest;
  String? ocrRaw;
  String? productInfo;
  String? imageBase64;
  String? userProfile;
  String? directoryPathImage;

  VisionAssistantInput({
    required this.type,
    this.userRequest,
    this.ocrRaw,
    this.productInfo,
    this.imageBase64,
    this.userProfile,
    this.directoryPathImage
  });

  VisionAssistantInput copyWith({
    AIType? type,
    String? userRequest,
    String? ocrRaw,
    String? productInfo,
    String? base64Image,
    String? userProfile,
    String? directoryPathImage
  }) {
    return VisionAssistantInput(
      type: type ?? this.type,
      userRequest: userRequest ?? this.userRequest,
      ocrRaw: ocrRaw ?? this.ocrRaw,
      productInfo: productInfo ?? this.productInfo,
      imageBase64: base64Image ?? imageBase64,
      userProfile: userProfile ?? this.userProfile,
      directoryPathImage: directoryPathImage ?? this.directoryPathImage,
    );
  }
}
