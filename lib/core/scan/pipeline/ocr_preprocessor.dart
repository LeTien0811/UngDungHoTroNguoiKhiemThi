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
        final Uint8List bytes = payload.bytes;
        final int w = payload.w;
        final int h = payload.h;
        final int? cx = payload.cx;
        final int? cy = payload.cy;
        final int? cw = payload.cw;
        final int? ch = payload.ch;
        final int stride = payload.stride;

        cv.Mat? mat = cv.Mat.fromList(h, stride, cv.MatType.CV_8UC1, bytes);
        try {
          final matReal = mat.colRange(0, w).clone();
          mat.dispose();
          mat = matReal;

          if (cx != null && cy != null && cw != null && ch != null) {
            developer_log.log('crop: $cx, $cy, $cw, $ch');
            final cropped = OpenCVVisionAlgorithm.safeCrop(mat, cx, cy, cw, ch, 0.15);
            mat.dispose();
            mat = cropped;
          }

          final cv.Mat processed = OpenCVVisionAlgorithm.prepareImageForOcr(mat);
          mat.dispose();
          mat = processed;

          final Uint8List nv21ReadyBytes = OpenCVVisionAlgorithm.packToNV21Bytes(mat);

          final int outW = mat.cols;
          final int outH = mat.rows;
          Uint8List debugBytes = Uint8List(0);

          final (success, encoded) = cv.imencode(".jpg", mat);
          if (success) debugBytes = encoded;

          mat.dispose();

          message.replyPort.send(
            OpenCVResult(nv21ReadyBytes, debugBytes, outW, outH),
          );
        } catch (e) {
          developer_log.log('Loi OpenCV: $e', name: 'WORKER_OPENCV');
          message.replyPort.send(null);
        } finally {
          mat?.dispose();
        }
      }
    }
  }

  Future<dynamic> processImage(
    Uint8List bytes,
    int w,
    int h, {
    int? stride,
    Map<String, int>? crop,
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
