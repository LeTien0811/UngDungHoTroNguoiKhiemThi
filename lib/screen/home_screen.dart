import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hotronguoikhiemthi_app/provider/app_state_manager.dart';
import 'package:hotronguoikhiemthi_app/screen/camera_screen.dart';
import 'package:hotronguoikhiemthi_app/widget/loading_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final CameraDescription camera;

  const HomeScreen({super.key, required this.camera});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openCamera() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(camera: widget.camera),
      ),
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
            body: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    GestureDetector(
                      onVerticalDragDown: (detail) {
                        _openCamera();
                      },

                      onDoubleTap: () {
                        provider.startSpeech();
                      },
                    ),
                  ]),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
