import 'dart:developer' as developer_log;
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageDebugUtils {
  static Future<void> saveDebugImage(
    Uint8List bytes, {
    int rotationDegree = 0,
    String filePrefix = 'ocr_check',
  }) async {
    try {
      // Ép đường dẫn cứng ra thư mục Pictures công khai của Android
      final String folderPath = '/storage/emulated/0/Pictures/BuildAccessDebug';
      final Directory dir = Directory(folderPath);

      // Tạo thư mục nếu chưa có
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      DateTime now = DateTime.now();
      final String safeTimeName = now.toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-')
          .split('T')
          .join('_');

      // Đặt tên file là ocr_check.jpg và ghi đè liên tục
      final String filePath = '$folderPath/${filePrefix}_$safeTimeName.jpg';
      final File file = File(filePath);

      Uint8List outputBytes = bytes;

      // AI-added: Xoay ảnh debug cùng chiều OCR để việc đối chiếu log/ảnh không bị sai do hệ trục cảm biến.
      if (rotationDegree != 0) {
        final img.Image? decodedImage = img.decodeImage(bytes);
        if (decodedImage != null) {
          final img.Image rotatedImage = img.copyRotate(
            decodedImage,
            angle: rotationDegree,
          );
          outputBytes = Uint8List.fromList(img.encodeJpg(rotatedImage));
        }
      }

      await file.writeAsBytes(outputBytes, flush: true);
      developer_log.log(
        "📸 Đã lưu thành công vào Bộ sưu tập: $filePath",
        name: "DEBUG_IMAGE",
      );
    } catch (e) {
      developer_log.log(
        "❌ Lỗi không thể lưu ảnh ra ngoài: $e",
        name: "DEBUG_IMAGE",
      );
    }
  }
}
