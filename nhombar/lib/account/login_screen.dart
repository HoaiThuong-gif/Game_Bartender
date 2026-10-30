import 'package:flutter/material.dart';

import 'account_service.dart';
import 'account_validation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.service});
  final AccountService service;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _name = TextEditingController();
  bool _register = false, _busy = false, _visible = false;
  String? _message;

  @override
  void dispose() {
    for (final controller in [_email, _password, _confirm, _name]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, {String? success}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
      if (mounted) setState(() => _message = success);
    } catch (error) {
      debugPrint('[Account] ${error.runtimeType}');
      if (mounted) setState(() => _message = accountError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    _run(
      () => _register
          ? widget.service.register(_name.text, _email.text, _password.text)
          : widget.service.login(_email.text, _password.text),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AutofillGroup(
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      child: Icon(
                        Icons.pets,
                        size: 44,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _register ? 'Tạo tài khoản' : 'Chào bạn!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Text('Đăng nhập để vào căn phòng của bạn.'),
                    const SizedBox(height: 24),
                    if (_register)
                      TextFormField(
                        controller: _name,
                        enabled: !_busy,
                        decoration: const InputDecoration(
                          labelText: 'Tên của bạn',
                        ),
                        validator: validatePlayerName,
                        autofillHints: const [AutofillHints.nickname],
                      ),
                    if (_register) const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      enabled: !_busy,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      enabled: !_busy,
                      obscureText: !_visible,
                      autofillHints: [
                        _register
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        suffixIcon: IconButton(
                          tooltip: _visible ? 'Ẩn mật khẩu' : 'Hiện mật khẩu',
                          onPressed: () => setState(() => _visible = !_visible),
                          icon: Icon(
                            _visible ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: validatePassword,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_register) const SizedBox(height: 12),
                    if (_register)
                      TextFormField(
                        controller: _confirm,
                        enabled: !_busy,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Nhập lại mật khẩu',
                        ),
                        validator: (value) => value == _password.text
                            ? null
                            : 'Hai mật khẩu chưa giống nhau.',
                      ),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _message!,
                          semanticsLabel: _message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_busy) const LinearProgressIndicator(),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: Text(_register ? 'Đăng ký' : 'Đăng nhập'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _run(widget.service.google),
                      icon: const Icon(Icons.account_circle_outlined),
                      label: const Text('Tiếp tục với Google'),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                              _register = !_register;
                              _message = null;
                              _form.currentState?.reset();
                            }),
                      child: Text(
                        _register
                            ? 'Đã có tài khoản? Đăng nhập'
                            : 'Chưa có tài khoản? Đăng ký',
                      ),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () {
                              final error = validateEmail(_email.text);
                              if (error != null) {
                                setState(
                                  () => _message = 'Nhập email của bạn trước khi lấy lại mật khẩu.',
                                );
                                return;
                              }
                              _run(
                                () => widget.service.resetPassword(_email.text),
                                success: 'Nếu email đã đăng ký, bạn sẽ nhận được thư đặt lại mật khẩu. Hãy kiểm tra cả thư rác.',
                              );
                            },
                      child: const Text('Quên mật khẩu?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
