import 'package:build_access/providers/locator.dart';
import 'package:build_access/providers/service_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ImageAlgorithm {
  final ProviderSevice providerService = getIt<ProviderSevice>();
  String analyzeTextPosition(
    RecognizedText text,
    int imgWidth,
    int imgHeight,
    int rotation,
  ) {
    try {
      if (text.blocks.isEmpty) throw ("RECAPTURE");

      TextBlock mainBlock = text.blocks.first;
      double maxArea = 0;

      for (var block in text.blocks) {
        double area = block.boundingBox.width * block.boundingBox.height;
        if (area > maxArea) {
          maxArea = area;
          mainBlock = block;
        }
      }

      final Rect box = mainBlock.boundingBox;

      final double textCenterX = box.center.dx;
      final double textCenterY = box.center.dy;

      final double screenCenterX = imgWidth / 2;
      final double screenCenterY = imgHeight / 2;

      final double area = box.width * box.height;
      final double ratio = area / (imgWidth * imgHeight).toDouble();

      if (ratio < 0.01) {
        providerService.speakQueue('Vui lòng đưa máy lại gần văn bản hơn');
        throw ("RECAPTURE");
      }

      final double deltaX = textCenterX - screenCenterX;
      final double deltaY = textCenterY - screenCenterY;

      final double thresholdX = imgWidth * 0.25;
      final double thresholdY = imgHeight * 0.25;

      if (deltaX.abs() < thresholdX && deltaY.abs() < thresholdY) {
        List<TextBlock> blocks = List.from(text.blocks);

        blocks.sort((a, b) {
          if ((a.boundingBox.center.dy - b.boundingBox.center.dy).abs() < 30) {
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
        return cleanText;
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


        providerService.speakQueue(command);
        throw ("RECAPTURE");
      }
    } catch (e) {
      rethrow;
    }
  }

  static double calculateBlurScore(CameraImage image) {
    try {
      final Plane plane = image.planes[0];
      final Uint8List bytes = plane.bytes;
      final int width = image.width;
      final int height = image.height;
      final int bytesPerRow = plane.bytesPerRow;

      double sum = 0;
      double sumSq = 0;
      int count = 0;

      for (int y = 1; y < height - 1; y += 4) {
        for (int x = 1; x < width - 1; x += 4) {
          int index = y * bytesPerRow + x;

          int center = bytes[index];
          int left = bytes[index - 1];
          int right = bytes[index + 1];
          int up = bytes[index - bytesPerRow];
          int down = bytes[index + bytesPerRow];

          // Áp dụng công thức Laplacian
          int laplacian = up + down + left + right - (4 * center);

          sum += laplacian;
          sumSq += laplacian * laplacian;
          count++;
        }
      }

      if (count == 0) return 0;

      // Tính phương sai (Variance)
      double mean = sum / count;
      double variance = (sumSq / count) - (mean * mean);

      return variance; // Giá trị càng cao -> Ảnh càng nét
    } catch (e) {
      rethrow;
    }
  }
}
