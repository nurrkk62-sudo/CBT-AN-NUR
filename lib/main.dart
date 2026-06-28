import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'pages/login_page.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint("ERROR CAMERA: $e");
    cameras = [];
  }

  runApp(const CBTApp());
}

class CBTApp extends StatelessWidget {
  const CBTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CBT AN-NUR',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D5C34),
          primary: const Color(0xFF0D5C34),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: LoginPage(cameras: cameras),
    );
  }
}