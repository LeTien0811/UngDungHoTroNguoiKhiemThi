import 'package:flutter/material.dart';
import 'dart:math' as math;

class OrganicGlowPainter extends CustomPainter {
  final Animation<double> animation;

  OrganicGlowPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0) return;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.8;

    for (int i = 0; i < 3; i++) {
      final waveValue = (animation.value + (i * 0.33)) % 1.0;
      final radius = maxRadius * waveValue;

      paint.color = Colors.white.withOpacity(1.0 - waveValue);

      final noise = 1.0 + (math.sin(animation.value * math.pi * 2 + i) * 0.05);

      canvas.drawCircle(center, radius * noise, paint);
    }
  }

  @override
  bool shouldRepaint(covariant OrganicGlowPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value;
  }
}