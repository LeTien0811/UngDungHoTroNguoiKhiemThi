import 'package:build_access/constant/color.dart';
import 'package:flutter/material.dart';

class DerectorText extends StatelessWidget {
  final String text;
  final IconData icon;

  const DerectorText({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Cực kỳ quan trọng để không bị tràn màn hình
      children: [
        Text(
          text,
          style: const TextStyle(
            color: MyColors.actionCyan,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        Icon(icon, size: 60, color: MyColors.actionCyan),
      ],
    );
  }
}