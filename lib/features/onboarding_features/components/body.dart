import 'package:build_access/config/my_colors.dart';
import 'package:build_access/view_models/onboarding_view_model.dart';
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
    return GestureDetector(
      onDoubleTap: () {
        widget.model.handleAction();
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: MyColors.bgDark),
        child: widget.model.isAiProcessing
            ? const Center(
                child: CircularProgressIndicator(color: MyColors.primaryGold),
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 40.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        widget.model.step == 0
                            ? Icons.remove_red_eye_rounded
                            : Icons.fingerprint_rounded,
                        size: 120,
                        color: MyColors.primaryGold,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        widget.model.step == 0 ? "BUILD ACCESS" : "BẢO MẬT",
                        style: const TextStyle(
                          color: MyColors.textWhite,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
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
                      const SizedBox(height: 30),
                      Text(
                        widget.model.step == 0
                            ? "Trợ lý thị giác thông minh.\nSử dụng AI để nhận diện không gian xung quanh bạn."
                            : "Công nghệ Passkey an toàn.\nLiên kết Google để đồng bộ dữ liệu.",
                        style: const TextStyle(
                          color: MyColors.textGrey,
                          fontSize: 18,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: MyColors.primaryGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: MyColors.primaryGold.withOpacity(0.5),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, color: MyColors.primaryGold),
                            SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Chạm hai lần để tiếp tục",
                                style: TextStyle(
                                  color: MyColors.primaryGold,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
