import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/navigator/app_navigator.dart';
import 'package:build_access/features/camera_feature/camera_features.dart';
import 'package:build_access/features/home_feature/components/derector_text.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:build_access/constant/color.dart';
import 'package:build_access/widgets/snackbar_util.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer_log;

class Body extends StatefulWidget {
  final HomeViewModel model;
  const Body({super.key, required this.model});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isHolding = false;
  bool isAiProcessing = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        HapticFeedback.heavyImpact();
      },
      child: Scaffold(
        backgroundColor: MyColors.bgDark,

        body: Semantics(
          label:
              'Màn hình chính. Chạm đúp vào giữa màn hình để nói hoặc quét thuốc. '
              'Vuốt sang trái để mở Lịch sử. Vuốt sang phải để mở Cài đặt.',
          explicitChildNodes: false,
          child: SafeArea(
            child: GestureDetector(
              onLongPressStart: (_) async {
                if (isAiProcessing) return;
                setState(() {
                  isHolding = true;
                });
                await widget.model.startRecording();
                SnackbarUtil.show(
                  context,
                  message: "🔊 Hãy đặt câu hỏi",
                  bgColor: MyColors.textWhite,
                );
              },
              onLongPressEnd: (_) async {
                if (!isHolding) return;

                setState(() {
                  isHolding = false;
                  isAiProcessing = true; // Khóa UI
                });

                try {
                  HapticFeedback.mediumImpact();
                  // Gọi xuống ViewModel xử lý AI/Intent
                  await widget.model.stopRecording();
                } catch (e) {
                  developer_log.log("Lỗi khi xử lý ghi âm: $e");
                } finally {
                  // NHÁT DAO CHÍNH: Dù thành công hay thất bại, PHẢI mở khóa UI
                  if (mounted) {
                    setState(() {
                      isAiProcessing = false;
                    });
                  }
                }
              },
              onVerticalDragEnd: (details) {
                if (isAiProcessing || isHolding) return;

                if (details.primaryVelocity! < -300) {
                  HapticFeedback.lightImpact();
                  getIt<VoiceInteractionProvider>().stopSpeaking();
                  SnackbarUtil.show(
                    context,
                    message: "Chuyển sang: Đọc Thông Tin",
                    bgColor: MyColors.actionCyan,
                  );
                  getIt<AppNavigator>().navigateTo(
                    CameraFeatures.routerName,
                  );
                }
              },

              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: MyColors.textWhite.withValues(alpha: 0.3),
                            width: 4,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.mic_none_rounded,
                              size: 80,
                              color: MyColors.textWhite,
                            ),
                            SizedBox(height: 20),
                            Text(
                              "CHẠM ĐỂ\nNÓI / QUÉT",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: MyColors.textWhite,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Đưa Positioned ra đây để làm con ruột của Stack
                    const Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: DerectorText(
                        text: "Đọc Thông Tin",
                        icon: Icons.keyboard_double_arrow_down_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
