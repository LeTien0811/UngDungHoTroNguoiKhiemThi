import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:build_access/config/open_cv.dart';
import 'package:build_access/core/base/base_service.dart';
import 'package:build_access/core/image/opencv_vision_algorithm.dart';
import 'package:build_access/core/isolate/isolate_messages.dart';
import 'package:build_access/core/isolate/long_live_worker.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'dart:developer' as developer_log;

class OcrPreprocessor extends BaseService {
  @override
  String get serviceName => 'OcrPreprocessor';

  late final LongLivedWorker<void, OpenCVPayload, OpenCVResult> _worker;

  OcrPreprocessor() {
    _worker = LongLivedWorker<void, OpenCVPayload, OpenCVResult>(_openCVTask);
  }

  @override
  Future<void> init() async {
    if (isInitialized) return;
    _worker.init(null);
    setInitialized(true);
  }

  static void _openCVTask(WorkerInit<void> setup) async {
    final workerReceivePort = ReceivePort();
    setup.sendPort.send(workerReceivePort.sendPort);

    await for (var message in workerReceivePort) {
      if (message == 'SHUTDOWN_NOW') {
        workerReceivePort.close();
        return;
      }

      if (message is WorkerTask<OpenCVPayload>) {
        final payload = message.data;

        cv.Mat? currentMat;
        cv.Mat? tempMat;

        try {
          currentMat = cv.Mat.fromList(
              payload.h,
              payload.stride,
              cv.MatType.CV_8UC1,
              payload.bytes
          );

          if (payload.cx != null && payload.cy != null && payload.cw != null && payload.ch != null) {
            // AI-added: Crop chỉ chạy đúng một lần bằng tọa độ chuẩn hóa để
            // loại bỏ lỗi cắt lệch khi vùng crop bị áp lại trên ảnh đã crop.
            tempMat = OpenCVVisionAlgorithm.safeCrop(
                currentMat, payload.cx!, payload.cy!, payload.cw!, payload.ch!, 0.05
            );
            currentMat.dispose();
            currentMat = tempMat;
            tempMat = null;
          }

          tempMat = OpenCVVisionAlgorithm.prepareImageForOcr(currentMat);
          currentMat.dispose();
          currentMat = tempMat;
          tempMat = null;

          final Uint8List nv21ReadyBytes = OpenCVVisionAlgorithm.packToNV21Bytes(currentMat);

          final int outW = currentMat.cols;
          final int outH = currentMat.rows;
          Uint8List debugBytes = Uint8List(0);

          final (success, encoded) = cv.imencode(".jpg", currentMat);
          if (success) {
            debugBytes = encoded;
          }

          message.replyPort.send(
            OpenCVResult(nv21ReadyBytes, debugBytes, outW, outH),
          );
        } catch (e) {
          developer_log.log('Lỗi OpenCV Worker: $e', name: 'WORKER_OPENCV');
          message.replyPort.send(null);
        } finally {
          if (tempMat != null) {
            tempMat.dispose();
          }
          if (currentMat != null) {
            currentMat.dispose();
          }
        }
      }
    }
  }

  Future<dynamic> processImage(
    Uint8List bytes,
    int w,
    int h, {
    int? stride,
    Map<String, double>? crop,
  }) async {
    if (!isInitialized) return Future.value(Uint8List(0));

    final payLoad = OpenCVPayload(
      bytes,
      w,
      h,
      stride ?? w,
      cx: crop?['x'],
      cy: crop?['y'],
      cw: crop?['w'],
      ch: crop?['h'],
    );

    final result = await _worker.execute(payLoad);

    if (result == null) return Future.value(Uint8List(0));

    return {
      'ocrBytes': result.ocrBytes,
      'debugBytes': result.debugBytes,
      'outW': result.outW,
      'outH': result.outH,
    };
  }

  @override
  Future<void> dispose() async {
    setInitialized(false);
    _worker.dispose();
    super.dispose();
  }
}
