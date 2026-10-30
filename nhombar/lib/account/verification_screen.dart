import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'account_security.dart';
import 'account_validation.dart';

class AccountVerificationGate extends StatefulWidget {
  const AccountVerificationGate({
    super.key,
    required this.security,
    required this.child,
  });
  final AccountSecurity security;
  final Widget child;
  @override
  State<AccountVerificationGate> createState() =>
      _AccountVerificationGateState();
}

class _AccountVerificationGateState extends State<AccountVerificationGate> {
  final _code = TextEditingController();
  bool _ready = false, _busy = true;
  String? _error, _challenge, _email;
  int _retryAt = 0, _expiresAt = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final claims = await widget.security.auth.currentUser!.getIdTokenResult();
      if (claims.claims?['account_session'] != null) {
        await widget.security.request('session');
        if (mounted) setState(() => _ready = true);
      }
    } catch (error) {
      if (mounted) setState(() => _error = accountError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _run(Future<void> Function() task) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await task();
    } catch (error) {
      if (mounted) setState(() => _error = accountError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send() async {
    final result = await widget.security.request('challenge', body: {});
    if (!mounted) return;
    setState(() {
      _challenge = result['challengeId'] as String;
      _email = result['email'] as String;
      _retryAt = result['retryAt'] as int;
      _expiresAt = result['expiresAt'] as int;
      _code.clear();
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _verify() async {
    if (_challenge == null || !RegExp(r'^\d{6}$').hasMatch(_code.text)) {
      throw const AccountSecurityError('Nhập đủ 6 chữ số trong email.');
    }
    await widget.security.verify(_challenge!, _code.text);
    if (mounted) setState(() => _ready = true);
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.child;
    final now = DateTime.now().millisecondsSinceEpoch;
    final wait = ((_retryAt - now) / 1000).ceil().clamp(0, 60);
    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực tài khoản')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.mark_email_read_outlined, size: 64),
                const SizedBox(height: 20),
                Text(
                  _email == null
                      ? 'Xác thực email để vào Lobby.'
                      : 'Nhập mã gửi tới $_email',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_challenge != null) ...[
                  TextField(
                    controller: _code,
                    enabled: !_busy,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Mã OTP'),
                  ),
                  if (now >= _expiresAt)
                    const Text('Mã đã hết hạn. Hãy gửi lại mã.'),
                  FilledButton(
                    onPressed: _busy ? null : () => _run(_verify),
                    child: const Text('Xác nhận'),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _busy || wait > 0 ? null : () => _run(_send),
                  child: Text(
                    wait > 0
                        ? 'Gửi lại sau $wait giây'
                        : _challenge == null
                        ? 'Gửi mã email'
                        : 'Gửi lại mã',
                  ),
                ),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: LinearProgressIndicator(),
                  ),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() async {
                          try {
                            if (_challenge != null) {
                              await widget.security.request(
                                'cancel',
                                body: {'challengeId': _challenge},
                              );
                            }
                          } finally {
                            await widget.security.signOut();
                          }
                        }),
                  child: const Text('Hủy và quay lại đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
