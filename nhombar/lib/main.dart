import 'package:flutter/material.dart';

import 'screens/home/home_screen.dart';
import 'settings/app_settings.dart';
import 'settings/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NhomBarApp());
}

class NhomBarApp extends StatefulWidget {
  const NhomBarApp({super.key, this.settings, this.home});
  final AppSettings? settings;
  final Widget? home;
  @override
  State<NhomBarApp> createState() => _NhomBarAppState();
}

class _NhomBarAppState extends State<NhomBarApp> {
  late final AppSettings _settings = widget.settings ?? AppSettings();
  @override
  void initState() {
    super.initState();
    if (widget.settings == null) _settings.useAccount(null);
  }

  @override
  void dispose() {
    if (widget.settings == null) _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: _settings,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nhóm Bar',
          theme: AppTheme.build(_settings.seedColor),
          themeAnimationDuration: _settings.reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 180),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: AppTextScaler(
                  media.textScaler,
                  _settings.textScale,
                ),
                disableAnimations:
                    media.disableAnimations || _settings.reduceMotion,
              ),
              child: child!,
            );
          },
          home: widget.home ?? const HomeScreen(),
        ),
      ),
    );
  }
}
