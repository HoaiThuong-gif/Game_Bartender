# Gacha giấy trúng thưởng

Nâng cấp mới nhất: xem [CINEMATIC_UPGRADE.md](CINEMATIC_UPGRADE.md) về giấy lớn,
Three.js cinematic và kiểm chứng trên OPPO. [TEAR_UPGRADE.md](TEAR_UPGRADE.md)
là báo cáo đợt progressive tear trước đó; cơ chế xé vẫn được giữ nguyên.

Flow: `idle → selecting → paperFocus (280 ms) → waitingForTear → tearing
→ numberReveal (500 ms) → prizeLookup (600 ms) → itemReveal (300 ms) → result`.
Số hiện bằng fade/bounce ngay khi xé; bảng dò số trước khi tên món xuất hiện.
Các ô bảng đều nằm trong viewport nên không cần tự scroll bảng.

## Những phần đã cập nhật

- `controllers/gacha_controller.dart`: state machine, một random/một lần trừ cá,
  chặn bốc trong animation, duplicate, lưu thưởng một lần và reset lượt mới.
- `services/gacha_wallet.dart`: ví cá local dùng SharedPreferencesAsync.
  **Project chưa có ví cá chung**: cấp 2000 cá khi chưa có số dư đã lưu,
  mỗi lượt trừ 100 cá. Không cấp lại sau khi hết cá. Có thể inject ví của app;
  chưa có chức năng kiếm cá hay mua cá.
- `services/gacha_audio_service.dart`: một AudioPlayer cho sáu WAV local,
  bắt lỗi asset/plugin, dừng khi đổi tab/background, dispose khi rời màn.
- `screens/gacha_screen.dart`: kết nối controller, audio, haptic, lifecycle,
  số dư và các panel. Chạm hộp phiếu để bốc; đã bỏ nút bốc riêng và biển Gacha.
- `models/gacha_ticket_state.dart`, `models/gacha_reward.dart`,
  `data/gacha_rewards.dart`: state và dữ liệu tập trung; id/path ảnh/model.
  Ownership nằm ở collection, duplicate nằm ở lượt bốc, tránh dữ liệu lệch nhau.
- `widgets/gacha_scene.dart`, `tear_ticket.dart`: đưa giấy từ hộp vào vị trí,
  scale/fade/dim, drag hai chiều, mask xé dần, mép shadow, lớp phủ rời cây widget,
  bốn mảnh giấy tự biến mất và số reveal.
- `widgets/gacha_result_panel.dart`, `gacha_cinematic_viewer.dart`: panel
  fade/scale, nhãn Đã sở hữu, nút khóa khi đang lưu; Three.js trên Android.
  Bục gỗ, camera dolly, sáu particle ngắn và orbit sau khi xuất hiện.
- `widgets/reward_model_viewer.dart`: giữ model_viewer_plus 1.10.0,
  kiểm tra manifest thay vì đọc GLB vào Dart, PNG fallback khi thiếu/lỗi/timeout,
  fade/scale khi load, camera xoay một lần 20° rồi cho người dùng xoay.
  Dùng khi Three.js lỗi hoặc khi inject viewerBuilder trong test.
- `pubspec.yaml`, `pubspec.lock`: audioplayers 6.8.1 và integration_test từ SDK;
  khai báo assets/audio/gacha và assets/gacha3d. Renderer mới dùng dependency
  webview_flutter/Three.js sẵn có; không thay Android config ở đợt cinematic.
- `test/gacha_controller_test.dart`: state, duplicate, lưu/claim lặp, thiếu cá,
  ví lưu qua lần mở lại, tab/lifecycle, retry khi storage thất bại.
  Các test Gacha hiện có được cập nhật thời gian, dữ liệu model và fixture riêng.
- `integration_test/gacha_device_test.dart`: 20 lượt native Nón lá, ba lần xem
  mỗi lượt (mở, đóng/mở lại, đổi Lobby/mở lại), thao tác xoay, bốc tiếp,
  kiểm tra đủ/thiếu cá. Dùng ví và collection riêng, không đổi dữ liệu người chơi.
- `tool/generate_gacha_audio.py`: tạo sáu WAV mono bằng noise/tone, bản gốc
  không dùng sample tải về. `tool/monitor_gacha_memory.py`: lấy mẫu ADB PSS.

Giấy, UI, audio/haptic và navigation dùng Flutter SDK. Cảnh item trong result
dùng Three.js; không dựng tiệm/background/bảng/giấy bằng Three.js.
Scene Gacha không có mèo riêng nên không thêm nhân vật hoặc dependency animation.

## Collection và viewer

Giữ UX cũ: lưu thưởng khi reveal hoàn tất, ngay cả khi đóng bằng barrier.
Nút Nhận đợi lưu và retry nếu lần lưu trước thất bại. Reopen không random,
không trừ cá, không lưu thêm. Collection giữ set ID và retry pending khi mở Tủ đồ.

