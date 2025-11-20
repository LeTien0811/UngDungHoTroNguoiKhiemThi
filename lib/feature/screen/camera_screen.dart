import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    // Đăng ký observer để theo dõi vòng đời app
    WidgetsBinding.instance.addObserver(this);
    // Khởi tạo camera lần đầu
    _initializeCamera();
  }

  @override
  void dispose() {
    // Gỡ bỏ observer trước khi dispose
    WidgetsBinding.instance.removeObserver(this);
    // Giải phóng tài nguyên camera
    _disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // Kiểm tra controller có tồn tại không
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.paused:
        // App chuyển sang background - tắt camera để tiết kiệm pin
        print('App paused - Disposing camera');
        _disposeCamera();
        break;

      case AppLifecycleState.resumed:
        // App quay lại foreground - khởi động lại camera
        print('App resumed - Reinitializing camera');
        _initializeCamera();
        break;

      case AppLifecycleState.inactive:
        // App tạm ngừng (có cuộc gọi đến, kéo notification)
        // Không làm gì, giữ camera hoạt động
        print('App inactive');
        break;

      case AppLifecycleState.detached:
        // App sắp bị đóng hoàn toàn
        print('App detached');
        _disposeCamera();
        break;

      case AppLifecycleState.hidden:
        // App bị ẩn (Flutter 3.13+)
        print('App hidden');
        break;
    }
  }

  /// Khởi tạo camera
  Future<void> _initializeCamera() async {
    try {
      // Tạo controller mới
      _controller = CameraController(
        widget.camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Khởi tạo controller
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      // Cập nhật trạng thái
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }

      print('Camera initialized successfully');
    } on CameraException catch (e) {
      _handleCameraException(e);
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  /// Giải phóng tài nguyên camera
  Future<void> _disposeCamera() async {
    if (_controller != null) {
      try {
        await _controller!.dispose();
        _controller = null;
        _isCameraInitialized = false;
        print('Camera disposed successfully');
      } catch (e) {
        print('Error disposing camera: $e');
      }
    }
  }

  /// Xử lý các lỗi camera
  void _handleCameraException(CameraException e) {
    String errorMessage = '';

    switch (e.code) {
      case 'CameraAccessDenied':
        errorMessage = 'Người dùng từ chối quyền truy cập camera';
        break;
      case 'CameraAccessDeniedWithoutPrompt':
        errorMessage = 'Quyền camera đã bị từ chối trước đó. Vui lòng vào Cài đặt để bật lại';
        break;
      case 'CameraAccessRestricted':
        errorMessage = 'Truy cập camera bị hạn chế (kiểm soát của phụ huynh)';
        break;
      case 'AudioAccessDenied':
        errorMessage = 'Người dùng từ chối quyền truy cập microphone';
        break;
      case 'AudioAccessDeniedWithoutPrompt':
        errorMessage = 'Quyền microphone đã bị từ chối trước đó. Vui lòng vào Cài đặt để bật lại';
        break;
      case 'AudioAccessRestricted':
        errorMessage = 'Truy cập microphone bị hạn chế (kiểm soát của phụ huynh)';
        break;
      default:
        errorMessage = 'Lỗi camera: ${e.description}';
    }

    print('Camera Exception: ${e.code} - $errorMessage');

    // Hiển thị thông báo lỗi cho người dùng
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Đóng',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  /// Chụp ảnh
  Future<XFile?> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Camera chưa được khởi tạo');
      return null;
    }

    if (_controller!.value.isTakingPicture) {
      print('Đang chụp ảnh...');
      return null;
    }

    try {
      final XFile image = await _controller!.takePicture();
      print('Đã chụp ảnh: ${image.path}');
      return image;
    } on CameraException catch (e) {
      _handleCameraException(e);
      return null;
    }
  }

  /// Bật/tắt flash
  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final currentFlashMode = _controller!.value.flashMode;
      final newFlashMode = currentFlashMode == FlashMode.off 
          ? FlashMode.auto 
          : FlashMode.off;
      
      await _controller!.setFlashMode(newFlashMode);
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Lỗi khi thay đổi flash: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera với Quản lý Vòng đời'),
        backgroundColor: Colors.black,
      ),
      body: _isCameraInitialized
          ? _buildCameraPreview()
          : _buildLoadingScreen(),
    );
  }

  /// Xây dựng màn hình camera
  Widget _buildCameraPreview() {
    return Stack(
      children: [
        // Camera preview
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.previewSize!.height,
              height: _controller!.value.previewSize!.width,
              child: CameraPreview(_controller!),
            ),
          ),
        ),

        // Các nút điều khiển
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Nút flash
              IconButton(
                onPressed: _toggleFlash,
                icon: Icon(
                  _controller!.value.flashMode == FlashMode.off
                      ? Icons.flash_off
                      : Icons.flash_auto,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              // Nút chụp ảnh
              GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Nút đổi camera (nếu có nhiều camera)
              IconButton(
                onPressed: () {
                  // Implement switch camera
                },
                icon: Icon(
                  Icons.flip_camera_ios,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),

        // Thông tin trạng thái (debug)
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Camera: ${_isCameraInitialized ? "Hoạt động" : "Tắt"}',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  'Flash: ${_controller?.value.flashMode.toString().split('.').last ?? "N/A"}',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Màn hình loading
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Đang khởi tạo camera...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}