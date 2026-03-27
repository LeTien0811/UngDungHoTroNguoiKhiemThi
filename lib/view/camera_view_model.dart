import 'package:build_access/config/base_model.dart';
import 'package:build_access/core/utils/camera/image_handle.dart';
import 'dart:developer' as developer_log;
import 'package:build_access/enum/config.dart';
import 'package:build_access/providers/locator.dart';
import 'package:build_access/providers/service_provider.dart';
import 'package:build_access/services/camera_service.dart';
import 'package:camera/camera.dart';

class CameraViewModel extends BaseModel {
  final ImageHandle _imageHandle = ImageHandle();
  final CameraService cameraService = getIt<CameraService>();
  final ProviderSevice providerSevice = getIt<ProviderSevice>();
  CameraDescription? camera;

  final int _throttleDuration = 1000;
  DateTime _lastScanTime = DateTime.now();

  Future<void> initCamera() async{
    await runSafe(() async{
        camera =await cameraService.getFirstCamera();
       cameraService.init(camera!);
     }, 'CameraModel.init');
  }

  Future<void> startStream() async {
    if (state == ViewState.busy) {
      return;
    }
    if (cameraService.controller!.value.isStreamingImages) return;

    await cameraService.controller!.startImageStream((CameraImage image) async {

      if (state == ViewState.busy) return;

      if (DateTime.now().difference(_lastScanTime).inMilliseconds <
          _throttleDuration) {
        return;
      }

      try {
        setState(ViewState.busy);
        _lastScanTime = DateTime.now();

        await _imageHandle.processImageFromFrame(
          image,
          providerSevice.speechQueue as Function(String message),
          camera!,
          cameraService.controller!,
        );

      } catch (e) {

        if (e == 'RECAPTURE') {
          developer_log.log(
            'Không nhận diện được quét lại: $e',
            name: 'stream.camera_service',
          );
        } else if (e == 'SUCCESS_READING') {
          await stopStream();
          // go to view show text
        } else {
          developer_log.log(
            'Lỗi luồng Camera: $e',
            name: 'stream.camera_service',
          );
          rethrow;
        }

      } finally {
        setState(ViewState.idle);
      }
    });
  }

  Future<void> stopStream() async {
    await runSafe(() async{
      if(cameraService.controller != null && cameraService.controller!.value.isStreamingImages) {
       await cameraService.controller!.stopImageStream();
       return;
      }
    }, 'CameraModel.stopStream');
  }

  @override
  void dispose() {
    super.dispose();
    cameraService.dispose();
  }
}