
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:object_3d_scanner/main.dart';

void main() {
  testWidgets('Kiểm tra giao diện trang chủ', (WidgetTester tester) async {
    await tester.pumpWidget(const Object3DScannerApp());

    expect(find.text('3D Object Scanner'), findsWidgets);
    expect(find.text('Bắt đầu quét 3D'), findsOneWidget);
    expect(find.byIcon(Icons.view_in_ar), findsOneWidget);
  });
}
