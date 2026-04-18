import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:build_access/core/base/base_service.dart';
import 'package:build_access/config/image_worker_request.dart';
import 'package:build_access/enum/config.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'dart:developer' as developer_log;

class HandleImageWorkerService extends BaseService {
  // AI-added: Chuẩn hóa một pipeline tiền xử lý nhẹ nhưng hữu ích cho OCR:
  // crop đúng vùng, upscale ảnh nhỏ, tăng tương phản cục bộ, làm sắc,
  // rồi deskew nhẹ để nhãn bớt nghiêng trước khi đưa sang ML Kit.
  static const int _targetLongEdge = 1280;

  @override
  String get serviceName => 'HandleImageWorkerService';

  Isolate? _isolate;
  SendPort? _sendToIsolatePort;
  final _receiveFromIsolatePort = ReceivePort();
  ImageWorkerRequest? _nextRequest;

  bool _shouldStopLoop = false;

  @override
  Future<void> init() async {
    if (isInitialized) return;
    _shouldStopLoop = false;

    _isolate = await Isolate.spawn(
      _persistentEntry,
      _receiveFromIsolatePort.sendPort,
    );
    _sendToIsolatePort = await _receiveFromIsolatePort.first;
    _startOrchestrationLoop();
    setInitialized(true);
  }

  static void _persistentEntry(SendPort mainSendPort) async {
    final workerReceivePort = ReceivePort();
    mainSendPort.send(workerReceivePort.sendPort);

    await for (var message in workerReceivePort) {
      if (message == 'SHUTDOWN_NOW') {
        workerReceivePort.close();
        return;
      }

      if (message is Map) {
        final SendPort replyPort = message['replyPort'];
        final Uint8List bytes = message['bytes'];
        final int w = message['w'];
        final int h = message['h'];
        final int stride = message['stride'];
        final int? cx = message['cx'];
        final int? cy = message['cy'];
        final int? cw = message['cw'];
        final int? ch = message['ch'];

        cv.Mat? mat = cv.Mat.fromList(h, stride, cv.MatType.CV_8UC1, bytes);
        try {
          final matReal = mat.colRange(0, w).clone();
          mat.dispose();
          mat = matReal;

          if (cx != null && cy != null && cw != null && ch != null) {
            developer_log.log('crop: $cx, $cy, $cw, $ch');
            final rect = cv.Rect(
              cx.clamp(0, w - 1),
              cy.clamp(0, h - 1),
              cw.clamp(1, w - cx),
              ch.clamp(1, h - cy),
            );
            final cropped = mat.region(rect).clone();
            mat.dispose();
            mat = cropped;
          }
          final cv.Mat processed = _prepareImageForOcr(mat);
          mat.dispose();
          mat = processed;

          final Uint8List resultRaw = Uint8List.fromList(mat.data);

          final int outW = mat.cols;
          final int outH = mat.rows;
          Uint8List debugBytes = Uint8List(0);

          final (success, encoded) = cv.imencode(".jpg", mat);
          if (success) debugBytes = encoded;

          mat.dispose();

          replyPort.send({
            'ocrBytes': resultRaw,
            'debugBytes': debugBytes,
            'outW': outW,
            'outH': outH,
          });
        } catch (e) {
          developer_log.log('Loi OpenCV: $e', name: 'WORKER_OPENCV');
          replyPort.send({
            'ocrBytes': Uint8List(0),
            'debugBytes': Uint8List(0),
          });
        } finally {
          mat?.dispose();
        }
      }
    }
  }

  // AI-added: Ảnh crop từ camera thường nhỏ, tương phản thấp và hơi nghiêng.
  // Hàm này tăng độ đọc được của chữ trước OCR nhưng vẫn giữ ảnh grayscale
  // để ML Kit không bị mất quá nhiều chi tiết như khi nhị phân hóa quá mạnh.
  static cv.Mat _prepareImageForOcr(cv.Mat input) {
    cv.Mat working = input.clone();
    try {
      final int longEdge = working.cols > working.rows
          ? working.cols
          : working.rows;
      if (longEdge < _targetLongEdge) {
        final double scale = _targetLongEdge / longEdge;
        final cv.Mat resized = cv.resize(working, (
          (working.cols * scale).round(),
          (working.rows * scale).round(),
        ), interpolation: cv.INTER_CUBIC);
        working.dispose();
        working = resized;
      }

      final cv.CLAHE clahe = cv.createCLAHE(
        clipLimit: 3.5,
        tileGridSize: (8, 8),
      );
      final cv.Mat localContrast = clahe.apply(working);
      clahe.dispose();
      working.dispose();
      working = localContrast;

      final cv.Mat denoised = cv.medianBlur(working, 3);
      working.dispose();
      working = denoised;

      final cv.Mat softBlur = cv.gaussianBlur(working, (3, 3), 0.0);
      final cv.Mat sharpened = cv.addWeighted(
        working,
        1.45,
        softBlur,
        -0.45,
        0.0,
      );
      softBlur.dispose();
      working.dispose();
      working = sharpened;

      // final cv.Mat deskewed = _deskewDocumentRegion(working);
      // working.dispose();
      return working;
    } catch (e) {
      developer_log.log('Xử lý OCR thất bại: $e', name: 'WORKER_OPENCV');
      working.dispose();
      return input.clone();
    }
  }

