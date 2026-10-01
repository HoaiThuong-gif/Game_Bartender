# DECISIONS — game_kitchen

Each entry records a locked decision, why it was made, and what was considered instead. Entries are dated by when they were locked during planning (2026-09-30 session). If a requirement or architecture assumption changes later, the affected entry must be revisited and the dependent docs (`PROJECT_SPEC.md`, `ARCHITECTURE.md`) updated accordingly.

## English

### D1 — Backend: Firebase Realtime Database
**Decision:** Use Firebase Realtime Database (RTDB) for room state, item passing, and the shared timer.
**Rationale:** No server to host or maintain; free tier (Spark plan) comfortably covers the expected load of a 2–4 player match; strong Flutter support via FlutterFire; developer has no backend experience and does not want to gain deep Flutter/Dart expertise either, so avoiding a self-hosted server reduces total surface area to learn.
**Alternatives considered:** Self-hosted Dart WebSocket server (rejected: requires hosting, and free hosting tiers sleep after inactivity — a demo-day risk); Cloud Firestore (rejected for this use case: per-operation billing model fits a frequent-small-update game worse than RTDB); Supabase Realtime (rejected: viable, but free projects can auto-pause after inactivity, another demo-day risk, with no clear advantage over RTDB for this scope).

### D2 — iOS strategy: Android-first
**Decision:** Build and verify on Android first; attempt an iOS build later only if time allows.
**Rationale:** The team's iOS user has no Mac available, and native iOS builds require macOS/Xcode (or a paid cloud-build service). Blocking MVP progress on solving iOS access was judged not worth it.
**Alternatives considered:** Paid Apple Developer Program + cloud CI (Codemagic) for signed builds (possible later, costs money and setup time); free-tier sideloading via a regular Apple ID (7-day signature, must be reinstalled weekly — deferred as a stretch option); running the game as a web build in Safari (deferred: motion sensor and vibration support in mobile Safari is limited, would likely require its own compromises).

### D3 — Room & lobby model
**Decision:** One player creates a room and receives a generated code (e.g. 4 digits); others join by entering the code. A match starts with 2+ players (not requiring all 4). If a player disconnects mid-match, the match continues with the remaining players.
**Rationale:** Matches the team's actual test setup (up to 4 phones, not always all present) and keeps room logic simple — no need to handle "waiting for exactly N players" edge cases.
**Alternatives considered:** QR code join (not needed for a small in-person team test); requiring exactly 4 players to start (rejected: too restrictive for iterative testing).

