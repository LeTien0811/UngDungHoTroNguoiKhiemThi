import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class AlgorithmImage {

  static void analyzeTextPosition(RecognizedText text, int imgWidth, int imgHeight, Function(String message, {bool priority}) onGuidance, Function() triggerAutoCapture) {
    TextBlock? mainBlock;
    double maxArea = 0;

    for (var block in text.blocks) {
      double area = block.boundingBox.width * block.boundingBox.height;
      if (area > maxArea) {
        maxArea = area;
        mainBlock = block;
      }
    }

    if (mainBlock == null) return;

    // Tính tâm của khối chữ
    final Rect box = mainBlock.boundingBox;
    final double textCenterX = box.center.dx;
    // ignore: unused_local_variable
    final double textCenterY = box.center.dy;

    final double screenCenterX = imgWidth / 2;
    // ignore: unused_local_variable
    final double screenCenterY = imgHeight / 2;

    // Tính độ lệch (Delta)
    // Đây là ví dụ logic đơn giản, thực tế cần xử lý rotation thiết bị
    // Giả sử ảnh đã xoay đúng:
    double deltaX = textCenterX - screenCenterX;

    double threshold = imgWidth * 0.15; // 15% chiều rộng

    if (deltaX.abs() < threshold) {
      triggerAutoCapture();
    } else if (deltaX > 0) {
      onGuidance("Dịch sang phải một chút", priority: false);
    } else {
      onGuidance("Dịch sang trái một chút", priority: false);
    }
  }

  static double calculateBlurScore(CameraImage image) {
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
        int left   = bytes[index - 1];
        int right  = bytes[index + 1];
        int up     = bytes[index - bytesPerRow];
        int down   = bytes[index + bytesPerRow];

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
  }
}