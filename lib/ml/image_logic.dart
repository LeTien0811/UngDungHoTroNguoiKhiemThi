import 'package:build_access/engine/image_pipeline.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer_log;
class ImageLogic {
  // chống gọi dồn dập khi luồng xử lý chưa xong
  bool _isProcessing = false;

  /// Nhận Frame từ UI -> Đẩy vào Isolate -> Trả về Frame đã xử lý
  Future<Uint8List?> analyzeFrame(Uint8List bytes, int width, int height) async {
    // Nếu AI đang bận xử lý frame trước đó, LẬP TỨC BỎ QUA frame này
    if (_isProcessing) return null;

    _isProcessing = true;

    try {
      // Dùng compute để mở một Isolate
      // Hàm processFrameInIsolate sẽ chạy mà không làm kẹt Main Thread
      final resultBytes = await compute(processFrameIsolate, {
        'bytes': bytes,
        'width': width,
        'height': height,
      });

      return resultBytes;
    } catch (e) {
      developer_log.log("Lỗi luồng Isolate AI: $e", name: 'VisionLogic.analyzeFrame');
      return null;
    } finally {
      // xong việc thì mở cổng cho frame tiếp theo vào
      _isProcessing = false;
    }
  }
}