import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/view_models/onboarding_view_model.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart'; // Nếu chưa có hãy chạy: flutter pub add avatar_glow

class Body extends StatefulWidget {
  final OnboardingViewModel model;
  const Body({super.key, required this.model});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool _isListening = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF050505), // Cùng tông màu nền với Splash
      ),
      child: Stack(
        children: [
          // 1. Phần tiêu đề hướng dẫn (Phía trên)
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

          // 2. NÚT NHẤN GIỮ Ở GIỮA (Trung tâm trải nghiệm)
          Center(
            child: GestureDetector(
              onLongPressStart: (_) async {
                setState(() => _isListening = true);
                // Gọi hàm bắt đầu thu âm từ ViewModel của ní
                widget.model.startVoiceOnboarding();
              },
              onLongPressEnd: (_) async {
                setState(() => _isListening = false);
                // Dừng thu âm và lấy kết quả
                widget.model.onUserFinishedSpeaking();
              },
              child: AvatarGlow(
                animate: _isListening,
                glowColor: const Color(0xFF4285F4),
                duration: const Duration(milliseconds: 1000),
                repeat: true,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isListening ? 180 : 160,
                  height: _isListening ? 180 : 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [const Color(0xFF4285F4), const Color(0xFF0D47A1)]
                          : [Colors.white10, Colors.white24],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isListening
                            ? const Color(0xFF4285F4).withOpacity(0.5)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // 3. Hiệu ứng Text chạy khi đang nghe (Phía dưới nút)
          if (_isListening)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.7,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  "Đang lắng nghe...",
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

          // 4. Nút bỏ qua hoặc trợ giúp ở góc dưới
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: () {
                  // Logic bỏ qua nếu cần
                },
                child: Text(
                  "BẠN CẦN TRỢ GIÚP?",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}