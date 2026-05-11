import 'package:build_access/view_models/onboarding_view_model.dart';
import 'package:build_access/widgets/button_action_micro_widget.dart';
import 'package:flutter/material.dart';

class Body extends StatefulWidget {
  final OnboardingViewModel model;
  const Body({super.key, required this.model});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF050505)),
      child: Stack(
        children: [
          Positioned(
            top: 80,
            left: 30,
            right: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "THIẾT LẬP\nHỒ SƠ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Ấn giữ vòng tròn bên dưới để giới thiệu về bạn: Họ tên, địa chỉ và tiền sử bệnh lý.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          ButtonActionMicroWidget(
            onLongPressedStart: widget.model.startRecording,
            onLongPressedEnd: widget.model.stopRecording,
          ),

          if (widget.model.isHolding || widget.model.isAiProcessing)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.7,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  widget.model.isHolding
                      ? "Đang thu âm (Nhả tay để gửi)..."
                      : "AI đang xử lý...",
                  style: TextStyle(
                    color: widget.model.isAiProcessing
                        ? const Color(0xFF00C853)
                        : const Color(0xFF4285F4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
