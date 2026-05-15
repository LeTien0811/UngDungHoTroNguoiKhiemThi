import 'package:build_access/config/my_colors.dart';
import 'package:build_access/view_models/setup_profile_view_model.dart';
import 'package:build_access/core/widgets/button_action_micro_widget.dart';
import 'package:flutter/material.dart';

class Body extends StatefulWidget {
  final SetupProfileViewModel model;
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
      decoration: const BoxDecoration(color: MyColors.bgDark),
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
                    color: MyColors.textWhite,
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
                    color: MyColors.primaryGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Ấn giữ vòng tròn bên dưới để giới thiệu về bạn: Họ tên, địa chỉ và tiền sử bệnh lý.",
                  style: TextStyle(
                    color: MyColors.textGrey,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          ButtonActionMicroWidget(
            onLongPressedStart: widget.model.startRecording,
            onLongPressedEnd: widget.model.stopRecordingAndProcess,
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
                        ? MyColors.successGreen
                        : MyColors.primaryGold,
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
