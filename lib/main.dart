import 'package:flutter/material.dart';

import 'screens/home/home_screen.dart';
import 'shared/services/retired_feature_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await removeRetiredFeatureStorage();
  } catch (error) {
    // Retry on the next launch if local storage is temporarily unavailable.
    debugPrint('Could not clean retired inventory data: $error');
  }
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
