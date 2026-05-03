import 'package:build_access/services/camera_hardware_service.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/view_models/camera_view_model.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Body extends StatefulWidget {
  final CameraViewModel model;
  const Body({super.key, required this.model});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình để tính toán khung
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. LỚP CAMERA NỀN
          if (widget.model.cameraProvider.cameraStatus !=
              CameraStatus.uninitialized)
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CameraPreview(
                getIt<CameraHardwareService>().controller!,
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // 2. LỚP PHỦ TỐI (OVERLAY) - Tạo hiệu ứng tập trung vào giữa
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                // Lỗ thủng hình chữ nhật bo góc ở giữa để nhìn thấy camera
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: size.width * 0.8,
                    height: size.height * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. KHUNG VIỀN TỎA SÁNG (SCANNER FRAME)
          Align(
            alignment: Alignment.center,
            child: Container(
              width: size.width * 0.8,
              height: size.height * 0.25,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Thanh quét chuyển động
                  AnimatedBuilder(
                    animation: _scannerController,
                    builder: (context, child) {
                      return Positioned(
                        top:
                            _scannerController.value * (size.height * 0.25 - 2),
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withValues(alpha: 0.8),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.blueAccent,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 4. NÚT BACK (Sửa lại cho đẹp và dễ bấm hơn)
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // 5. CHỈ DẪN DƯỚI CÙNG
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  "ĐANG TỰ ĐỘNG QUÉT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Hãy đưa khung hình đối diện văn bản",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
