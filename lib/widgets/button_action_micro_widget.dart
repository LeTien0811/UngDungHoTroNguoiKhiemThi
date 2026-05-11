import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

class ButtonActionMicroWidget extends StatefulWidget {
  final Future Function() onLongPressedStart;
  final Future Function() onLongPressedEnd;
  const ButtonActionMicroWidget({
    super.key,
    required this.onLongPressedStart,
    required this.onLongPressedEnd,
  });

  @override
  State<ButtonActionMicroWidget> createState() =>
      _ButtonActionMicroWidgetState();
}

class _ButtonActionMicroWidgetState extends State<ButtonActionMicroWidget> {
  bool isHolding = false;
  bool isAiProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onLongPressStart: (_) async {
          if (isAiProcessing) return;
          setState(() => isHolding = true);

          await widget.onLongPressedStart();
        },

        onLongPressEnd: (_) async {
          if (!isHolding || isAiProcessing) return;
          setState(() {
            isHolding = false;
            isAiProcessing = true; // Khóa UI chờ AI
          });

          await widget.onLongPressedEnd();
          if (mounted) {
            setState(() => isAiProcessing = false);
          }
        },

        child: AvatarGlow(
          animate: isHolding,
          glowColor: const Color(0xFF4285F4),
          duration: const Duration(milliseconds: 1000),
          repeat: true,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isHolding ? 180 : 160,
            height: isHolding ? 180 : 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isHolding
                    ? [const Color(0xFF4285F4), const Color(0xFF0D47A1)]
                    : isAiProcessing
                    ? [const Color(0xFF00C853), const Color(0xFF1B5E20)]
                    : [Colors.white10, Colors.white24],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              isHolding
                  ? Icons.mic_rounded
                  : isAiProcessing
                  ? Icons.hourglass_empty_rounded
                  : Icons.mic_none_rounded,
              size: 70,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
