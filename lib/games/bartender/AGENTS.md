# AGENTS.md — game_kitchen (Bartender)

Rules for any coding agent (Antigravity, Claude Code, or similar) working in `lib/games/bartender/`. Read this file, and everything in the repo-root `docs/` folder relevant to this feature (`README.md`, `PROJECT_SPEC.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `API.md`, `DEVELOPMENT.md`), before writing or editing any code. Place this file at `lib/games/bartender/AGENTS.md` so it is found automatically by agents working inside this folder.

## English

### 1. Docs are the source of truth — you may read them, never edit them
- `docs/PROJECT_SPEC.md`, `docs/ARCHITECTURE.md`, and `docs/DECISIONS.md` (inside `lib/games/bartender/docs/`, this feature's own docs) describe locked decisions. **Do not edit these files.**
- If something you're asked to build contradicts these docs, or a doc is ambiguous/missing a detail you need, **stop and ask the developer** instead of guessing or silently changing the doc yourself.
- If the developer explicitly tells you a decision has changed, you may update `docs/DECISIONS.md` by **adding a new dated entry** (never rewrite or delete an old entry), and update the relevant section of `docs/PROJECT_SPEC.md` or `docs/ARCHITECTURE.md` to match — only when the developer has explicitly said so.
- `docs/API.md` and `docs/DEVELOPMENT.md` are reference material — same rule: don't edit them yourself; flag if they seem wrong.
- Also read (but never edit) `docs/rubik-foundation.md` and `docs/lobby.md` **at the repo root** (a different `docs/` folder from this feature's own, which lives inside `lib/games/bartender/docs/`) once, for context on this repo's existing naming and documentation conventions — they belong to the Rubik and lobby features, not this one.

### 2. `TASK.md` is yours to maintain
- `TASK.md` (at `lib/games/bartender/TASK.md`) is an operational log, not a decision record. **Keep it updated as you work.**
- Before starting work, check it for what's already done and what's in progress.
- Move items between "Đang làm / In progress", "Đã xong / Done", and "Chưa làm / Backlog" as you go. Add new backlog items if you discover necessary sub-tasks not yet listed.
- If blocked by a decision only the developer can make, add it under "Vướng mắc / Blocked" — do not guess and proceed silently on anything architecture- or scope-affecting.

### 3. Scope boundaries — this is the most important rule in this file
- Only write/edit files inside `lib/games/bartender/`. Do **not** modify anything inside `lib/games/rubik/`, `lib/screens/home/` (except the one exception below), `lib/shared/`, `assets/`, or any other part of the repo.
- **The one allowed exception:** wiring the `onBartenderTap` callback in `lib/screens/home/lobby_screen.dart`, and only as described in `DEVELOPMENT.md` step 7 — a single, minimal, isolated change (swap the placeholder snackbar for a `Navigator.push` to `BartenderScreen`), done as its own commit, never bundled with other changes. Do not touch anything else in that file, and never touch `lobby_layout.dart` or any asset under `assets/images/lobby/` — those belong to the lobby feature's own documented conventions in `docs/lobby.md`.
- Follow the internal layering in `docs/ARCHITECTURE.md` (`models` / `services` / `controllers` / `widgets` / `screens`) and match the naming style already used by `lib/games/rubik/` for consistency across the repo.
- `pubspec.yaml` currently has no Firebase or `sensors_plus` dependencies. Adding them is expected (see `DEVELOPMENT.md`), but do so as its own clearly-labeled change, since it affects the whole app's dependency tree, not just this feature.
- Follow the build order in `docs/DEVELOPMENT.md`. Don't jump ahead to a later stage while an earlier one is unverified.

### 4. Working style
- Prefer small, reviewable changes the developer can run and test on a real device before continuing, especially anything sensor-related (cannot be verified on an emulator).
- Do not perform your own code review or claim code is production-ready — the developer reviews and tests; your job is implementation against the docs.
- The developer is a first-time mobile developer who does not want to learn Dart/Flutter in depth — prefer clear, well-commented code and explain non-obvious choices in `TASK.md` notes rather than assuming familiarity.

## Tiếng Việt

### 1. Docs là nguồn sự thật — chỉ được đọc, không được sửa
- `docs/PROJECT_SPEC.md`, `docs/ARCHITECTURE.md`, và `docs/DECISIONS.md` (trong `lib/games/bartender/docs/`, docs riêng của tính năng này) mô tả các quyết định đã chốt. **Không sửa các file này.**
- Nếu yêu cầu nhận được mâu thuẫn với các docs này, hoặc một doc thiếu chi tiết/mơ hồ mà bạn cần, **dừng lại và hỏi người phát triển** thay vì tự đoán hoặc tự âm thầm sửa doc.
- Nếu người phát triển nói rõ ràng một quyết định đã đổi, bạn có thể cập nhật `docs/DECISIONS.md` bằng cách **thêm một mục mới có ghi ngày** (không viết đè hay xoá mục cũ), và cập nhật phần liên quan trong `docs/PROJECT_SPEC.md` hoặc `docs/ARCHITECTURE.md` cho khớp — chỉ khi người phát triển đã nói rõ như vậy.
- `docs/API.md` và `docs/DEVELOPMENT.md` là tài liệu tham khảo — luật tương tự: không tự sửa, chỉ báo nếu thấy có vẻ sai.
- Cũng đọc (nhưng không sửa) `docs/rubik-foundation.md` và `docs/lobby.md` **ở gốc repo** (một thư mục `docs/` khác, không phải `docs/` riêng của tính năng này nằm trong `lib/games/bartender/docs/`) một lần, để hiểu quy ước đặt tên và tài liệu đã có sẵn của repo — chúng thuộc về tính năng Rubik và lobby, không phải tính năng này.

### 2. `TASK.md` là file bạn phải tự duy trì
- `TASK.md` (tại `lib/games/bartender/TASK.md`) là nhật ký vận hành, không phải bản ghi quyết định. **Luôn cập nhật khi đang làm việc.**
- Trước khi bắt đầu, kiểm tra xem đã xong gì, đang làm gì.
- Di chuyển mục giữa "Đang làm / In progress", "Đã xong / Done", "Chưa làm / Backlog" khi tiến độ thay đổi. Thêm mục backlog mới nếu phát hiện việc con cần làm.
- Nếu bị vướng bởi quyết định chỉ người phát triển mới quyết được, ghi vào "Vướng mắc / Blocked" — không tự đoán rồi âm thầm làm tiếp với bất kỳ điều gì ảnh hưởng kiến trúc hoặc phạm vi.

### 3. Giới hạn phạm vi — luật quan trọng nhất trong file này
- Chỉ viết/sửa file bên trong `lib/games/bartender/`. **Không** sửa bất kỳ thứ gì trong `lib/games/rubik/`, `lib/screens/home/` (trừ ngoại lệ bên dưới), `lib/shared/`, `assets/`, hay bất kỳ phần nào khác của repo.
- **Ngoại lệ duy nhất được phép:** nối callback `onBartenderTap` trong `lib/screens/home/lobby_screen.dart`, và chỉ theo đúng mô tả ở bước 7 của `DEVELOPMENT.md` — một thay đổi duy nhất, tối thiểu, tách biệt (đổi snackbar tạm thành `Navigator.push` tới `BartenderScreen`), làm thành commit riêng, không bao giờ gộp với thay đổi khác. Không đụng gì khác trong file đó, và không bao giờ đụng `lobby_layout.dart` hay bất kỳ asset nào trong `assets/images/lobby/` — những thứ đó thuộc quy ước riêng của tính năng lobby, đã ghi trong `docs/lobby.md`.
- Tuân theo cấu trúc lớp nội bộ trong `docs/ARCHITECTURE.md` (`models` / `services` / `controllers` / `widgets` / `screens`) và theo đúng kiểu đặt tên mà `lib/games/rubik/` đã dùng để nhất quán trong repo.
- `pubspec.yaml` hiện chưa có dependency Firebase hay `sensors_plus`. Việc thêm vào là cần thiết (xem `DEVELOPMENT.md`), nhưng làm thành thay đổi riêng, rõ ràng, vì nó ảnh hưởng đến cây dependency của cả app, không chỉ tính năng này.
- Tuân theo thứ tự xây dựng trong `docs/DEVELOPMENT.md`. Không nhảy sang giai đoạn sau khi giai đoạn trước chưa được kiểm chứng.

### 4. Cách làm việc
- Ưu tiên thay đổi nhỏ, dễ review, để người phát triển chạy và test trên thiết bị thật trước khi tiếp tục, đặc biệt với thứ liên quan cảm biến (không thể kiểm chứng trên giả lập).
- Không tự review code của chính mình hay tự nhận code đã sẵn sàng production — người phát triển sẽ review và test; việc của bạn là cài đặt theo đúng docs.
- Người phát triển là người lần đầu làm mobile app và không muốn học sâu Dart/Flutter — ưu tiên code rõ ràng, có comment đầy đủ, và giải thích các lựa chọn không hiển nhiên trong ghi chú ở `TASK.md` thay vì giả định người đọc đã quen thuộc.
