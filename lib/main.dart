import 'package:flutter/material.dart';
import 'package:hotronguoikhiemthi_app/provider/app_state_manager.dart';
import 'package:hotronguoikhiemthi_app/screen/home_screen.dart';
import 'package:hotronguoikhiemthi_app/storage/storage_handle.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageHandle().init();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppStateManager())],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {

  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainApp();
}

class _MainApp extends State<MainApp> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
