import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hotronguoikhiemthi_app/feature/screen/camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  Future<CameraDescription?> _startCamera() async {
    try {
      final cameras = await availableCameras();
      final firtsCamera = cameras.first;
      return firtsCamera;
    } catch (e) {
      return null;
    }
  }

  Future<void> _openCamera() async {
    final camera = await _startCamera();
    if (camera != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraScreen(camera: camera)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể mở camera')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              GestureDetector(onVerticalDragDown: (details) {
                _openCamera();
              }),
            ]),
          ),
        ],
      ),
    );
  }
}