  // AI-added: Dùng contour lớn nhất của vùng chữ sau adaptive threshold để
  // ước lượng góc nghiêng của nhãn. Chỉ sửa góc nhỏ-vừa để tránh xoay sai mạnh.
  static cv.Mat _deskewDocumentRegion(cv.Mat source) {
    cv.Mat? thresholded;
    cv.Mat? closed;
    cv.Mat? kernel;
    cv.Mat? rotationMatrix;

    try {
      thresholded = cv.adaptiveThreshold(
        source,
        255,
        cv.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv.THRESH_BINARY_INV,
        31,
        12,
      );

      kernel = cv.getStructuringElement(cv.MORPH_RECT, (9, 3));
      closed = cv.morphologyEx(
        thresholded,
        cv.MORPH_CLOSE,
        kernel,
        iterations: 1,
      );

      final (contours, _) = cv.findContours(
        closed,
        cv.RETR_EXTERNAL,
        cv.CHAIN_APPROX_SIMPLE,
      );

      double maxArea = 0;
      cv.VecPoint? bestContour;
      for (int i = 0; i < contours.length; i++) {
        final cv.VecPoint contour = contours[i];
        final double area = cv.contourArea(contour);
        if (area > maxArea) {
          maxArea = area;
          bestContour = contour;
        }
      }

      if (bestContour == null || maxArea < source.rows * source.cols * 0.08) {
        return source.clone();
      }

      final cv.RotatedRect rotatedRect = cv.minAreaRect(bestContour);
      final double width = rotatedRect.size.width;
      final double height = rotatedRect.size.height;

      double angle = rotatedRect.angle;
      if (width < height) {
        angle += 90;
      }

      if (angle.abs() < 2 || angle.abs() > 20) {
        return source.clone();
      }

      rotationMatrix = cv.getRotationMatrix2D(rotatedRect.center, angle, 1.0);
      return cv.warpAffine(
        source,
        rotationMatrix,
        (source.cols, source.rows),
        flags: cv.INTER_CUBIC,
        borderMode: cv.BORDER_CONSTANT,
        borderValue: cv.Scalar.all(255),
      );
    } catch (e) {
      developer_log.log('Deskew OCR thất bại: $e', name: 'WORKER_OPENCV');
      return source.clone();
    } finally {
      thresholded?.dispose();
      closed?.dispose();
      kernel?.dispose();
      rotationMatrix?.dispose();
    }
  }

  void _startOrchestrationLoop() async {
    while (!_shouldStopLoop) {
      if (_nextRequest != null && isProcess == ServiceState.idle) {
        final request = _nextRequest!;
        _nextRequest = null;

        await runSafe(() async {
          final responsePort = ReceivePort();
          _sendToIsolatePort?.send({
            'bytes': request.bytes,
            'w': request.width,
            'h': request.height,
            'stride': request.stride,
            'cx': request.cropX,
            'cy': request.cropY,
            'cw': request.cropW,
            'ch': request.cropH,
            'replyPort': responsePort.sendPort,
          });

          final dynamic result = await responsePort.first.timeout(const Duration(seconds: 2), onTimeout: () => null);
          responsePort.close();

          if (!request.completer.isCompleted) {
            request.completer.complete(result);
          }
        });
      }
      if (!isInitialized) break;

      await Future.delayed(const Duration(milliseconds: 20));
    }

    log('Vòng lặp đã dừng lại');
  }

  Future<dynamic> processImage(
    Uint8List bytes,
    int w,
    int h, {
    int? stride,
    Map<String, int>? crop,
  }) {
    if (!isInitialized) return Future.value(Uint8List(0));

    if (_nextRequest != null && !_nextRequest!.completer.isCompleted) {
      _nextRequest!.completer.complete(Uint8List(0));
    }

    final Uint8List safeBytes = Uint8List.fromList(bytes);

    final completer = Completer<dynamic>();
    _nextRequest = ImageWorkerRequest(
      bytes: safeBytes,
      width: w,
      height: h,
      stride: stride ?? w,
      cropX: crop?['x'],
      cropY: crop?['y'],
      cropW: crop?['w'],
      cropH: crop?['h'],
      completer: completer,
    );

    return completer.future.catchError((e) => Uint8List(0));
  }

  @override
  Future<void> dispose() async {
    _shouldStopLoop = true;
    setInitialized(false);
    try {
      _sendToIsolatePort?.send('SHUTDOWN_NOW');
    } catch (e) {
      log('port đã đóng trước đó: $e');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendToIsolatePort = null;
    super.dispose();
  }
}
