import 'dart:async';
import 'dart:typed_data';

class OpenCVPayload {
  final Uint8List bytes;
  final int w;
  final int h;
  final int stride;
  final double? cx;
  final double? cy;
  final double? cw;
  final double? ch;

  OpenCVPayload(this.bytes, this.w, this.h, this.stride, {this.cx, this.cy, this.cw, this.ch});
}

class OpenCVResult {
  final Uint8List ocrBytes;
  final Uint8List debugBytes;
  final int outW;
  final int outH;

  OpenCVResult(this.ocrBytes, this.debugBytes, this.outW, this.outH);
}

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