### D4 — Round model decoupled from the shared timer
**Decision:** The shared match timer (60s, +5s per completed order) only determines when the whole match ends. Separately, a "round" ends when **all** players have completed a fixed number of orders (target: 3) for that round; ending a round triggers station reassignment and starts a new round.
**Rationale:** Requested by the team lead specifically so that later updates can extend or rebalance round-based difficulty progression without having to change the match-ending timer logic.
**Alternatives considered:** A single continuous model where players just keep receiving new orders until the timer runs out with no round boundaries, matching the original Word document description most literally (rejected per team lead's explicit direction); time-boxed rounds (e.g. 30 seconds per round regardless of completion) (rejected in favor of the all-players-done trigger).

### D5 — Stations: 4+, randomly reassigned each round, duplicates/missing allowed
**Decision:** At least 4 processing stations exist. Each round, stations are randomly (re)assigned to players; it is acceptable for two players to share a station type or for a player to have none, even at 2–4 players.
**Rationale:** Preserves the original design's core coordination pressure (you may not have the station you need and must rely on teammates) rather than simplifying to a clean 1-to-1 mapping that would remove that tension.
**Alternatives considered:** Strict 1-to-1 station-to-player mapping at low player counts (rejected — explicitly not wanted).

### D6 — Sensor usage: touch/drag primary, one shake station
**Decision:** Most stations use touch/drag interactions. Exactly one station (the shaker) uses phone-shake detection via `sensors_plus`. Tilt-based interaction is out of scope for MVP.
**Rationale:** Keeps sensor-related code to a minimum (one small, well-documented API) for a developer who does not want to go deep into Flutter, while still keeping one "phone-native" interaction from the original concept. Tilt was excluded because it is hard to verify on emulators and behaves inconsistently across Android devices.
**Alternatives considered:** No sensor usage at all (rejected: would lose a signature part of the original game concept); multiple sensor-based stations as originally envisioned — knife/cutting board via swipe, blender via horizontal shake, juicer via pinch, shaker via vertical shake, pouring via tilt (deferred as a post-MVP stretch goal).

### D7 — Recipes & difficulty: 3–5 recipes, difficulty increases by round
**Decision:** A fixed pool of 3–5 recipes of varying complexity (1 ingredient/step up to multiple ingredients/stations). Early rounds only draw from easy recipes; later rounds draw from a pool that includes harder ones.
**Rationale:** Matches the original design intent (easy start, harder later) while staying simple to implement — a static ordered/gated pool, not a dynamic scaling algorithm.
**Alternatives considered:** Fully random recipe draw from the whole pool every round regardless of round number (rejected — would not guarantee an easy start); dynamic algorithmic difficulty scaling (rejected as unnecessary complexity for MVP).

### D8 — Item passing and order submission
**Decision:** Items are passed by swiping left/right to the adjacent player in the ring. Orders are submitted manually by dragging the finished product into a "submit" zone on the order owner's own screen.
**Rationale:** Matches the original game concept's core interaction model; manual submission (vs. auto-submit on receipt) gives the player a clear, deliberate action and avoids accidental submissions from items merely passing through.
**Alternatives considered:** Auto-submit when the correct product reaches the order owner (rejected — removes player agency and risks accidental submission).

### D9 — Documentation language: bilingual English + Vietnamese
**Decision:** All project documentation for this package is written bilingually (English section followed by Vietnamese section), with technical terms kept in English in both.
**Rationale:** Explicit project-specific preference, overriding the general default of English-only docs, because this documentation will be read/reviewed by Vietnamese-speaking teammates and possibly the instructor.
**Alternatives considered:** English-only (the general default) — not used for this project by explicit request.

### D10 — Repository and integration structure: switched to the leader's flat `Game_Bartender` repo
**Decision:** Build this feature inside `github.com/HoaiThuong-gif/Game_Bartender`, under `lib/games/bartender/`, matching the flat convention already used by `lib/games/rubik/` — not the earlier `packages/` monorepo plan with a `MiniGame` interface. Integration with the rest of the app is a single `BartenderScreen` entry point, wired into the existing `onBartenderTap` callback in `lib/screens/home/lobby_screen.dart`.
**Rationale:** The team decided to use the leader's actual working repo instead of the earlier placeholder repo. That repo already has a substantial, working Rubik feature built on a flat `lib/games/<name>/` structure with no plugin interface, and the lobby screen already has a placeholder tap target wired for Bartender — matching that existing convention is far less work and far easier for the leader to review than introducing a new monorepo/package system into an already-developed app.
**Alternatives considered:** Keep the original `packages/` + `game_api`/`MiniGame` plan and ask the team to restructure the real repo to match it (rejected — the real repo is already built around a different, working convention; restructuring it would be disruptive and is not this developer's call to make unilaterally).

### D11 — Documentation format: kept personal convention over the team's narrative-doc style
**Decision:** This feature's documentation stays in the developer's own README/PROJECT_SPEC/ARCHITECTURE/DECISIONS/API/DEVELOPMENT split, even though the rest of the repo documents features as a single long narrative file per feature (e.g. `docs/rubik-foundation.md`, `docs/lobby.md`).
**Rationale:** Explicit developer preference — familiarity with, and reliance on, this specific documentation structure for working with a coding agent outweighs matching the existing repo's documentation style for this one feature.
**Alternatives considered:** Match the team's single-narrative-file style (would have been easier to review alongside existing docs, but rejected by explicit request); a hybrid of both styles (not chosen).

## Tiếng Việt

### D1 — Backend: Firebase Realtime Database
**Quyết định:** Dùng Firebase Realtime Database (RTDB) cho trạng thái phòng, chuyền vật phẩm, và đồng hồ chung.
**Lý do:** Không cần host hay bảo trì server; gói miễn phí (Spark) đủ sức cho tải dự kiến của một trận 2-4 người; hỗ trợ Flutter tốt qua FlutterFire; người phát triển chưa có kinh nghiệm backend và cũng không muốn học sâu Flutter/Dart, nên tránh tự host server giúp giảm bớt thứ phải học.
**Phương án khác đã xét:** Server WebSocket tự host bằng Dart (loại bỏ: cần host, các gói host miễn phí thường ngủ sau thời gian không hoạt động — rủi ro cho ngày demo); Cloud Firestore (loại bỏ cho trường hợp này: mô hình tính phí theo thao tác không hợp với game cập nhật nhỏ và liên tục bằng RTDB); Supabase Realtime (loại bỏ: khả thi, nhưng project miễn phí có thể tự tạm dừng sau thời gian không hoạt động, cũng là rủi ro ngày demo, và không có lợi thế rõ ràng so với RTDB cho phạm vi này).

### D2 — Chiến lược iOS: ưu tiên Android trước
**Quyết định:** Build và kiểm chứng trên Android trước; chỉ thử build iOS sau nếu còn thời gian.
**Lý do:** Người dùng iOS trong nhóm không có Mac, mà build iOS native cần macOS/Xcode (hoặc dịch vụ build cloud trả phí). Việc chặn tiến độ MVP để giải quyết vấn đề truy cập iOS được đánh giá là không đáng.
**Phương án khác đã xét:** Apple Developer Program trả phí + CI cloud (Codemagic) để build có ký (có thể làm sau, tốn tiền và thời gian cài đặt); sideload miễn phí bằng Apple ID thường (chữ ký 7 ngày, phải cài lại hàng tuần — để dành làm phương án cộng thêm); chạy game dạng web trên Safari (để dành sau: hỗ trợ cảm biến chuyển động và rung trên Safari di động khá hạn chế, nhiều khả năng phải đánh đổi thêm).

### D3 — Mô hình phòng & lobby
**Quyết định:** Một người tạo phòng và nhận mã được sinh ra (ví dụ 4 số); người khác vào bằng cách nhập mã. Trận bắt đầu khi có từ 2 người trở lên (không bắt buộc đủ 4). Nếu một người thoát giữa trận, trận tiếp tục với những người còn lại.
**Lý do:** Khớp với cách nhóm thực tế sẽ test (tối đa 4 điện thoại, không phải lúc nào cũng có đủ) và giữ logic phòng đơn giản — không cần xử lý các trường hợp "chờ đúng N người".
**Phương án khác đã xét:** Vào phòng bằng quét QR (không cần thiết cho một nhóm nhỏ test trực tiếp); bắt buộc đúng 4 người mới bắt đầu (loại bỏ: quá gò bó khi test lặp lại nhiều lần).

### D4 — Mô hình round tách rời khỏi đồng hồ chung
**Quyết định:** Đồng hồ chung của trận (60 giây, +5 giây mỗi đơn hoàn thành) chỉ dùng để quyết định khi nào toàn trận kết thúc. Riêng biệt, một "round" kết thúc khi **tất cả** người chơi đã hoàn thành một số lượng đơn cố định (mục tiêu: 3) của round đó; khi round kết thúc sẽ kích hoạt phân lại trạm và bắt đầu round mới.
**Lý do:** Do leader nhóm yêu cầu cụ thể, để các bản cập nhật sau có thể mở rộng hoặc cân bằng lại độ khó theo round mà không phải đụng vào logic kết thúc trận.
**Phương án khác đã xét:** Mô hình liên tục đơn giản, người chơi chỉ liên tục nhận đơn mới cho đến khi hết giờ, không có ranh giới round, khớp sát nhất với mô tả gốc trong file Word (loại bỏ theo chỉ đạo rõ ràng của leader); round theo khung thời gian cố định (ví dụ 30 giây/round bất kể đã xong hay chưa) (loại bỏ, chọn kích hoạt theo "tất cả đã xong" thay vào).

### D5 — Trạm: từ 4 trở lên, phân lại ngẫu nhiên mỗi round, có thể thiếu/trùng
**Quyết định:** Có ít nhất 4 trạm chế biến. Mỗi round, trạm được phân (lại) ngẫu nhiên cho người chơi; chấp nhận việc hai người cùng loại trạm hoặc một người không có trạm nào, kể cả khi chỉ 2-4 người.
**Lý do:** Giữ lại áp lực phối hợp cốt lõi của thiết kế gốc (có thể bạn không có trạm mình cần và phải dựa vào đồng đội) thay vì đơn giản hoá thành ánh xạ 1-1 gọn gàng làm mất đi áp lực đó.
**Phương án khác đã xét:** Ánh xạ trạm-người chơi chặt chẽ 1-1 khi số người ít (loại bỏ — rõ ràng không mong muốn).

### D6 — Dùng cảm biến: chủ yếu chạm/kéo thả, một trạm dùng lắc
**Quyết định:** Hầu hết các trạm dùng thao tác chạm/kéo thả. Đúng một trạm (bình lắc) dùng cảm biến lắc điện thoại qua `sensors_plus`. Thao tác nghiêng nằm ngoài phạm vi MVP.
**Lý do:** Giữ code liên quan đến cảm biến ở mức tối thiểu (một API nhỏ, tài liệu đầy đủ) cho người phát triển không muốn học sâu Flutter, trong khi vẫn giữ được một thao tác "đặc trưng của điện thoại" từ ý tưởng gốc. Loại bỏ nghiêng vì khó kiểm chứng trên giả lập và hoạt động không nhất quán giữa các dòng máy Android.
**Phương án khác đã xét:** Không dùng cảm biến nào (loại bỏ: sẽ mất đi phần đặc trưng của ý tưởng gốc); nhiều trạm dùng cảm biến như hình dung ban đầu — dao/thớt bằng vuốt, máy xay bằng lắc ngang, máy ép bằng chụm hai ngón, bình lắc bằng lắc dọc, rót đồ bằng nghiêng (để dành làm mục tiêu cộng thêm sau MVP).

### D7 — Công thức & độ khó: 3-5 công thức, tăng dần theo round
**Quyết định:** Một tập cố định gồm 3-5 công thức với độ phức tạp khác nhau (1 nguyên liệu/công đoạn đến nhiều nguyên liệu/nhiều trạm). Round đầu chỉ rút từ công thức dễ; round sau rút từ tập bao gồm cả công thức khó hơn.
**Lý do:** Khớp với ý định thiết kế gốc (bắt đầu dễ, khó dần về sau) trong khi vẫn đơn giản để cài đặt — một tập cố định có thứ tự/điều kiện mở khoá, không phải thuật toán scale động.
**Phương án khác đã xét:** Rút ngẫu nhiên hoàn toàn từ cả tập bất kể round nào (loại bỏ — không đảm bảo được sự khởi đầu dễ); thuật toán tăng độ khó động (loại bỏ vì thừa phức tạp cho MVP).

### D8 — Chuyền vật phẩm và nộp đơn
**Quyết định:** Vật phẩm được chuyền bằng cách vuốt trái/phải cho người liền kề trong vòng tròn. Đơn được nộp thủ công bằng cách kéo sản phẩm hoàn thành vào khung "nộp đơn" trên màn hình của chính chủ đơn.
**Lý do:** Khớp với mô hình tương tác cốt lõi của ý tưởng gốc; nộp thủ công (thay vì tự động khi nhận) cho người chơi một thao tác rõ ràng, có chủ đích, và tránh nộp nhầm khi vật phẩm chỉ đang đi qua.
**Phương án khác đã xét:** Tự động nộp khi đúng sản phẩm đến tay chủ đơn (loại bỏ — làm mất quyền chủ động của người chơi và dễ nộp nhầm).

### D9 — Ngôn ngữ tài liệu: song ngữ Anh - Việt
**Quyết định:** Toàn bộ tài liệu dự án cho package này viết song ngữ (phần tiếng Anh trước, phần tiếng Việt sau), thuật ngữ kỹ thuật giữ tiếng Anh ở cả hai phần.
**Lý do:** Yêu cầu riêng cho dự án này, ghi đè lên quy ước mặc định chỉ dùng tiếng Anh, vì tài liệu này sẽ được đồng đội nói tiếng Việt và có thể cả giảng viên đọc/review.
**Phương án khác đã xét:** Chỉ tiếng Anh (mặc định chung) — không dùng cho dự án này theo yêu cầu rõ ràng.

### D10 — Cấu trúc repo & tích hợp: chuyển sang repo phẳng `Game_Bartender` của leader
**Quyết định:** Xây dựng tính năng này trong `github.com/HoaiThuong-gif/Game_Bartender`, đặt tại `lib/games/bartender/`, theo đúng quy ước phẳng mà `lib/games/rubik/` đã dùng — không theo kế hoạch `packages/` monorepo với interface `MiniGame` trước đó. Tích hợp với phần còn lại của app là một điểm vào duy nhất `BartenderScreen`, nối vào callback `onBartenderTap` đã có sẵn trong `lib/screens/home/lobby_screen.dart`.
**Lý do:** Nhóm quyết định dùng repo thật của leader thay vì repo tạm trước đó. Repo đó đã có sẵn tính năng Rubik hoạt động đáng kể, xây trên cấu trúc phẳng `lib/games/<name>/` không có interface plugin, và lobby đã có sẵn điểm chạm tạm cho Bartender — theo đúng quy ước có sẵn này ít công sức hơn nhiều và dễ cho leader review hơn so với đưa thêm một hệ thống monorepo/package mới vào một app đã phát triển.
**Phương án khác đã xét:** Giữ kế hoạch `packages/` + `game_api`/`MiniGame` gốc và yêu cầu nhóm cấu trúc lại repo thật cho khớp (loại bỏ — repo thật đã xây quanh một quy ước khác, đang hoạt động; cấu trúc lại sẽ gây xáo trộn và không phải quyết định một người có thể tự đưa ra).

### D11 — Format tài liệu: giữ quy ước cá nhân thay vì kiểu tường thuật của nhóm
**Quyết định:** Tài liệu của tính năng này vẫn giữ theo cách chia README/PROJECT_SPEC/ARCHITECTURE/DECISIONS/API/DEVELOPMENT của người phát triển, dù phần còn lại của repo ghi tài liệu theo kiểu một file tường thuật dài cho mỗi tính năng (ví dụ `docs/rubik-foundation.md`, `docs/lobby.md`).
**Lý do:** Yêu cầu rõ ràng từ người phát triển — sự quen thuộc và phụ thuộc vào đúng cấu trúc tài liệu này khi làm việc với coding agent quan trọng hơn việc khớp theo style tài liệu có sẵn của repo cho riêng tính năng này.
**Phương án khác đã xét:** Theo kiểu một file tường thuật như nhóm (dễ review cùng các docs có sẵn hơn, nhưng bị loại bỏ theo yêu cầu rõ ràng); kết hợp cả hai kiểu (không chọn).
