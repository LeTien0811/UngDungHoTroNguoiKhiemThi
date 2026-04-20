import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/models/scan/process_image_result.dart';
import 'package:build_access/core/scan/process_case_result.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/features/reading_result_feature/reading_result_features.dart';
import 'dart:developer' as developer_log;
import 'package:build_access/providers/camera_provider.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/global_provider.dart';
import 'package:build_access/core/camera/camera_hardware_manager.dart';
import 'package:build_access/core/scan/detect_and_recognizer_text.dart';
import 'package:build_access/core/utils/navigator_service.dart';
import 'package:camera/camera.dart';
import 'dart:ui' as ui;

class CameraViewModel extends BaseModel {
  // AI-added: Chặn scan thắng ngay khi model/object detector vừa warm-up để ưu tiên ổn định cho người dùng khiếm thị.
  static const int _startupWarmupMs = 2500;
  static const int _requiredStableSuccessFrames = 2;
  int _streamStartedAtMs = 0;
  int _stableSuccessFrames = 0;
  final CameraViewModel cameraViewService = getIt<CameraViewModel>();
  final GlobalProvider globalProvider = getIt<GlobalProvider>();
  final CameraProvider cameraProvider = getIt<CameraProvider>();
  final ProcessCaseResult processCaseResult = ProcessCaseResult();
  final DetectAndRecognizerText detectAndRecognizerText =
      getIt<DetectAndRecognizerText>();

  Future<void> initCamera() async {
    await runSafe(() async {
      globalProvider.speakQueue(
        'Bắt đầu tạo camera và lấy nét vật thể vui lòng đưa máy đối diện vật muốn và chờ trong giây lát',
      );
      await cameraViewService.init();

      await detectAndRecognizerText.init();

      await startProcess();

      globalProvider.speakQueue('Khởi động thành công bắt đầu nhận diện!');
    }, 'CameraModel.init');
  }

  Future<void> startProcess() async {
    setState(ViewState.busy);
    _streamStartedAtMs = DateTime.now().millisecondsSinceEpoch;
    _stableSuccessFrames = 0;
    await cameraService.startStream((CameraImage imageFromFrame) async {
      try {
        if (cameraService.controller == null ||
            !cameraService.controller!.value.isInitialized) {
          developer_log.log(
            'controller bị null hoặc controller chưa được stream',
            name: 'CameraViewModel.startProcess',
          );
          return false;
        }

        final ui.Size? previewSize =
            cameraService.controller!.value.previewSize;

        if (previewSize == null) {
          developer_log.log(
            'preview Size null',
            name: 'CameraViewModel.startProcess',
          );
          return false;
        }

        ProcessImageResult? result = await detectAndRecognizerText
            .detectObjectAndReadTextFromInputImage(
              cameraService: cameraService,
              imageFromFrame: imageFromFrame,
              globalProvider: globalProvider,
              previewSize: previewSize,
            );

        if (result == null) {
          developer_log.log(
            'kết quả null thực hiện lại',
            name: 'CameraViewModel.startProcess',
          );
          return false;
        }

        bool check = await processCaseResult
            .handleProcessResult<ProcessImageResult>(result: result);
        developer_log.log(
          'Kết qủa sau check $check',
          name: 'CameraViewModel.startProcess',
        );
        if (check) {
          final int currentMs = DateTime.now().millisecondsSinceEpoch;
          final bool isPastWarmup =
              currentMs - _streamStartedAtMs >= _startupWarmupMs;
          _stableSuccessFrames++;

          if (!isPastWarmup ||
              _stableSuccessFrames < _requiredStableSuccessFrames) {
            developer_log.log(
              'Bỏ qua kết quả sớm để ổn định scan: warmup=$isPastWarmup successFrames=$_stableSuccessFrames',
              name: 'CameraViewModel.startProcess',
            );
            return false;
          }

          globalProvider.speakQueue(result.textDetect.toString());
          developer_log.log(
            'đoọc được ${result.textDetect}',
            name: 'CameraViewModel.startProcess',
          );
          getIt<NavigatorService>().pushNamedAndRemoveUntil(
            ReadingResultFeatures.routeName,
            arguments: result.textDetect,
          );
          return true;
        } else {
          _stableSuccessFrames = 0;
          switch (result.status) {
            case ProcessStatus.blur:
              if (processCaseResult.shouldHandleBlurRecovery()) {
                String command = (result.command?.isNotEmpty == true)
                    ? result.command!
                    : 'Ảnh mờ vui lòng giữ yên tay';
                globalProvider.speakQueue(command);

                developer_log.log('báo ảnh mở', name: 'Camera view model');

                globalProvider.speakQueue(
                  "Đang tự động lấy nét!, giữ điện thoại đứng yên",
                );
                await cameraService.refocus();
                processCaseResult.markBlurRecoveryHandled();
              }
              break;
            case ProcessStatus.recapture:
              if (processCaseResult.shouldHandleRecaptureRecovery()) {
                String command = (result.command?.isNotEmpty == true)
                    ? result.command!
                    :   'Đang chụp lại ảnh vui lòng giữ yên tay';
                globalProvider.speakQueue(command);
                developer_log.log('nhận diện', name: 'Camera view model');
                processCaseResult.markRecaptureRecoveryHandled();
              }
              break;
            case ProcessStatus.error:
              developer_log.log('lỗi', name: 'Camera view model');
              break;
            case ProcessStatus.ok:
              break;
          }
          return false;
        }
      } catch (e) {
        developer_log.log('Lỗi: $e', name: 'CameraView model scan');
        rethrow;
      }
    });
  }

  @override
  void dispose() {
    try {
      if (cameraService.controller != null &&
          cameraService.controller!.value.isStreamingImages) {
        cameraService.controller!.stopImageStream();
      }
    } catch (e) {
      developer_log.log(
        'Lỗi khi hủy view_models: $e',
        name: 'CameraViewModel.dispose',
      );
    }

    detectAndRecognizerText.dispose();
    detectAndRecognizerText.setInitialized(false);
    super.dispose();
  }
}
