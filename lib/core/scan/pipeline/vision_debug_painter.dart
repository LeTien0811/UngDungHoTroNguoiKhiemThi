import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class VisionDebugPainter {
  // AI-added: Lưu riêng ảnh cảnh gốc đã xoay đúng chiều ML Kit, rồi vẽ box vật thể
  // và box crop nhãn chính để phân biệt rõ lỗi object detection với lỗi OCR box.
  static Uint8List? drawSceneBoundingBoxes({
    required Uint8List lumaBytes,
    required int width,
    required int height,
    required int stride,
    required int rotationDegree,
    Rect? objectBox,
    Rect? cropBox,
  }) {
    try {
      img.Image sceneImage = img.Image(width: width, height: height);

      for (int y = 0; y < height; y++) {
        final int rowStart = y * stride;
        for (int x = 0; x < width; x++) {
          final int pixel = lumaBytes[rowStart + x];
          sceneImage.setPixelRgba(x, y, pixel, pixel, pixel, 255);
        }
      }

      if (rotationDegree != 0) {
        sceneImage = img.copyRotate(sceneImage, angle: rotationDegree);
      }

      if (objectBox != null) {
        img.drawRect(
          sceneImage,
          x1: objectBox.left.round(),
          y1: objectBox.top.round(),
          x2: objectBox.right.round(),
          y2: objectBox.bottom.round(),
          color: img.ColorRgb8(0, 255, 0),
          thickness: 4,
        );
      }

      if (cropBox != null) {
        img.drawRect(
          sceneImage,
          x1: cropBox.left.round(),
          y1: cropBox.top.round(),
          x2: cropBox.right.round(),
          y2: cropBox.bottom.round(),
          color: img.ColorRgb8(255, 215, 0),
          thickness: 4,
        );
      }

      return Uint8List.fromList(img.encodeJpg(sceneImage, quality: 95));
    } catch (e) {
      return null;
    }
  }

  // AI-added: `ocrDebugBytes` ở pipeline hiện tại đã là ảnh crop cuối cùng
  // từ object/focus box. Không crop tiếp bằng OCR box nữa để tránh lệch hệ tọa độ.
  static Uint8List buildOcrCropPreview(Uint8List compressedBytes) {
    return compressedBytes;
  }
}
