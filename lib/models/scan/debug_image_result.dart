class DebugImageResult {
  final String imageName;
  final String base64Image;

  DebugImageResult({required this.imageName, required this.base64Image});

  DebugImageResult copyWith({String? imageName, String? base64Image}) {
    return DebugImageResult(
      imageName: imageName ?? this.imageName,
      base64Image: base64Image ?? this.base64Image,
    );
  }
}
