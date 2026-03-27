import 'package:build_access/view/camera_view_model.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Body extends StatefulWidget {
  final CameraViewModel model;
  const Body({super.key, required this.model});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (widget.model.cameraService.controller != null)
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CameraPreview(widget.model.cameraService.controller!),
            )
          else
            const Center(child: CircularProgressIndicator()),
          Positioned(
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
