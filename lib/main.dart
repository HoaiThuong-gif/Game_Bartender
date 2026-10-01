import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const NhomBarApp());
}

class NhomBarApp extends StatelessWidget {
  const NhomBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nhóm Bar',
      home: const HomeScreen(),
    );
  }
}