import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hotronguoikhiemthi_app/screen/camera_screen.dart';

class HomeScreen extends StatefulWidget {
  final CameraDescription camera;

  const HomeScreen({
    super.key,
    required this.camera,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openCamera() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CameraScreen(camera: widget.camera)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                GestureDetector(
                  onVerticalDragDown: (details) {
                    _openCamera();
                  },
                ),
              ]),
            ),
          ],
        ),
    );
  }
}
