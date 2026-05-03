import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class VisionDebugPainter {
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