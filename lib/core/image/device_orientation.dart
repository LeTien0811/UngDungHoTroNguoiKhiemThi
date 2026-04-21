import 'package:build_access/services/camera_hardware_serivce.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

final orientationsCheck = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

InputImageRotation getRotation(int degree) {
  switch (degree) {
    case 0:
      return InputImageRotation.rotation0deg;
    case 90:
      return InputImageRotation.rotation90deg;
    case 180:
      return InputImageRotation.rotation180deg;
    case 270:
      return InputImageRotation.rotation270deg;
    default:
      return InputImageRotation.rotation0deg;
  }
}

int resolveRotationDegree(CameraHardwareService hardWare) {
  final int sensorOrientation = hardWare.camera!.sensorOrientation;
  final DeviceOrientation deviceOrientation =
      hardWare.controller!.value.deviceOrientation;
  final CameraLensDirection lensDirection =
      hardWare.camera!.lensDirection;

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



