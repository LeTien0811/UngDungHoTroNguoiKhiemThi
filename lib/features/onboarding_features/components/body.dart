import 'package:build_access/view_models/onboarding_view_model.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/services/scan/haptic_hardware_service.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

class Body extends StatefulWidget {
  final OnboardingViewModel model;
  const Body({super.key, required this.model});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool _isHolding = false;
  bool _isAiProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF050505)),
      child: Stack(
        children: [
          // ... Giữ nguyên Text phía trên ...
          Center(
            child: GestureDetector(
              onLongPressStart: (_) {
                // Đang xử lý AI thì không cho bấm đè lên
                if (_isAiProcessing) return;

                getIt<HapticHardwareService>().executeSystemVibration();

                setState(() => _isHolding = true);
                widget.model.startRecording();
              },
              onLongPressEnd: (_) async {
                // Nếu không giữ (do lỗi chạm lướt) hoặc đang xử lý thì bỏ qua
                if (!_isHolding || _isAiProcessing) return;

                getIt<HapticHardwareService>().executeSystemVibration();

                setState(() {
                  _isHolding = false;
                  _isAiProcessing = true; // Khóa UI chờ AI
                });

                bool success = await widget.model.stopRecordingAndProcess();

                if (mounted) {
                  setState(() => _isAiProcessing = false); // Mở khóa UI
                  if (success) {
                    // TODO: Navigate qua màn hình Home
                  }
                }
              },
              child: AvatarGlow(
                animate: _isHolding,
                glowColor: const Color(0xFF4285F4),
                duration: const Duration(milliseconds: 1000),
                repeat: true,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isHolding ? 180 : 160,
                  height: _isHolding ? 180 : 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isHolding
                          ? [const Color(0xFF4285F4), const Color(0xFF0D47A1)]
                          : _isAiProcessing
                          ? [const Color(0xFF00C853), const Color(0xFF1B5E20)]
                          : [Colors.white10, Colors.white24],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    _isHolding
                        ? Icons.mic_rounded
                        : _isAiProcessing
                        ? Icons.hourglass_empty_rounded
                        : Icons.mic_none_rounded,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          if (_isHolding || _isAiProcessing)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.7,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  _isHolding
                      ? "Đang thu âm (Nhả tay để gửi)..."
                      : "AI đang xử lý...",
                  style: TextStyle(
                    color: _isAiProcessing
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
