import 'package:build_access/config/my_colors.dart';
import 'package:build_access/view_models/splash_view_model.dart';
import 'package:flutter/material.dart';

class Body extends StatefulWidget {
  final SplashViewModel model;
  const Body({super.key, required this.model});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Tạo hiệu ứng nhịp đập cho logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.bgDark, // Nền đen sâu cực sang
      body: Stack(
        children: [
          // Hiệu ứng các hạt sáng mờ ảo ở nền
          Positioned(
            top: -100,
            right: -50,
            child: _buildBlurCircle(MyColors.primaryGold, 200),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: _buildBlurCircle(MyColors.successGreen, 150),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO AI & Hiệu ứng Pulse
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                      boxShadow: [
                        BoxShadow(
                          color: MyColors.primaryGold.withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.remove_red_eye_rounded, // Hoặc logo dự án của ní
                      size: 80,
                      color: MyColors.textWhite,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Tên ứng dụng với Gradient
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [MyColors.primaryGold, MyColors.textWhite],
                  ).createShader(bounds),
                  child: const Text(
                    "BUILD ACCESS",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: MyColors.textWhite,
                      letterSpacing: 4,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  "AI ASSISTANT FOR THE BLIND",
                  style: TextStyle(
                    color: MyColors.textWhite.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          // Chỉ báo Loading ở dưới cùng
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 40,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.white10,
                      color: MyColors.primaryGold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Đang khởi tạo hệ thống AI...",
                  style: TextStyle(color: MyColors.textGrey, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget tạo các đốm sáng mờ ảo
  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}
