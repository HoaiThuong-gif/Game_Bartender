import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSecurityError implements Exception {
  const AccountSecurityError(this.message);
  final String message;
}

class AccountSecurity {
  AccountSecurity(this.auth);
  final FirebaseAuth auth;
  String? _grant;
  final _preferences = SharedPreferencesAsync();
  final _vault = const FlutterSecureStorage(
    aOptions: AndroidOptions.biometric(
      storageNamespace: 'account_biometrics_v1',
      enforceBiometrics: true,
      requireBiometricsPerOperation: true,
      resetOnError: false,
      biometricType: AndroidBiometricType.strongBiometricOnly,
      biometricPromptTitle: 'Đăng nhập Nhóm Bar',
      biometricPromptNegativeButton: 'Hủy',
    ),
  );

  Future<Map<String, dynamic>> request(
    String action, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final base = Uri.parse(
      const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://127.0.0.1:3000/api/v1',
      ),
    );
    if (base.scheme != 'https' &&
        !['127.0.0.1', 'localhost', '::1'].contains(base.host)) {
      throw const AccountSecurityError(
        'Kết nối tài khoản cần HTTPS hoặc USB tới máy tính.',
      );
    }
    final client = http.Client();
    try {
      final token = authenticated ? await auth.currentUser?.getIdToken() : null;
      final uri = base.replace(
        path: '${base.path.replaceAll(RegExp(r'/$'), '')}/account/$action',
      );
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response =
          await (body == null
                  ? client.get(uri, headers: headers)
                  : client.post(uri, headers: headers, body: jsonEncode(body)))
              .timeout(const Duration(seconds: 25));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        throw AccountSecurityError(
          (data['error'] as Map?)?['message'] as String? ??
              'Chưa xác thực được. Hãy thử lại.',
        );
      }
      return data;
    } finally {
      client.close();
    }
  }

  Future<void> verify(String challengeId, String code) async {
    final result = await request(
      'verify',
      body: {'challengeId': challengeId, 'code': code},
    );
    await auth.signInWithCustomToken(result['customToken'] as String);
    _grant = result['grant'] as String;
    await request('session');
  }

  Future<bool> get biometricEnabled => _preferences
      .getBool('account.biometric.enabled')
      .then((value) => value ?? false);
  Future<bool> get supportsBiometrics async =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      (await LocalAuthentication().getAvailableBiometrics()).contains(
        BiometricType.strong,
      );

  Future<void> enableBiometrics() async {
    if (_grant == null || !await supportsBiometrics) {
      throw const AccountSecurityError(
        'Cần xác thực OTP và cài vân tay/khuôn mặt bảo mật trên điện thoại trước.',
      );
    }
    await request('session');
    await _vault.write(key: 'grant', value: _grant);
    await _preferences.setBool('account.biometric.enabled', true);
  }

  Future<void> disableBiometrics() async {
    try {
      await _vault.delete(key: 'grant');
    } finally {
      await _preferences.setBool('account.biometric.enabled', false);
    }
  }

  Future<void> signInBiometric() async {
    if (!await biometricEnabled || !await supportsBiometrics) {
      throw const AccountSecurityError(
        'Hãy bật đăng nhập sinh trắc học trong hồ sơ sau khi xác thực OTP.',
      );
    }
    final grant = await _vault.read(
      key: 'grant',
    ); // Keystore requires OS authentication to decrypt.
    if (grant == null) {
      throw const AccountSecurityError(
        'Không đọc được khóa. Hãy đăng nhập thông thường.',
      );
    }
    final response = await request(
      'resume',
      body: {'grant': grant},
      authenticated: false,
    );
    await auth.signInWithCustomToken(response['customToken'] as String);
    _grant = grant;
  }

  Future<void> signOut() async {
    // Keep the UI locked locally even when the server is temporarily unreachable.
    try {
      if (auth.currentUser != null) await request('logout', body: {});
    } finally {
      _grant = null;
      try {
        await disableBiometrics();
      } finally {
        await auth.signOut();
      }
    }
  }
}
