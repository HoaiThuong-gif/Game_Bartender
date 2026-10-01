# game_kitchen (Bartender)

## English

### Overview
The **Bartender game** (internal code name `game_kitchen` in these docs — the player-facing name in the app is "Quầy Bartender") is one of the mini-games inside **Game_Bartender**, the team's shared Flutter repo (`github.com/HoaiThuong-gif/Game_Bartender`). It is a multiplayer cooperative drink-making game: up to 10 players by original design (MVP target: **2 to 4 players**) work through a shared timer while each player also tracks personal completed orders for ranking.

This feature is developed by one team member and lives entirely under `lib/games/bartender/`, mirroring how the existing Rubik solver lives under `lib/games/rubik/`.

### Stack
- **UI / client logic:** Flutter, Dart
- **Realtime sync:** Firebase Realtime Database (RTDB)
- **Sensors:** `sensors_plus` (shake detection), `HapticFeedback` / `vibration`
- **Local-only dev:** an in-memory fake repository (no network required)

### Repository structure (this feature)
Following the convention already established by `lib/games/rubik/`:
```
lib/games/bartender/
├── models/          # Order, Recipe, Station, Round, Room, ring position
├── services/         # RoomRepository (interface) + Firebase + Fake implementations
├── controllers/       # Round/match state management, driving the UI
├── widgets/            # Station widgets, swipe targets, trash bin, order tray
├── screens/             # BartenderScreen (entry point), lobby/waiting, match, results
├── AGENTS.md             # Rules for coding agents, scoped to this feature
├── TASK.md               # Progress log
└── docs/                  # README.md, PROJECT_SPEC.md, ARCHITECTURE.md, DECISIONS.md, API.md, DEVELOPMENT.md
```
Everything for this feature — code, docs, agent rules, task log — lives inside this one folder, nested under the repo's existing `lib/games/` convention. Nothing is pushed up to the repo root except the one-line change to `lobby_screen.dart` described below.

### How it plugs into the app
There is no plugin/interface system in this repo (unlike an earlier, abandoned plan). Integration is direct, matching how Rubik is wired:
- `lib/screens/home/lobby_screen.dart` already has an `onBartenderTap` callback on the "Quầy Bartender" lobby object, currently defaulting to a "coming soon" snackbar.
- Once `BartenderScreen` exists, that callback is wired to `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BartenderScreen()))`, the same pattern used for `RubikScreen`.
- **`lobby_screen.dart` is a shared file, not owned by this feature.** Wiring the callback requires a small, clearly-scoped change to that file — see `DEVELOPMENT.md` for how to keep that change minimal and easy for the leader to review.

### Setup
See [DEVELOPMENT.md](./DEVELOPMENT.md) for full setup steps (Flutter, Firebase project, running with the fake repository first).

### Scope
See [PROJECT_SPEC.md](./PROJECT_SPEC.md) for the full MVP scope, and [ARCHITECTURE.md](./ARCHITECTURE.md) for internal structure and how it talks to Firebase.

---

## Tiếng Việt

### Tổng quan
**Game Bartender** (tên nội bộ trong bộ tài liệu này là `game_kitchen` — tên hiển thị trong app là "Quầy Bartender") là một trong các mini-game trong **Game_Bartender**, repo Flutter dùng chung của nhóm (`github.com/HoaiThuong-gif/Game_Bartender`). Đây là game phối hợp nhiều người chơi pha chế đồ uống: thiết kế gốc cho tối đa 10 người (mục tiêu MVP: **2 đến 4 người**), cùng chia sẻ một đồng hồ chung, trong khi mỗi người vẫn theo dõi đơn hàng cá nhân để xếp hạng.

Tính năng này do một thành viên phát triển và nằm hoàn toàn trong `lib/games/bartender/`, theo đúng khuôn mà trò giải Rubik đã có sẵn trong `lib/games/rubik/`.

### Công nghệ sử dụng
- **Giao diện / logic client:** Flutter, Dart
- **Đồng bộ thời gian thực:** Firebase Realtime Database (RTDB)
- **Cảm biến:** `sensors_plus` (nhận diện lắc), `HapticFeedback` / `vibration`
- **Chạy thử offline:** một fake repository lưu trong bộ nhớ (không cần mạng)

### Cấu trúc thư mục (của tính năng này)
Theo đúng quy ước mà `lib/games/rubik/` đã thiết lập:
```
lib/games/bartender/
├── models/          # Order, Recipe, Station, Round, Room, vị trí vòng tròn
├── services/         # RoomRepository (interface) + bản Firebase + bản Fake
├── controllers/       # Quản lý trạng thái round/trận, điều khiển UI
├── widgets/            # Widget trạm, vùng vuốt, thùng rác, khay đơn hàng
├── screens/             # BartenderScreen (điểm vào), lobby/chờ, trận đấu, kết quả
├── AGENTS.md             # Rules cho coding agent, giới hạn trong phạm vi tính năng này
├── TASK.md               # Nhật ký tiến độ
└── docs/                  # README.md, PROJECT_SPEC.md, ARCHITECTURE.md, DECISIONS.md, API.md, DEVELOPMENT.md
```
Toàn bộ của tính năng này — code, docs, rules agent, nhật ký task — nằm gọn trong một thư mục, lồng theo đúng quy ước `lib/games/` có sẵn của repo. Không có gì đẩy lên gốc repo ngoại trừ thay đổi một dòng trong `lobby_screen.dart` mô tả bên dưới.

### Cách tích hợp vào app
Repo này không có hệ thống plugin/interface (khác với một kế hoạch trước đó đã bỏ). Tích hợp diễn ra trực tiếp, giống cách Rubik đã được nối:
- `lib/screens/home/lobby_screen.dart` đã có sẵn callback `onBartenderTap` trên vật thể "Quầy Bartender" trong lobby, hiện đang mặc định hiện snackbar "đang được phát triển".
- Khi `BartenderScreen` đã có, callback đó sẽ được nối tới `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BartenderScreen()))`, giống hệt cách `RubikScreen` đang dùng.
- **`lobby_screen.dart` là file dùng chung, không thuộc sở hữu của tính năng này.** Việc nối callback cần một thay đổi nhỏ, rõ phạm vi vào file đó — xem `DEVELOPMENT.md` để biết cách giữ thay đổi tối thiểu, dễ cho leader review.

### Cài đặt
Xem [DEVELOPMENT.md](./DEVELOPMENT.md) để có đầy đủ các bước cài đặt (Flutter, project Firebase, chạy thử với fake repository trước).

### Phạm vi
Xem [PROJECT_SPEC.md](./PROJECT_SPEC.md) để biết phạm vi MVP đầy đủ, và [ARCHITECTURE.md](./ARCHITECTURE.md) để hiểu cấu trúc nội bộ và cách giao tiếp với Firebase.
