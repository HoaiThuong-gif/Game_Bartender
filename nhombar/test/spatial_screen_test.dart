import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/spatial/spatial_screen.dart';

void main() {
  const channel = MethodChannel('meomeo/spatial');
  late List<Map<String, dynamic>> models;
  late List<List<String>> deletions;
  var rejectDeletion = false;
  var connectionFails = false;
  late List<String> scanCalls;

  setUp(() {
    models = List.generate(
      2,
      (i) => <String, dynamic>{
        'id': 'model-$i',
        'name': 'Object $i',
        'triangles': 1000,
        'frames': 40,
        'coverage': 80,
        'qualityVersion': 4,
      },
    );
    deletions = [];
    rejectDeletion = false;
    connectionFails = false;
    scanCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'models':
              return models;
            case 'capabilities':
              return {'arcore': 'SUPPORTED_INSTALLED'};
            case 'serverSettings':
              return {'usbAddress': 'https://127.0.0.1:8765'};
            case 'checkServerConnection':
              scanCalls.add('check');
              if (connectionFails) {
                throw PlatformException(
                  code: 'SPATIAL_NETWORK',
                  message: 'PC cần cùng mạng Wi-Fi',
                );
              }
              return {'ready': true, 'transport': 'USB'};
            case 'open':
              scanCalls.add('open');
              return null;
            case 'deleteModels':
              final ids = List<String>.from(
                (call.arguments as Map)['ids'] as List,
              );
              deletions.add(ids);
              if (rejectDeletion) {
                throw PlatformException(
                  code: 'SPATIAL_DELETE',
                  message: 'Đang dùng trong AR',
                );
              }
              models.removeWhere((model) => ids.contains(model['id']));
              return ids.length;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> open(WidgetTester tester, {bool library = true}) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: SpatialScreen()));
    await tester.pumpAndSettle();
    if (library) {
      await tester.tap(find.text('Mô hình của tôi'));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('cancel preserves models; confirm deletes only selected model', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.byTooltip('Xóa mô hình').first);
    await tester.pumpAndSettle();
    expect(deletions, isEmpty);
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(find.text('Object 0'), findsOneWidget);
    await tester.tap(find.byTooltip('Xóa mô hình').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await tester.pumpAndSettle();
    expect(deletions, [
      ['model-0'],
    ]);
    expect(find.text('Object 0'), findsNothing);
    expect(find.text('Object 1'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('batch deletion sends selected IDs and refreshes library', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa đã chọn'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await tester.pumpAndSettle();
    expect(deletions.single, ['model-0', 'model-1']);
    expect(find.text('Object 0'), findsNothing);
    expect(find.text('Object 1'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('active AR reference rejection keeps the model in library', (
    tester,
  ) async {
    rejectDeletion = true;
    await open(tester);
    await tester.tap(find.byTooltip('Xóa mô hình').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await tester.pumpAndSettle();
    expect(find.text('Object 0'), findsOneWidget);
    expect(find.text('Chưa thực hiện được. Hãy thử lại.'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('USB opens capture without requiring Wi-Fi settings', (
    tester,
  ) async {
    await open(tester, library: false);
    await tester.tap(find.text('Bắt đầu quét'));
    await tester.pumpAndSettle();
    expect(scanCalls, ['check', 'check', 'open']);
    expect(find.text('Quét mã kết nối'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('unreachable PC opens guided setup before capture', (
    tester,
  ) async {
    connectionFails = true;
    await open(tester, library: false);
    expect(find.text('Chưa tìm thấy máy xử lý 3D'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Bắt đầu quét'),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Hướng dẫn kết nối'));
    await tester.pumpAndSettle();
    expect(scanCalls, ['check', 'check']);
    expect(find.text('Quét mã kết nối'), findsOneWidget);
    expect(find.byType(TextField).hitTestable(), findsNothing);
    expect(scanCalls.contains('open'), isFalse);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(scanCalls.contains('open'), isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('setup detects plugged cable then continues into capture', (
    tester,
  ) async {
    connectionFails = true;
    await open(tester, library: false);
    await tester.tap(find.text('Hướng dẫn kết nối'));
    await tester.pumpAndSettle();
    connectionFails = false;
    await tester.pump(const Duration(seconds: 8));
    await tester.pumpAndSettle();
    expect(find.text('Sẵn sàng quét'), findsOneWidget);
    await tester.tap(find.text('Xong'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bắt đầu quét'));
    await tester.pumpAndSettle();
    expect(scanCalls.last, 'open');
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
