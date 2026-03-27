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
