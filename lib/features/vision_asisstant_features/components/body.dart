import 'dart:ui';
import 'package:build_access/config/my_colors.dart';
import 'package:build_access/core/speech/speech_to_text/speech_to_text_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/navigator/app_navigator.dart';
import 'package:build_access/core/widgets/button_action_micro_widget.dart';
import 'package:build_access/features/camera_feature/camera_features.dart';
import 'package:build_access/features/home_feature/home_features.dart';
import 'package:build_access/features/vision_asisstant_features/components/organic_glow_painter.dart';
import 'package:build_access/view_models/vision_assistant_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Body extends StatefulWidget {
  final VisionAssistantViewModel model;
  const Body({super.key, required this.model});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    widget.model.addListener(_onViewModelChange);
    _waveController.repeat();
  }

  void _onViewModelChange() {
    if (!widget.model.voiceInteractionProvider.isSpeaking) {
      _waveController.stop();
    } else {
      if (!_waveController.isAnimating) _waveController.repeat();
    }
    if (mounted) setState(() {});
  }

  void _handleExitToScan() {
    HapticFeedback.mediumImpact();
    getIt<AppNavigator>().pushNamedAndRemoveUntil(CameraFeatures.routerName);
  }

  void _handleExitToHome() {
    HapticFeedback.heavyImpact();
    getIt<AppNavigator>().pushNamedAndRemoveUntil(HomeFeatures.routerName);
  }

  @override
  void dispose() {
    _waveController.stop();
    widget.model.removeListener(_onViewModelChange);
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleExitToScan();
      },
      child: Scaffold(
        backgroundColor: MyColors.bgDark, // Đen sâu thẳm
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onForcePressEnd: (_) => _handleExitToScan(),
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! < -300) _handleExitToHome();
          },
          child: Stack(
            children: [
              // 1. Nền Gradient mờ ảo phía sau
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5,
                      colors: [const Color(0xFF1A1F38), MyColors.bgDark],
                    ),
                  ),
                ),
              ),

              // 2. Hệ thống sóng âm Google Assistant ở dưới đáy
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 200,
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // Hiệu ứng nhòe (Blur) để sóng trông ảo diệu hơn
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        CustomPaint(
                          painter: GoogleAssistantWavePainter(
                            animation: _waveController,
                          ),
                          size: Size.infinite,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // 3. Nội dung văn bản chính
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      // Icon AI nhỏ xinh phía trên
                      Icon(
                        Icons.auto_awesome,
                        color: widget.model.voiceInteractionProvider.isSpeaking
                            ? MyColors.primaryGold
                            : MyColors.textGrey,
                        size: 30,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            (widget.model.result.trim().isEmpty)
                                ? "vision_reading_image".tr
                                : widget
                                      .model.result,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: MyColors.textWhite.withValues(alpha: 0.5),
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                              height: 1.6,
                              // Đổ bóng nhẹ cho chữ dễ đọc
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black.withValues(alpha: 0.5),
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 150), // Chừa chỗ cho sóng âm
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: ButtonActionMicroWidget(
                    onLongPressedStart: () =>
                        getIt<SpeechToTextEngine>().startWalkieTalkie(),
                    onLongPressedEnd: () => widget.model.stopUserAsking(),
                  ),
                ),
              ),

              // 4. Chỉ báo "Đang nói" (Glow dot)
              if (widget.model.voiceInteractionProvider.isSpeaking)
                Positioned(
                  top: 40,
                  right: 30,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: MyColors.primaryGold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: MyColors.primaryGold,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
