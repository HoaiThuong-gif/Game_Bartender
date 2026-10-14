import 'package:flutter/material.dart';

/// Scoped to Rubik routes so other games retain their own styling.
class RubikTheme extends StatelessWidget {
  const RubikTheme({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1670D2));
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF3F5FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF3F5FA),
          foregroundColor: Color(0xFF17233D),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xFF17233D),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1670D2),
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            shape: shape,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF24466F),
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            shape: shape,
          ),
        ),
      ),
      child: child,
    );
  }
}

class RubikModeTile extends StatelessWidget {
  const RubikModeTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.primary = false,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) => Material(
    color: primary ? const Color(0xFF1670D2) : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(
        color: primary ? Colors.transparent : const Color(0xFFDCE3ED),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: primary ? Colors.white : const Color(0xFF1670D2),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: primary ? Colors.white : const Color(0xFF17233D),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: primary
                            ? Colors.white70
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: primary ? Colors.white : const Color(0xFF64748B),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Help is a separate route; the game and its controllers stay mounted.
Future<void> showRubikHelp(BuildContext context, String text) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Cách sử dụng',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng hướng dẫn',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(text, style: const TextStyle(fontSize: 15, height: 1.5)),
            ],
          ),
        ),
      ),
    );
