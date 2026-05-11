import 'dart:convert';
import 'dart:developer' as developer_log;
import 'dart:io';
import 'dart:typed_data';
import 'package:build_access/models/scan/debug_image_result.dart';
import 'package:image/image.dart' as img;

class ImageDebugUtils {
  static Future<DebugImageResult?> saveDebugImage(
    Uint8List bytes, {
    int rotationDegree = 0,
    String filePrefix = 'ocr_check',
  }) async {
    try {
      final String folderPath = '/storage/emulated/0/Pictures/BuildAccessDebug';
      final Directory dir = Directory(folderPath);

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      DateTime now = DateTime.now();
      final String safeTimeName = now.toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-')
          .split('T')
          .join('_');

      final String filePath = '$folderPath/${filePrefix}_$safeTimeName.jpg';
      final File file = File(filePath);



      final img.Image? decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return null;

      img.Image processImage = decodedImage;
      if (rotationDegree != 0) {

        processImage = img.copyRotate(
            decodedImage,
            angle: rotationDegree,
          );
      }

      final Uint8List jpegBytes = Uint8List.fromList(img.encodeJpg(processImage, quality: 85));

      await file.writeAsBytes(jpegBytes, flush: true);

      String base64Image = base64Encode(jpegBytes);
      developer_log.log(
        "📸 Đã lưu thành công vào Bộ sưu tập: $filePath",
        name: "DEBUG_IMAGE",
      );
      DebugImageResult result = DebugImageResult(imageName: safeTimeName, base64Image: base64Image);
      return result;
    } catch (e) {
      developer_log.log(
        "❌ Lỗi không thể lưu ảnh ra ngoài: $e",
        name: "DEBUG_IMAGE",
      );
      return null;
    }
  }
}
