import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

String? validateEmail(String? value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
    ? null
    : 'Nhập địa chỉ email hợp lệ.';

String? validatePassword(String? value) =>
    (value?.length ?? 0) >= 6 ? null : 'Mật khẩu cần ít nhất 6 ký tự.';

String? validatePlayerName(String? value) {
  final name = value?.trim() ?? '';
  return name.isNotEmpty && name.length <= 40
      ? null
      : 'Tên cần có từ 1 đến 40 ký tự.';
}

String accountError(Object error) {
  if (error is TimeoutException) {
    return 'Chưa xác nhận được đã lưu. Hãy kiểm tra mạng. Thay đổi đang chờ có thể đồng bộ khi có mạng trở lại.';
  }
  if (error is GoogleSignInException) {
    return error.code == GoogleSignInExceptionCode.canceled
        ? 'Bạn đã hủy đăng nhập Google.'
        : 'Chưa đăng nhập được Google. Thử lại hoặc dùng email.';
  }
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'email-already-in-use' || 'credential-already-in-use' =>
        'Email này đã có tài khoản. Hãy đăng nhập hoặc chọn Quên mật khẩu.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Email hoặc mật khẩu chưa đúng.',
      'invalid-email' => 'Địa chỉ email chưa hợp lệ.',
      'weak-password' => 'Mật khẩu quá dễ đoán. Hãy chọn mật khẩu mạnh hơn.',
      'user-disabled' => 'Tài khoản đã bị khóa. Hãy liên hệ người quản lý.',
      'too-many-requests' =>
        'Bạn đã thử nhiều lần. Hãy đợi một lúc rồi thử lại.',
      'network-request-failed' =>
        'Chưa kết nối được. Hãy kiểm tra mạng rồi thử lại.',
      'requires-recent-login' => 'Hãy đăng nhập lại để đổi mật khẩu.',
      'account-exists-with-different-credential' =>
        'Email này đang dùng cách đăng nhập khác. Hãy dùng cách đã đăng ký.',
      'operation-not-allowed' =>
        'Cách đăng nhập này chưa được bật. Hãy báo người quản lý.',
      _ => 'Chưa thực hiện được. Hãy thử lại.',
    };
  }
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' || 'unauthorized' =>
        'Chưa có quyền lưu hồ sơ. Hãy báo người quản lý ứng dụng.',
      'unavailable' => 'Chưa kết nối được nơi lưu hồ sơ. Hãy thử lại.',
      _ => 'Chưa lưu được hồ sơ. Hãy thử lại.',
    };
  }
  return 'Chưa thực hiện được. Hãy kiểm tra kết nối rồi thử lại.';
}
