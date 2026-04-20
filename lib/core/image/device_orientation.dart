import 'package:build_access/core/camera/camera_hardware_manager.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

final orientationsCheck = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

int checkRotation(dynamic metadata) {
  int rotationDegrees = 0;
  switch(metadata.rotation) {
    case InputImageRotation.rotation90deg: rotationDegrees = 90; break;
    case InputImageRotation.rotation180deg: rotationDegrees = 180; break;
    case InputImageRotation.rotation270deg: rotationDegrees = 270; break;
    default: break;
  }
  return rotationDegrees;
}

int resolveRotationDegree(CameraService cameraService) {
  final int sensorOrientation = cameraService.camera!.sensorOrientation;
  final DeviceOrientation deviceOrientation =
      cameraService.controller!.value.deviceOrientation;
  final CameraLensDirection lensDirection =
      cameraService.camera!.lensDirection;

  return getRotationCompensation(
    sensorOrientation,
    deviceOrientation,
    lensDirection,
  );
}

int getRotationCompensation(int sensorOrientation, DeviceOrientation deviceOrientation, CameraLensDirection lensDirection) {
  int deviceRotation = 0;
  switch (deviceOrientation) {
    case DeviceOrientation.portraitUp:
      deviceRotation = 0;
      break;
    case DeviceOrientation.landscapeLeft:
      deviceRotation = 90;
      break;
    case DeviceOrientation.portraitDown:
      deviceRotation = 180;
      break;
    case DeviceOrientation.landscapeRight:
      deviceRotation = 270;
      break;
  }

  int rotationCompensation;
  if (lensDirection == CameraLensDirection.front) {
    // Camera trước: Lật ngược trục
    rotationCompensation = (sensorOrientation + deviceRotation) % 360;
  } else {
    // Camera sau: Bù trừ thông thường
    rotationCompensation = (sensorOrientation - deviceRotation + 360) % 360;
  }
  return rotationCompensation;
}