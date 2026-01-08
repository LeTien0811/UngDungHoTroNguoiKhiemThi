import 'package:flutter/material.dart';
import 'package:hotronguoikhiemthi_app/screen/camera_screen.dart';
import 'package:camera/camera.dart';
import 'package:hotronguoikhiemthi_app/provider/app_state_manager.dart';
import 'package:hotronguoikhiemthi_app/screen/home_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppStateManager())
    ],
    child: MainApp(camera: firstCamera),
  ));
}
class MainApp extends StatefulWidget {
  final CameraDescription camera;

  const MainApp({
    super.key,
    required this.camera,
  });


  @override
  State<MainApp> createState() => _MainApp();
}

class _MainApp extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home:  HomeScreen(camera: widget.camera)
    );
  }
}
