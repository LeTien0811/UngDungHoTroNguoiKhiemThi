import 'dart:async';
import 'dart:typed_data';

class ImageWorkerRequest {
  final Uint8List bytes;
  final int width;
  final int height;
  final int stride;
  final int? cropX;
  final int? cropY;
  final int? cropW;
  final int? cropH;
  final Completer<dynamic> completer;

  ImageWorkerRequest({
    required this.bytes,
    required this.width,
    required this.height,
    required this.stride,
    this.cropX,
    this.cropY,
    this.cropW,
    this.cropH,
    required this.completer,
  });
}