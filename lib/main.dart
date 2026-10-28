
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Object3DScannerApp());
}

class Object3DScannerApp extends StatelessWidget {
  const Object3DScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '3D Object Scanner',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.tealAccent,
        scaffoldBackgroundColor: const Color(0xFF101418),
      ),
      home: const HomeScreen(),
    );
  }
}
