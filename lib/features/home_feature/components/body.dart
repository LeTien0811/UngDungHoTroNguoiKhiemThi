import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/navigator/app_navigator.dart';
import 'package:build_access/features/camera_feature/camera_features.dart';
import 'package:build_access/features/home_feature/components/derector_text.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:build_access/config/my_colors.dart';
import 'package:build_access/core/widgets/snackbar_util.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer_log;
import 'package:get/get.dart';

class Body extends StatefulWidget {
  final HomeViewModel model;
  const Body({super.key, required this.model});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  bool isHolding = false;
  bool isAiProcessing = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        HapticFeedback.heavyImpact();
      },
      child: Scaffold(
        backgroundColor: MyColors.bgDark,
        body: Stack(
          children: [
            // 1. Nền Gradient & Blur (Giống VoiceConfirm)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MyColors.bgDark,
                    MyColors.primaryGold.withValues(alpha: 0.15),
                    MyColors.bgDark,
                  ],
                ),
              ),
            ),

            // 2. Nội dung chính
            Semantics(
              label: 'home_semantics_label'.tr,
              explicitChildNodes: false,
              child: SafeArea(
                child: GestureDetector(
                  onLongPressStart: (_) async {
                    if (isAiProcessing) return;
                    HapticFeedback.heavyImpact();
                    setState(() {
                      isHolding = true;
                    });
                    await widget.model.startRecording();
                    SnackbarUtil.show(
                      context,
                      message: 'home_ask_question_snackbar'.tr,
                      bgColor: MyColors.textWhite,
                    );
                  },
                  onLongPressEnd: (_) async {
                    if (!isHolding) return;

                    setState(() {
                      isHolding = false;
                      isAiProcessing = true;
                    });

                    try {
                      HapticFeedback.mediumImpact();
                      await widget.model.stopRecording();
                    } catch (e) {
                      developer_log.log("Lỗi khi xử lý ghi âm: $e");
                    } finally {
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
                      getIt<AppNavigator>().navigateTo(
                        CameraFeatures.routerName,
                      );
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Vòng tròn Mic trung tâm
                        ScaleTransition(
                          scale: Tween(begin: 1.0, end: isHolding ? 1.2 : 1.05)
                              .animate(
                                CurvedAnimation(
                                  parent: _pulseController,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            height: MediaQuery.of(context).size.width * 0.75,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isHolding
                                  ? MyColors.primaryGold.withValues(
                                      alpha: 0.2,
                                    )
                                  : MyColors.textWhite.withValues(alpha: 0.05),
                              border: Border.all(
                                color: isHolding
                                    ? MyColors.primaryGold
                                    : MyColors.textWhite.withValues(alpha: 0.2),
                                width: isHolding ? 6 : 2,
                              ),
                              boxShadow: [
                                if (isHolding)
                                  BoxShadow(
                                    color: MyColors.primaryGold.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon thay đổi theo trạng thái
                                Icon(
                                  isAiProcessing
                                      ? Icons.sync_rounded
                                      : (isHolding
                                            ? Icons.mic_rounded
                                            : Icons.mic_none_rounded),
                                  size: 100,
                                  color: isHolding
                                      ? MyColors.primaryGold
                                      : MyColors.textWhite,
                                ),
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    isAiProcessing
                                        ? 'Đang xử lý...'
                                        : (isHolding
                                              ? 'home_listening'.tr
                                              : 'home_touch_to_speak_scan'.tr),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: MyColors.textWhite,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10,
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer - Chỉ dẫn vuốt
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _pulseController, // Làm mờ nhẹ theo nhịp thở
                child: DerectorText(
                  text: 'home_read_info'.tr,
                  icon: Icons
                      .keyboard_double_arrow_up_rounded, // Đổi icon cho đúng hướng vuốt lên
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
