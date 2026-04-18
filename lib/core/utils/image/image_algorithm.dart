import 'package:build_access/models/scan/process_image_result.dart';
import 'package:build_access/enum/config.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ImageAlgorithm {
  static ProcessImageResult analyzeTextPosition(
    RecognizedText text,
    int imgWidth,
    int imgHeight,
    int rotation,
  ) {
    try {
      if (text.blocks.isEmpty) {
        return ProcessImageResult(ProcessStatus.recapture);
      }

      double minX = double.infinity, minY = double.infinity;
      double maxX = 0, maxY = 0;

      for (var block in text.blocks) {
        final Rect rect = block.boundingBox;
        if (rect.left < minX) minX = rect.left;
        if (rect.top < minY) minY = rect.top;
        if (rect.right > maxX) maxX = rect.right;
        if (rect.bottom > maxY) maxY = rect.bottom;
      }


      final double textCenterX = (minX + maxX) / 2;
      final double textCenterY = (minY + maxY) / 2;

      final double screenCenterX = imgWidth / 2;
      final double screenCenterY = imgHeight / 2;

      final double totalBoundingBoxArea = (maxX - minX) * (maxY - minY);
      final double ratio = totalBoundingBoxArea / (imgWidth * imgHeight).toDouble();

      if (ratio < 0.005) {
        return ProcessImageResult(
          ProcessStatus.recapture,
          command: "Vui lòng đưa máy lại gần văn bản hơn",
        );
      }

      final double deltaX = textCenterX - screenCenterX;
      final double deltaY = textCenterY - screenCenterY;

      final double thresholdX = imgWidth * 0.25;
      final double thresholdY = imgHeight * 0.25;

      bool isHighQuality = text.text.length > 20 && text.blocks.length >= 2;

      if (deltaX.abs() < thresholdX && deltaY.abs() < thresholdY ||
          isHighQuality) {
        List<TextBlock> blocks = List.from(text.blocks);

        blocks.sort((a, b) {
          double heightTolerance = a.boundingBox.height * 0.5;
          if ((a.boundingBox.center.dy - b.boundingBox.center.dy).abs() < heightTolerance) {
            return a.boundingBox.left.compareTo(b.boundingBox.left);
          }
          return a.boundingBox.top.compareTo(b.boundingBox.top);
        });

        StringBuffer finalStructuredText = StringBuffer();

        for (var block in blocks) {
          for (var line in block.lines) {
            finalStructuredText.write('${line.text} ');
          }
          finalStructuredText.write('. \n');
        }

        String cleanText = finalStructuredText.toString().trim();
        return ProcessImageResult(
          ProcessStatus.ok,
          textDetect: cleanText,
        );

      } else {
        String command = "";
        if (deltaX.abs() > deltaY.abs()) {
          if (rotation == 0 || rotation == 180) {
            command = deltaX > 0 ? "Dịch sang phải" : "Dịch sang trái";
          } else {
            command = deltaX > 0 ? "Dịch xuống dưới" : "Dịch lên trên";
          }
        } else {
          if (rotation == 0 || rotation == 180) {
            command = deltaY > 0 ? "Dịch xuống dưới" : "Dịch lên trên";
          } else {
            command = deltaY > 0 ? "Dịch sang phải" : "Dịch sang trái";
          }
        }
        return ProcessImageResult(ProcessStatus.recapture, command: command);
      }
    } catch (e) {
      rethrow;
    }
  }
}
