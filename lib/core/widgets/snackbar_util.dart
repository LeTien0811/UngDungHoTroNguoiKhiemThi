import 'dart:ui';
import 'package:flutter/material.dart';

class SnackbarUtil {
  static void show(
    BuildContext context, {
    required String message,
    required Color bgColor,
  }) {
    // Xóa Snackbar cũ ngay lập tức để không bị chồng chéo
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Làm cho Snackbar bay lơ lửng thay vì dính đáy
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            Colors.transparent, // Nền trong suốt để hiện hiệu ứng mờ
        elevation: 0,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.only(
          bottom: 100, // Đẩy lên cao một chút để không che mất các nút dưới đáy
          left: 20,
          right: 20,
        ),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ), // Hiệu ứng mờ kính
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                // Kết hợp màu bgColor của ní với độ mờ
                color: bgColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Thêm icon để người dùng dễ nhận diện trạng thái
                  Icon(_getIconByColor(bgColor), color: Colors.white, size: 30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      message,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20, // Chữ to rõ cho người thị lực kém
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm bổ trợ để chọn Icon tự động dựa trên màu nền (Thành công/Lỗi/Cảnh báo)
  static IconData _getIconByColor(Color color) {
    if (color == Colors.red || color.red > color.green) {
      return Icons.error_outline_rounded;
    } else if (color == Colors.green || color.green > color.red) {
      return Icons.check_circle_outline_rounded;
    }
    return Icons.info_outline_rounded;
  }
}
