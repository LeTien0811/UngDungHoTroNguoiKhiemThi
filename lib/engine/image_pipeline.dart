import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

Uint8List processFrameIsolate(Map<String, dynamic> args) {
  final cameraBytes = args['bytes'] as Uint8List;
  final width = args['width'] as int;
  final height = args['height'] as int;

  final bridge = NativeBridge();
  return bridge.processImage(cameraBytes, width, height);
}

class NativeBridge {
  late DynamicLibrary _lib;
  // thêm tham số Pointer<Int32> để hứng kích thước ảnh trả về
  late Pointer<Uint8> Function(Pointer<Uint8>, int, int, Pointer<Int32>) _preprocess;
  late void Function(Pointer<NativeType>) _freeMem;

  NativeBridge() {
    _lib = DynamicLibrary.open('libimage_optimizer.so');

    _preprocess = _lib
        .lookup<NativeFunction<Pointer<Uint8> Function(Pointer<Uint8>, Int32, Int32, Pointer<Int32>)>>('preprocess_frame')
        .asFunction();

    _freeMem = _lib
        .lookup<NativeFunction<Void Function(Pointer<NativeType>)>>('free_memory')
        .asFunction();
  }

  Uint8List processImage(Uint8List cameraBytes, int width, int height) {
    // cấp phát RAM cho ảnh gốc & Biến hứng size
    final Pointer<Uint8> ptr = calloc<Uint8>(cameraBytes.length);
    ptr.asTypedList(cameraBytes.length).setAll(0, cameraBytes);

    final Pointer<Int32> outSizePtr = calloc<Int32>(); // biến hứng kích thước mảng mới

    // xuống C++ xử lý
    final Pointer<Uint8> resultPtr = _preprocess(ptr, width, height, outSizePtr);

    // lấy kích thước thực tế do C++ tính toán (tránh lỗi out of bounds)
    final int resultSize = outSizePtr.value;

    // copy kết quả ra List của Dart
    final Uint8List resultList = Uint8List.fromList(resultPtr.asTypedList(resultSize));

    // dỌN RÁC
    calloc.free(ptr);
    calloc.free(outSizePtr); // xóa luôn biến hứng size
    _freeMem(resultPtr);

    return resultList;
  }

}
