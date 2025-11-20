import 'package:flutter/material.dart';
import 'package:hotronguoikhiemthi_app/feature/screen/home_screen.dart';
import 'package:hotronguoikhiemthi_app/state_services/app_state_manager.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppStateManager())
    ],
    child: const MainApp(),
    ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: const HomeScreen(),
        ),
      ),
    );
  }
}
