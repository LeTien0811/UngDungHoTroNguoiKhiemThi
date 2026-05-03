import 'package:build_access/models/scan/scan_result.dart';
import 'package:build_access/enum/state.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class SpatialTextAnalyzer {
  ScanResult process(
    RecognizedText text,
    int imgWidth,
    int imgHeight,
    int rotation,
  ) {
    try {
      if (text.blocks.isEmpty) {
        return ScanResult(ScanStatus.notFoundText);
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
      final double ratio =
          totalBoundingBoxArea / (imgWidth * imgHeight).toDouble();

      if (ratio < 0.005) {
        return ScanResult(
          ScanStatus.notFoundText,
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
        return ScanResult(
          ScanStatus.ok,
          textDetect: text.text,
          rawRecognizedText: text,
        );
      } else {
        String command = _generateDirectionalCommand(deltaX, deltaY, rotation);
        return ScanResult(ScanStatus.notFoundText, command: command);
      }
    } catch (e) {
      rethrow;
    }
  }

  String _generateDirectionalCommand(
    double deltaX,
    double deltaY,
    int rotation,
  ) {
    if (deltaX.abs() > deltaY.abs()) {
      if (rotation == 0 || rotation == 180) {
        return deltaX > 0 ? "Dịch sang phải" : "Dịch sang trái";
      } else {
        return deltaX > 0 ? "Dịch xuống dưới" : "Dịch lên trên";
      }
    } else {
      if (rotation == 0 || rotation == 180) {
        return deltaY > 0 ? "Dịch xuống dưới" : "Dịch lên trên";
      } else {
        return deltaY > 0 ? "Dịch sang phải" : "Dịch sang trái";
      }
    }
  }
}
