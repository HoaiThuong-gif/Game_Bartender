# DEVELOPMENT — game_kitchen (Bartender)

## English

> Added beyond the required doc set because the developer is building their first mobile app and is deferring implementation to a coding agent (Claude Code / Antigravity). A clear, ordered setup and workflow reduces back-and-forth and avoids the agent making undocumented environment assumptions.

### Recommended build order
Follow this order; each stage should be runnable and demoable before moving to the next.

1. **Skeleton feature, no shared-file changes yet.** Create `lib/games/bartender/` with the `models / services / controllers / widgets / screens` folders from `ARCHITECTURE.md`. Add a minimal `BartenderScreen` showing placeholder text. Run it standalone (temporarily point `main.dart` at it, or add a debug route) — do not touch `lobby_screen.dart` yet.
2. **Models, no UI polish.** Implement the models and rules in `models/` (ring math, round completion, station assignment, recipe/difficulty pool) as plain Dart, with unit tests in `test/` at the repo root (same location as the existing Rubik tests, e.g. `test/cube_state_test.dart` — follow that pattern, e.g. `test/bartender_round_test.dart`).
3. **Single-device playable loop with `FakeRoomRepository`.** Wire up `widgets/`/`screens/` against the fake, in-memory repository. The full round loop, station display, swiping, trash bin, and order submission should work on one phone with simulated other players. No Firebase needed yet.
4. **Firebase project setup.** This repo has no Firebase dependency yet (`pubspec.yaml` confirmed clean). Create the Firebase project, run the FlutterFire CLI, add the generated config files for Android (and iOS later). **Tell the team before doing this** — it adds new files under `android/app/` that others will see.
5. **`FirebaseRoomRepository`.** Implement the real repository against the schema in `API.md`. Test room creation and joining with 2 physical devices first, then 3–4.
6. **Sensors and haptics.** Add `sensors_plus` (not yet a dependency — add it to `pubspec.yaml`) for the shaker station, plus haptic feedback for key events. Test only on real devices (see note below).
7. **Wire into the lobby.** This is the only step that touches a shared file. In `lib/screens/home/lobby_screen.dart`, change the `onBartenderTap` default from the "coming soon" snackbar to:
   ```dart
   onBartenderTap ?? () => Navigator.of(context).push(
     MaterialPageRoute<void>(builder: (_) => const BartenderScreen()),
   ),
   ```
   Make this its own small commit (or PR into `dev`), separate from the rest of the feature's commits, so the leader can review just this one-line change easily. Do not touch anything else in `lobby_screen.dart` or `lobby_layout.dart` (positioning/assets are the leader's area, documented in `docs/lobby.md`).
8. **Polish and results screen.** End-of-match results, ranking display, basic styling.

### Local development (steps 1–3, no Firebase)
```bash
flutter pub get
flutter test                 # runs unit tests, including the new bartender ones
flutter run -d <device-id>   # runs the app with FakeRoomRepository selected
```
Use a simple compile-time or runtime flag (e.g. a constant in a `bartender_config.dart` file) to choose between `FakeRoomRepository` and `FirebaseRoomRepository`, so gameplay can keep developing without touching Firebase at all until step 4.

### Firebase setup (step 4 onward)
1. Create a project at the Firebase console and enable **Realtime Database** (not Firestore).
2. Install the FlutterFire CLI and run `flutterfire configure` from the repo root; this generates `firebase_options.dart` and the platform config files.
3. Add the generated Android config (`google-services.json`) under `android/app/`.
4. For iOS, the equivalent (`GoogleService-Info.plist`) requires a Mac-connected flow — the team's iOS user has no Mac, so Android is the priority target; this step can be deferred (see `DECISIONS.md`, D2).
5. Set Realtime Database rules as shown in `API.md`. Firebase's default "test mode" rules **expire automatically after about 30 days** — check they haven't expired before demo day.

