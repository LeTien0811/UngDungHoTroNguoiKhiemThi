import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hotronguoikhiemthi_app/provider/app_state_manager.dart';
import 'package:hotronguoikhiemthi_app/screen/camera_screen.dart';
import 'package:hotronguoikhiemthi_app/services/log_error_services.dart';
import 'package:hotronguoikhiemthi_app/widget/loading_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openCamera() async {
    LogErrorServices.showLog(
      where: 'Home screen',
      type: 'mở camera',
      message: 'bắt đầu mở camera',
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  CameraScreen()),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext builderContext) {
        final provider = builderContext.watch<AppStateManager>();
        if (provider.isLoading) {
          return const LoadingScreen();
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: GestureDetector(
                    // hỗ bat su kien chạm vào khảong trắng
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragEnd: (detail) {
                      if (detail.primaryVelocity! > 0) {
                        _openCamera();
                      }
                    },

                    onDoubleTap: () {
                      provider.startSpeech();
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: const Text(
                        "Vuốt xuống để mở Camera\nNhấn đúp để nói",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
