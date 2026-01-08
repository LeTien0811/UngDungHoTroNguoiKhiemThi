import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hotronguoikhiemthi_app/provider/app_state_manager.dart';
import 'package:hotronguoikhiemthi_app/services/camera_services.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraServices cameraServices;
  late Future<void> _initializeFuture;
  @override
  void initState() {
    super.initState();
    cameraServices = CameraServices(widget.camera, context.read<AppStateManager>().speak);

    _initializeFuture = cameraServices.initialize();
  }

  @override
  void dispose() {
    cameraServices.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đang quét văn bản....')),
      body: FutureBuilder<void>(
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CameraPreview(cameraServices.cameraController),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi camera: ${snapshot.error}"));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
