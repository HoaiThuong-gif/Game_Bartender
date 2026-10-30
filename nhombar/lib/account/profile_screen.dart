import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart' show compute;

import 'account_service.dart';
import 'account_validation.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user, required this.accounts});
  final User user;
  final AccountService accounts;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profiles = PlayerProfiles();
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  Uint8List? _avatar;
  bool _busy = false, _editing = false;
  String? _message;
  late Future<void> _ready;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _profile;
  @override
  void initState() {
    super.initState();
    _ready = _profiles.ensure(widget.user);
    _profile = _profiles
        .reference(widget.user.uid)
        .snapshots(includeMetadataChanges: true);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
      if (mounted && success.isNotEmpty) setState(() => _message = success);
    } catch (error) {
      debugPrint('[Profile] ${error.runtimeType}');
      if (mounted) setState(() => _message = accountError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickAvatar() async {
    await _run(() async {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
        requestFullMetadata: false,
      );
      if (image == null) return;
      final bytes = await compute(_avatarJpeg, await image.readAsBytes());
      if (!mounted) return;
      if (bytes.length > 2 * 1024 * 1024) {
        setState(() => _message = 'Ảnh quá lớn. Hãy chọn ảnh nhỏ hơn 2 MB.');
        return;
      }
      setState(() {
        _avatar = bytes;
        _editing = true;
      });
    }, '');
  }

  Future<void> _passwordDialog() async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final form = GlobalKey<FormState>();
    final value = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: current,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu hiện tại',
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nhập mật khẩu hiện tại.'
                      : null,
                ),
                TextFormField(
                  controller: next,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                  validator: validatePassword,
                ),
                TextFormField(
                  controller: confirm,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nhập lại mật khẩu mới',
                  ),
                  validator: (value) => value == next.text
                      ? null
                      : 'Hai mật khẩu chưa giống nhau.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, (current.text, next.text));
              }
            },
            child: const Text('Đổi mật khẩu'),
          ),
        ],
      ),
    );
    // Wait for the closing route animation before disposing its controllers.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    current.dispose();
    next.dispose();
    confirm.dispose();
    if (value != null && mounted) {
      await _run(
        () => _profiles.changePassword(widget.user, value.$1, value.$2),
        'Đã đổi mật khẩu.',
      );
    }
  }

  Widget _failure() => Column(
    children: [
      const Text(
        'Chưa tải được hồ sơ. Hãy kiểm tra mạng hoặc báo người quản lý.',
      ),
      TextButton(
        onPressed: () => setState(() {
          _ready = _profiles.ensure(widget.user);
        }),
        child: const Text('Thử lại'),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Hồ sơ của tôi')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Thông tin của bạn',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text('Cập nhật tên và ảnh để bạn bè dễ nhận ra bạn.'),
        const SizedBox(height: 24),
        FutureBuilder<void>(
          future: _ready,
          builder: (context, ready) {
            if (ready.hasError) return _failure();
            if (ready.connectionState != ConnectionState.done) {
              return const LinearProgressIndicator();
            }
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _profile,
              builder: (context, snapshot) {
                if (snapshot.hasError) return _failure();
                if (!snapshot.hasData) return const LinearProgressIndicator();
                final data = snapshot.data!.data() ?? {};
                if (!_editing) {
                  _name.text = data['displayName'] as String? ?? 'Người chơi';
                }
                final url = data['photoURL'] as String? ?? '';
                final created = data['createdAt'];
                final date = created is Timestamp
                    ? created.toDate()
                    : widget.user.metadata.creationTime;
                return Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 44,
                          foregroundImage: _avatar != null
                              ? MemoryImage(_avatar!)
                              : (url.isEmpty ? null : NetworkImage(url)),
                          onForegroundImageError:
                              _avatar != null || url.isNotEmpty
                              ? (_, _) {}
                              : null,
                          child: const Icon(Icons.person, size: 44),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _busy ? null : _pickAvatar,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Đổi ảnh đại diện'),
                      ),
                      TextFormField(
                        controller: _name,
                        enabled: !_busy,
                        validator: validatePlayerName,
                        onChanged: (_) => _editing = true,
                        decoration: const InputDecoration(
                          labelText: 'Tên hiển thị',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        widget.user.email ?? data['email'] as String? ?? '',
                      ),
                      SelectableText('UID: ${widget.user.uid}'),
                      SelectableText(
                        'Game ID: ${data['gameId'] ?? 'Đang cấp ID…'}',
                      ),
                      if (snapshot.data!.metadata.hasPendingWrites)
                        const Text('Thay đổi đang chờ đồng bộ…'),
                      if (date != null)
                        Text(
                          'Tham gia: ${date.day}/${date.month}/${date.year}',
                        ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _busy
                            ? null
                            : () {
                                if (!_form.currentState!.validate()) return;
                                _run(() async {
                                  await _profiles.save(
                                    widget.user,
                                    _name.text,
                                    avatar: _avatar,
                                  );
                                  if (mounted) {
                                    setState(() {
                                      _avatar = null;
                                      _editing = false;
                                    });
                                  }
                                }, 'Đã lưu hồ sơ.');
                              },
                        child: const Text('Lưu thay đổi'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              if (widget.accounts is FirebaseAccountService)
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('Đăng nhập sinh trắc học'),
                  subtitle: const Text(
                    'Bật sau khi xác thực OTP trên điện thoại này',
                  ),
                  onTap: () => _run(() async {
                    final security =
                        (widget.accounts as FirebaseAccountService).security;
                    if (await security.biometricEnabled) {
                      await security.disableBiometrics();
                    } else {
                      await security.enableBiometrics();
                    }
                  }, 'Đã cập nhật đăng nhập sinh trắc học.'),
                ),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Giao diện'),
                subtitle: const Text('Chọn màu chủ đạo và cỡ chữ'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AppearanceScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Cài đặt'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_busy) const LinearProgressIndicator(),
        if (_message != null)
          Padding(padding: const EdgeInsets.all(12), child: Text(_message!)),
        if (widget.user.providerData.any(
          (provider) => provider.providerId == 'password',
        ))
          OutlinedButton(
            onPressed: _busy ? null : _passwordDialog,
            child: const Text('Đổi mật khẩu'),
          )
        else
          const Text('Mật khẩu được quản lý bởi tài khoản Google của bạn.'),
        TextButton.icon(
          onPressed: _busy ? null : () => _run(widget.accounts.logout, ''),
          icon: const Icon(Icons.logout),
          label: const Text('Đăng xuất'),
        ),
      ],
    ),
  );
}

Uint8List _avatarJpeg(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('Invalid image');
  return img.encodeJpg(img.bakeOrientation(decoded), quality: 80);
}
