import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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

  static Future<Uint8List?> drawTextBoundingBoxes(
    Uint8List compressedBytes,
    RecognizedText recognizedText,
  ) async {
    try {
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromList(compressedBytes, (ui.Image img) {
        completer.complete(img);
      });
      final ui.Image image = await completer.future;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      canvas.drawImage(image, Offset.zero, Paint());

      final Paint boxPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final Paint cropPaint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;

      canvas.drawRect(
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        cropPaint,
      );

      for (TextBlock block in recognizedText.blocks) {
        final Rect rect = block.boundingBox;
        canvas.drawRect(rect, boxPaint);
      }

      final ui.Picture picture = recorder.endRecording();
      final ui.Image finalImage = await picture.toImage(
        image.width,
        image.height,
      );

      final ByteData? byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      image.dispose();
      finalImage.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}
