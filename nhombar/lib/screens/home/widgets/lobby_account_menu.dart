import 'package:flutter/material.dart';

enum LobbyAccountAction { profile, settings, appearance, layout, logout }

class LobbyAccountButton extends StatelessWidget {
  const LobbyAccountButton({
    super.key,
    required this.name,
    this.photoUrl,
    required this.onPressed,
  });
  final String name;
  final String? photoUrl;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: (MediaQuery.sizeOf(context).width * .6).clamp(120, 240),
      ),
      child: Material(
        color: colors.surface,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Tooltip(
          message: 'Menu tài khoản',
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlayerAvatar(name: name, photoUrl: photoUrl, radius: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge!
                          .copyWith(color: colors.onSurface),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.expand_more, size: 18, color: colors.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 28,
  });
  final String name;
  final String? photoUrl;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final url = photoUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primaryContainer,
      child: ClipOval(
        child: url == null || url.isEmpty
            ? Icon(
                Icons.person_rounded,
                color: colors.onPrimaryContainer,
                size: radius * 1.2,
              )
            : Image.network(
                url,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.person_rounded,
                  color: colors.onPrimaryContainer,
                  size: radius * 1.2,
                ),
              ),
      ),
    );
  }
}

Future<LobbyAccountAction?> showLobbyAccountMenu(
  BuildContext context, {
  required String name,
  String? photoUrl,
  required bool canLogout,
}) => showModalBottomSheet<LobbyAccountAction>(
  context: context,
  isScrollControlled: true,
  sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
      ? AnimationStyle.noAnimation
      : null,
  useSafeArea: true,
  constraints: const BoxConstraints(maxWidth: 520),
  builder: (context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .85,
    ),
    child: SingleChildScrollView(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  PlayerAvatar(name: name, photoUrl: photoUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Text('Tài khoản của bạn'),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng menu',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              for (final entry in const [
                (
                  LobbyAccountAction.profile,
                  Icons.person_outline,
                  'Hồ sơ cá nhân',
                ),
                (
                  LobbyAccountAction.settings,
                  Icons.settings_outlined,
                  'Cài đặt',
                ),
                (
                  LobbyAccountAction.appearance,
                  Icons.palette_outlined,
                  'Giao diện',
                ),
                (
                  LobbyAccountAction.layout,
                  Icons.dashboard_customize_outlined,
                  'Chỉnh bố cục Lobby',
                ),
              ])
                ListTile(
                  leading: Icon(
                    entry.$2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(entry.$3),
                  trailing: const Icon(Icons.chevron_right),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onTap: () => Navigator.pop(context, entry.$1),
                ),
              if (canLogout) ...[
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () =>
                      Navigator.pop(context, LobbyAccountAction.logout),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  ),
);
