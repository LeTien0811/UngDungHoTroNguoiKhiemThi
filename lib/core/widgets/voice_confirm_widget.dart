import 'dart:ui';
import 'package:build_access/config/my_colors.dart';
import 'package:build_access/services/hardware/haptic_hardware_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/core/utils/dependency_injection.dart';

class VoiceConfirmWidget extends StatefulWidget {
  final String message;

  const VoiceConfirmWidget({super.key, required this.message});

  static Future<bool?> show({required String message}) async {
    return await Get.dialog<bool>(
      VoiceConfirmWidget(message: message),
      useSafeArea: false,
      barrierDismissible: false,
      transitionCurve: Curves.easeInOutBack,
    );
  }

  @override
  State<VoiceConfirmWidget> createState() => _VoiceConfirmWidgetState();
}

class _VoiceConfirmWidgetState extends State<VoiceConfirmWidget>
    with SingleTickerProviderStateMixin {
  final VoiceInteractionProvider _voice = getIt<VoiceInteractionProvider>();
  late AnimationController _controller;
  final HapticHardwareService hapticFeedback = getIt<HapticHardwareService>();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _speakMessage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _speakMessage() async {
    await _voice.speak(widget.message);
  }

  void _handleConfirm() {
    hapticFeedback.executeSystemVibration();
    _voice.stopSpeaking();
    Get.back(result: true);
  }

  void _handleCancel() {
    hapticFeedback.executeSystemVibration();
    _voice.stopSpeaking();
    Get.back(result: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Nền mờ kính cường lực
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: MyColors.primaryGold.withValues(alpha: 0.05),
            ),
          ),

          GestureDetector(
            onDoubleTap: _handleConfirm,
            onHorizontalDragEnd: (details) {
              // Vuốt sang phải (vận tốc dương) để hủy
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 0) {
                _handleCancel();
              }
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    MyColors.bgDark.withValues(alpha: 0.7),
                    theme.colorScheme.primary.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon nhịp thở tạo cảm giác app đang lắng nghe
                    ScaleTransition(
                      scale: Tween(begin: 1.0, end: 1.1).animate(_controller),
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: const Icon(
                          Icons.mic_none_rounded,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Nội dung tin nhắn
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black54,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Chỉ dẫn thao tác (Hướng dẫn trực quan cho người có thị lực kém)
                    _buildInstructionRow(
                      Icons.touch_app,
                      "Chạm 2 lần để XÁC NHẬN",
                      theme,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionRow(
                      Icons.swipe_right,
                      "Vuốt sang phải để HỦY",
                      theme,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow(IconData icon, String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