Viewer chỉ mount trong panel kết quả. Đóng, bốc tiếp hoặc đổi tab tháo viewer;
timer tải bị hủy, Three.js dispose model/texture/controls/mixer/renderer và
WebView chuyển về about:blank. Server loopback chỉ phục vụ HTML, JS và GLB
của result hiện tại rồi đóng. Lượt mount mới đợi cleanup lượt trước.
Nếu Three.js lỗi, release xong mới mount model_viewer_plus; không mount cả hai.
Việc giải phóng bộ nhớ native cuối cùng do Android WebView/GC quản lý.
Không preload collection GLB; grid Tủ đồ vẫn dùng PNG.

## Asset final cần bổ sung/thay

Nón lá: `assets/models/gacha/non_la.glb` đã có. Các món sau dùng PNG đúng món
cho tới khi thêm GLB riêng vào những đường dẫn này:

- `assets/models/gacha/ao_ba_ba.glb`
- `assets/models/gacha/khan_ran.glb`
- `assets/models/gacha/dep_to_ong.glb`
- `assets/models/gacha/non_tai_beo.glb`
- `assets/models/gacha/tui_vai.glb`

Không dùng `test_item.glb` thay vật phẩm thắng. PNG hiện có tiếp tục dùng;
icon thiếu/hỏng cũng có fallback SDK. Ưu tiên GLB low poly, ít material,
texture 512/1024; không bật realtime shadow/AR/auto rotation liên tục.

Có thể thay sáu âm tổng hợp bằng âm thu giấy thật cùng tên:
`assets/audio/gacha/{paper_pick,paper_rustle,paper_tear,number_reveal,prize_hit,item_reveal}.wav`.
Pipeline hiện chạy đầy đủ dù file âm bị thiếu; lỗi chỉ log trong debug.

## Kiểm tra

```text
flutter pub get
flutter analyze
flutter test
flutter test integration_test/gacha_device_test.dart -d 6TJRA6YTFUYL75KV *> gacha-device-test.txt
python tool/monitor_gacha_memory.py
```

Test device dùng harness Lobby/Gacha để kiểm tra lifecycle cùng cơ chế isActive
của màn thật. Test không thay thế việc đánh giá hình ảnh/âm thanh bằng tay.
PSS debug gồm Dart VM, asset/UI và renderer; cần xem xu hướng sau warmup,
không dùng một mẫu PSS làm bằng chứng tuyệt đối rằng native không leak.
Ví và collection đang lưu riêng; chưa có transaction khôi phục lượt bốc nếu
ứng dụng bị kill giữa lúc trừ cá và reveal. Khi app có backend/kinh tế thật,
cần dùng giao dịch lượt bốc bền vững trong repository chung.

## Kết quả xác minh trước đợt nâng cấp mask (2026-10-03)

- `flutter pub get`: thành công; `flutter analyze`: No issues found.
- `flutter test`: **132 test pass**, giữ lại các test cũ và thêm 4 test controller/ví.
- OPPO CPH1969 Android 11: **hai lần chạy, mỗi lần 20 lượt**, đều pass.
  Lần có cleanup 3D: 60 mount, 60 load GLB thành công, 60 dispose; đóng,
  mở lại, bốc tiếp, chuyển Lobby/Gacha và thiếu cá đều đạt. Không thấy timeout,
  renderer error hoặc exception trong bài integration.
- Lần có cleanup: 12 mẫu ADB ở lượt 7–19, PSS **407.6–433.7 MiB**,
  mẫu cuối **420.1 MiB**; WebView object count **3–4** ở các mẫu cuối,
  không tăng tuyến tính theo 60 lần mount. Native WebView vẫn có bộ nhớ cache/
  GC giữ tạm: chưa thể tuyên bố hết leak hoặc dùng con số debug này làm mức RAM release.
- Nón lá GLB 803564 byte, 5 mesh/primitive, 3 material, 1 texture;
  không bật shadow/AR/auto rotation liên tục.
- Build APK debug của app bình thường sau bài test: thành công.
- Đã cài lại APK app bình thường trên OPPO và mở MainActivity thành công.
- Log kiểm chứng ở `artifacts/gacha/`: all-tests.txt, device-test.txt,
  memory-samples.jsonl, build-final.txt; bản trước cleanup cũng được lưu để so sánh.

Các lần test không sửa ví/collection thật. Haptic và âm thanh đã gọi qua plugin
native trong bài integration; độ tự nhiên của tiếng giấy/rung vẫn cần đánh giá
bằng tai/tay. Các điều chỉnh cuối chỉ thay màu nút và timing/biến thiên giấy;
đã chạy lại analyze/132 test và build app.