### Testing on real devices
- **Shake detection cannot be reliably tested on an emulator/simulator.** Test on at least one real Android phone from the first moment shake logic is added.
- **Multi-device testing:** devices just need any internet connection (Wi-Fi or mobile data) to reach Firebase — they don't need to share a network.
- **The existing Rubik feature already has a working Android build process** documented in `docs/rubik-foundation.md` at the repo root, including an offline Gradle fallback (`gradlew.bat --offline ...`) if dependency downloads are slow. Reuse that if you hit the same issue.
- **iOS:** if attempted, budget extra time for provisioning/signing issues (see `DECISIONS.md`, D2).

### Working with a coding agent
- Give the agent this documentation set (`PROJECT_SPEC.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `API.md`) plus this file as context before asking it to implement a stage.
- Also point it at `docs/rubik-foundation.md` at the repo root once, so it sees the naming convention (`models/services/controllers/widgets/screens`) already established by the other feature and stays consistent with it.
- Ask for one stage of the build order above at a time, and run/test each stage on a device before asking for the next.
- Step 7 (wiring `lobby_screen.dart`) should be a deliberately small, isolated request to the agent — remind it explicitly not to touch anything else in that file or in `lobby_layout.dart`.
- If a requirement turns out to be wrong or needs to change while building, update the relevant doc (usually `PROJECT_SPEC.md` or a new entry in `DECISIONS.md`) rather than only telling the agent verbally.
- Code review is expected to be done by the coding agent itself (or a second agent), not by asking Claude.ai for a code review.

## Tiếng Việt

> Thêm ngoài bộ tài liệu bắt buộc vì đây là lần đầu người phát triển làm mobile app và phần cài đặt sẽ giao cho coding agent (Claude Code / Antigravity). Thứ tự cài đặt và quy trình rõ ràng giúp giảm hỏi lại qua lại và tránh agent tự giả định môi trường không được ghi lại.

### Thứ tự xây dựng gợi ý
Làm theo thứ tự này; mỗi giai đoạn nên chạy và demo được trước khi sang giai đoạn tiếp theo.

1. **Khung tính năng, chưa đụng file dùng chung.** Tạo `lib/games/bartender/` với các thư mục `models / services / controllers / widgets / screens` theo `ARCHITECTURE.md`. Thêm một `BartenderScreen` tối thiểu hiện chữ tạm. Chạy độc lập (tạm trỏ `main.dart` vào nó, hoặc thêm route debug) — chưa đụng `lobby_screen.dart`.
2. **Models, chưa cần giao diện đẹp.** Cài đặt model và luật trong `models/` (toán vòng tròn, kiểm tra round hoàn thành, phân trạm, tập công thức/độ khó) bằng Dart thuần, kèm unit test đặt trong `test/` ở gốc repo (cùng chỗ với test Rubik hiện có, ví dụ `test/cube_state_test.dart` — theo đúng mẫu đó, ví dụ `test/bartender_round_test.dart`).
3. **Vòng lặp chơi được trên một máy với `FakeRoomRepository`.** Nối `widgets/`/`screens/` với repository giả trong bộ nhớ. Toàn bộ vòng lặp round, hiển thị trạm, vuốt, thùng rác, nộp đơn nên chạy được trên một điện thoại với người chơi khác được giả lập. Chưa cần Firebase.
4. **Cài đặt project Firebase.** Repo này chưa có dependency Firebase nào (`pubspec.yaml` đã kiểm tra, sạch). Tạo project Firebase, chạy FlutterFire CLI, thêm file cấu hình sinh ra cho Android (và iOS sau). **Báo nhóm trước khi làm bước này** — nó thêm file mới vào `android/app/` mà người khác sẽ thấy.
5. **`FirebaseRoomRepository`.** Cài đặt repository thật theo schema trong `API.md`. Test tạo phòng và vào phòng với 2 thiết bị thật trước, sau đó 3-4.
6. **Cảm biến và rung.** Thêm `sensors_plus` (chưa có trong dependency — thêm vào `pubspec.yaml`) cho trạm bình lắc, cùng rung phản hồi cho các sự kiện chính. Chỉ test trên thiết bị thật (xem ghi chú bên dưới).
7. **Nối vào lobby.** Đây là bước duy nhất đụng vào file dùng chung. Trong `lib/screens/home/lobby_screen.dart`, đổi mặc định của `onBartenderTap` từ snackbar "đang phát triển" thành:
   ```dart
   onBartenderTap ?? () => Navigator.of(context).push(
     MaterialPageRoute<void>(builder: (_) => const BartenderScreen()),
   ),
   ```
   Làm thành một commit nhỏ riêng (hoặc PR riêng vào `dev`), tách khỏi các commit khác của tính năng, để leader dễ review đúng một dòng thay đổi này. Không đụng gì khác trong `lobby_screen.dart` hay `lobby_layout.dart` (vị trí/asset là phần của leader, đã ghi trong `docs/lobby.md`).
8. **Hoàn thiện và màn hình kết quả.** Kết quả cuối trận, bảng xếp hạng, chỉnh giao diện cơ bản.

### Phát triển local (bước 1-3, chưa cần Firebase)
```bash
flutter pub get
flutter test                 # chạy unit test, gồm cả test bartender mới
flutter run -d <device-id>   # chạy app với FakeRoomRepository
```
Dùng một cờ đơn giản (ví dụ một hằng số trong file `bartender_config.dart`) để chọn giữa `FakeRoomRepository` và `FirebaseRoomRepository`, để tiếp tục phát triển gameplay mà chưa cần đụng Firebase cho đến bước 4.

### Cài đặt Firebase (từ bước 4)
1. Tạo project trên Firebase console và bật **Realtime Database** (không phải Firestore).
2. Cài FlutterFire CLI và chạy `flutterfire configure` từ gốc repo; lệnh này sinh ra `firebase_options.dart` và file cấu hình nền tảng.
3. Thêm file cấu hình Android (`google-services.json`) vào `android/app/`.
4. Với iOS, file tương ứng (`GoogleService-Info.plist`) cần quy trình có kết nối Mac — người dùng iOS trong nhóm không có Mac, nên Android là mục tiêu ưu tiên; bước này có thể để sau (xem `DECISIONS.md`, D2).
5. Thiết lập Realtime Database rules như trong `API.md`. Rules "test mode" mặc định của Firebase **tự hết hạn sau khoảng 30 ngày** — kiểm tra trước ngày demo.

### Test trên thiết bị thật
- **Không thể test đáng tin cậy việc nhận diện lắc trên giả lập.** Test trên ít nhất một điện thoại Android thật ngay từ lúc thêm logic lắc.
- **Test nhiều thiết bị:** chỉ cần có kết nối internet bất kỳ (wifi hay dữ liệu di động) để tới được Firebase — không cần chung mạng.
- **Tính năng Rubik hiện có đã có sẵn quy trình build Android hoạt động**, ghi trong `docs/rubik-foundation.md` ở gốc repo, kể cả cách build Gradle offline (`gradlew.bat --offline ...`) nếu tải dependency chậm. Dùng lại nếu gặp vấn đề tương tự.
- **iOS:** nếu thử làm, nên dự trù thêm thời gian cho vấn đề provisioning/ký (xem `DECISIONS.md`, D2).

### Làm việc với coding agent
- Đưa cho agent bộ tài liệu này (`PROJECT_SPEC.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `API.md`) cộng với file này làm ngữ cảnh trước khi yêu cầu cài đặt một giai đoạn.
- Cũng cho agent xem qua `docs/rubik-foundation.md` ở gốc repo một lần, để nó thấy quy ước đặt tên (`models/services/controllers/widgets/screens`) mà tính năng kia đã thiết lập và giữ nhất quán.
- Yêu cầu từng giai đoạn trong thứ tự xây dựng ở trên, chạy/test từng giai đoạn trên thiết bị trước khi yêu cầu giai đoạn tiếp theo.
- Bước 7 (nối `lobby_screen.dart`) nên là một yêu cầu cố ý nhỏ, tách biệt với agent — nhắc rõ không đụng gì khác trong file đó hay trong `lobby_layout.dart`.
- Nếu một yêu cầu hoá ra sai hoặc cần đổi trong lúc code, cập nhật tài liệu liên quan (thường là `PROJECT_SPEC.md` hoặc thêm mục mới vào `DECISIONS.md`) thay vì chỉ nói miệng với agent.
- Việc review code nên do chính coding agent (hoặc agent thứ hai) đảm nhận, không nhờ Claude.ai review code.
