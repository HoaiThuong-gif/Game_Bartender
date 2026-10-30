import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/home/lobby_screen.dart';
import 'account_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'verification_screen.dart';
import '../settings/app_settings.dart';

class AccountGate extends StatefulWidget {
  const AccountGate({super.key, this.initialize, this.lobbyBuilder});
  final Future<AccountService> Function()? initialize;
  final WidgetBuilder? lobbyBuilder;
  @override
  State<AccountGate> createState() => _AccountGateState();
}

class _AccountGateState extends State<AccountGate> {
  late Future<AccountService> _initialization;
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    _initialization =
        (widget.initialize ?? FirebaseAccountService.initialize)();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AccountService>(
    future: _initialization,
    builder: (context, ready) {
      if (ready.hasError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Chưa mở được đăng nhập. Hãy kiểm tra mạng và thử lại.',
                ),
                FilledButton(
                  onPressed: () => setState(_initialize),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        );
      }
      if (!ready.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return _SessionGate(
        service: ready.data!,
        lobbyBuilder: widget.lobbyBuilder,
      );
    },
  );
}

class _SessionGate extends StatefulWidget {
  const _SessionGate({required this.service, this.lobbyBuilder});
  final AccountService service;
  final WidgetBuilder? lobbyBuilder;
  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  late final _changes = widget.service.changes;
  String? _appearanceAccount;
  bool _appearanceLoaded = false;
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: _changes,
    builder: (context, session) {
      if (session.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final user = session.data;
      final uid = user != null && !user.isAnonymous ? user.uid : null;
      if (!_appearanceLoaded || _appearanceAccount != uid) {
        _appearanceLoaded = true;
        _appearanceAccount = uid;
        final settings = AppSettingsScope.maybeOf(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) settings?.useAccount(uid);
        });
      }
      if (session.hasError || user == null || user.isAnonymous) {
        return LoginScreen(service: widget.service);
      }
      // All protected routes live here. Removing this Navigator on sign-out
      // removes Lobby AND any profile/game route above it, including Back access.
      final protected = _ProtectedNavigator(
        key: ValueKey('player-${user.uid}'),
        builder: (context) =>
            widget.lobbyBuilder?.call(context) ??
            _ProfileBootstrap(
              user: user,
              builder: (name, photo) => LobbyScreen(
                playerName: name,
                avatarUrl: photo,
                onLogout: widget.service.logout,
                onAccountTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ProfileScreen(user: user, accounts: widget.service),
                  ),
                ),
              ),
            ),
      );
      final service = widget.service;
      return service is FirebaseAccountService
          ? AccountVerificationGate(
              key: ValueKey('${user.uid}:${service.loginEpoch}'),
              security: service.security,
              child: protected,
            )
          : protected;
    },
  );
}

class _ProtectedNavigator extends StatefulWidget {
  const _ProtectedNavigator({super.key, required this.builder});
  final WidgetBuilder builder;
  @override
  State<_ProtectedNavigator> createState() => _ProtectedNavigatorState();
}

class _ProtectedNavigatorState extends State<_ProtectedNavigator> {
  final _navigator = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) => NavigatorPopHandler<void>(
    onPopWithResult: (_) => _navigator.currentState?.maybePop(),
    child: Navigator(
      key: _navigator,
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: widget.builder),
    ),
  );
}

class _ProfileBootstrap extends StatefulWidget {
  const _ProfileBootstrap({required this.user, required this.builder});
  final User user;
  final Widget Function(String name, String? photo) builder;
  @override
  State<_ProfileBootstrap> createState() => _ProfileBootstrapState();
}

class _ProfileBootstrapState extends State<_ProfileBootstrap> {
  late Future<void> _ready;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _profile;
  @override
  void initState() {
    super.initState();
    _ready = PlayerProfiles().ensure(widget.user);
    _profile = PlayerProfiles().reference(widget.user.uid).snapshots();
  }

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _profile,
        builder: (context, snapshot) {
          final data = snapshot.data?.data();
          final name =
              data?['displayName'] as String? ??
              widget.user.displayName ??
              'Người chơi';
          final photo = data?['photoURL'] as String? ?? widget.user.photoURL;
          return Stack(
            children: [
              widget.builder(name, photo),
              FutureBuilder<void>(
                future: _ready,
                builder: (context, snapshot) => snapshot.hasError
                    ? Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: SafeArea(
                          child: Material(
                            borderRadius: BorderRadius.circular(16),
                            child: ListTile(
                              title: const Text('Chưa đồng bộ được hồ sơ'),
                              trailing: TextButton(
                                onPressed: () => setState(() {
                                  _ready = PlayerProfiles().ensure(widget.user);
                                }),
                                child: const Text('Thử lại'),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      );
}
