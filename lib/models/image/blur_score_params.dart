import 'package:flutter/foundation.dart';

class BlurScoreParams {
  final Uint8List bytes;
  final int width;
  final int height;
  final int stride;

  BlurScoreParams({
    required this.bytes,
    required this.width,
    required this.height,
    required this.stride,
  });
}