import 'package:build_access/src/features/reading_result_feature/components/organic_glow_painter.dart';
import 'package:build_access/view/reading_result_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Body extends StatefulWidget {
  final ReadingResultViewModel model;
  const Body({super.key, required this.model});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late ReadingResultViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  void _onViewModelChange() {
    final isSpeaking = _viewModel.providerSevice.isSpeaking;
    if (isSpeaking && !_glowController.isAnimating) {
      _glowController.repeat();
    } else if (!isSpeaking && _glowController.isAnimating) {
      _glowController.stop();
      _glowController.animateTo(0, duration: const Duration(milliseconds: 500));
    }
  }

  void _handleExitToScan() {
    HapticFeedback.mediumImpact();
    _viewModel.dispose();
    Navigator.pop(context);
  }

  void _handleExitToHome() {
    HapticFeedback.heavyImpact();
    _viewModel.dispose();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleExitToScan();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B132B),
        body: SafeArea(
          child: Semantics(
            label: 'Đang đọc kết quả. Chạm một lần hoặc chạm đúp để quét lại. Vuốt lên bằng hai ngón tay để về trang chủ.',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleExitToScan,
              onDoubleTap: _handleExitToScan,
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! < -300) {
                  _handleExitToHome();
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return RadialGradient(
                            colors: [
                              const Color(0xFF00FFFF).withOpacity(0.6 * _glowController.value),
                              const Color(0xFFFF00FF).withOpacity(0.3 * _glowController.value),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.4 + (_glowController.value * 0.4), 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: CustomPaint(
                          painter: OrganicGlowPainter(animation: _glowController),
                          size: const Size(double.infinity, double.infinity),
                        ),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              widget.model.fullResponse.isEmpty
                                  ? "Đang phân tích dữ liệu..."
                                  : widget.model.fullResponse,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFF3C623),
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}