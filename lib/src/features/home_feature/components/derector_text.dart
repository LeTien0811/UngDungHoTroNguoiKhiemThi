import 'package:build_access/constant/color.dart';
import 'package:flutter/material.dart';

class DerectorText extends StatefulWidget {
  final String text;
  final IconData icon;
  final double top;
  final double bottom;
  final double left;
  final double right;
  const DerectorText({
    super.key,
    required this.text,
    required this.icon,
    required this.top,
    required this.left,
    required this.bottom,
    required this.right,
  });

  @override
  State<DerectorText> createState() => _DerectorTextState();
}

class _DerectorTextState extends State<DerectorText> {
  @override
  Widget build(BuildContext context) {
    return  Positioned(
      top: widget.top,
      bottom: widget.bottom,
      right: widget.right,
      left: widget.left,
      child: Column(
        children: [
          Text(
            widget.text,
            style: TextStyle(
              color: MyColors.actionCyan,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Icon(widget.icon, size: 60, color: MyColors.actionCyan),
        ],
      ),
    );
  }
}

