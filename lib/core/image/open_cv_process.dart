import 'dart:developer' as developer_log;
import 'package:opencv_dart/opencv_dart.dart' as cv;

class OpenCVProcess {
  static const int targetLongEdge = 1280;

  // AI-added: Ảnh crop từ camera thường nhỏ, tương phản thấp và hơi nghiêng.
  // Hàm này tăng độ đọc được của chữ trước OCR nhưng vẫn giữ ảnh grayscale
  // để ML Kit không bị mất quá nhiều chi tiết như khi nhị phân hóa quá mạnh.
  static cv.Mat prepareImageForOcr(cv.Mat input) {
    cv.Mat working = input.clone();
    try {
      final int longEdge = working.cols > working.rows
          ? working.cols
          : working.rows;
      if (longEdge < targetLongEdge) {
        final double scale = targetLongEdge / longEdge;
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

      //final cv.Mat deskewed = _deskewDocumentRegion(working);
      //working.dispose();
      return working;
    } catch (e) {
      developer_log.log('Xử lý OCR thất bại: $e', name: 'WORKER_OPENCV');
      working.dispose();
      return input.clone();
    }
  }

  // AI-added: Dùng contour lớn nhất của vùng chữ sau adaptive threshold để
  // ước lượng góc nghiêng của nhãn. Chỉ sửa góc nhỏ-vừa để tránh xoay sai mạnh.
  static cv.Mat deskewDocumentRegion(cv.Mat source) {
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
}
