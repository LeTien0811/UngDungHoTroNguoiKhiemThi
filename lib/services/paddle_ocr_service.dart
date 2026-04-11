import 'package:paddle_ocr/bean/ocr_results.dart';
import 'package:paddle_ocr/paddle_ocr.dart';
import 'package:paddle_ocr/bean/ocr_result.dart';
import 'dart:math';

class PaddleOcrService {
  static final PaddleOcrService _instance = PaddleOcrService._internal();
  factory PaddleOcrService() => _instance;
  PaddleOcrService._internal();

  Future<String> scanImage(String imagePath) async {
    try {
      final dynamic response = await PaddleOcr.ocrFromImage(imagePath);

      if (response is Map && response['success'] == true) {
        // response['ocrResult'] lúc này là đối tượng OcrResultInfo
        final dynamic info = response['ocrResult'];

        if (info is OcrResultInfo && info.ocrResults != null) {
          // Gửi danh sách OcrResult đi sắp xếp
          return _extractTextFromResults(info.ocrResults!);
        }
      }
      return "";
    } catch (e) {
      return "";
    }
  }

  String _extractTextFromResults(List<OcrResult> results) {
    // Sắp xếp tọa độ (giữ nguyên logic MinY, MinX đã tối ưu trước đó)
    final sortedResults = List<OcrResult>.from(results.where((e) => e.name != null));

    sortedResults.sort((a, b) {
      final aBounds = a.bounds;
      final bBounds = b.bounds;
      if (aBounds == null || aBounds.isEmpty || bBounds == null || bBounds.isEmpty) return 0;

      final double aMinY = aBounds.map((p) => (p.y ?? 0).toDouble()).reduce(min);
      final double bMinY = bBounds.map((p) => (p.y ?? 0).toDouble()).reduce(min);

      if ((aMinY - bMinY).abs() < 20) {
        final double aMinX = aBounds.map((p) => (p.x ?? 0).toDouble()).reduce(min);
        final double bMinX = bBounds.map((p) => (p.x ?? 0).toDouble()).reduce(min);
        return aMinX.compareTo(bMinX);
      }
      return aMinY.compareTo(bMinY);
    });

    return sortedResults.map((e) => e.name).join(" ").trim();
  }
}