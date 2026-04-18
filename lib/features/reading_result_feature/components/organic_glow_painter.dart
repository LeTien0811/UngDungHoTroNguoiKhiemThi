import 'dart:math' as math;
import 'package:flutter/material.dart';

class GoogleAssistantWavePainter extends CustomPainter {
  final Animation<double> animation;
  GoogleAssistantWavePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Danh sách 4 màu đặc trưng của Google/AI hiện đại
    final colors = [
      const Color(0xFF4285F4).withOpacity(0.7), // Blue
      const Color(0xFFEA4335).withOpacity(0.7), // Red
      const Color(0xFFFBBC05).withOpacity(0.7), // Yellow
      const Color(0xFF34A853).withOpacity(0.7), // Green
    ];

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      final path = Path();

      // Mỗi lớp sóng sẽ có tần số và biên độ khác nhau để tạo sự tự nhiên
      double phase = animation.value * 2 * math.pi + (i * math.pi / 2);
      double amplitude = 15.0 + (i * 5);
      double frequency = 0.01 + (i * 0.005);

      path.moveTo(0, size.height);
      for (double x = 0; x <= size.width; x++) {
        // Công thức sóng hình sin: y = A * sin(kx + phase)
        double y = amplitude * math.sin((x * frequency) + phase) + (size.height * 0.85);
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}