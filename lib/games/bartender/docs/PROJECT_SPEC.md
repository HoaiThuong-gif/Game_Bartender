# PROJECT_SPEC — game_kitchen

## English

### Goals
- Deliver a working, demoable multiplayer cooperative drink-making mini-game as one of the 4 mini-games required by the course assignment.
- Run reliably on the team's own devices for the MVP: **2 to 4 players**, Android-first, iOS as a stretch goal.
- Fit into the shared Flutter repo (`Game_Bartender`) as an isolated feature under `lib/games/bartender/`, following the same flat convention already used by `lib/games/rubik/`, so the other mini-games (including the mandatory Rubik solver) can be developed independently.
- Keep the implementation simple enough for a first-time mobile developer to build with the help of a coding agent, working from this documentation.

### Non-goals (MVP)
- No matchmaking beyond joining by a room code.
- No server-authoritative anti-cheat logic (client-trusted gameplay is acceptable for this project).
- No tilt-based station interaction (only touch/drag + one shake-based station).
- No testing or guaranteed support beyond 4 concurrent players (design supports up to 10 per the original concept, but only 2–4 is verified).
- No persistence of match history beyond the current match's end screen.
- No login/accounts — players are identified only by their display name and ring position within a room.
- No in-app purchases or monetization.
- No dynamic/algorithmic difficulty scaling — difficulty progression is achieved by drawing from a fixed pool of recipes ordered from easy to hard, not by a scaling formula.

### Users
- The team's own 4 members, using their personal phones (3 Android, 1 iOS) to demo the game to the instructor.
- Secondary: the course instructor, who will play or observe a demo session.

### Requirements

**Room & players**
- A player creates a room and receives a generated room code (e.g. 4 digits); other players join by entering that code.
- Players are assigned a sequential position (1, 2, 3, ...) forming a ring.
- A match can start once **2 or more** players are in the room (does not require all 4).
- If a player disconnects mid-match, the match continues with the remaining players.

**Match loop**
- A match has one shared countdown timer, starting at 60 seconds. It only serves to **end the match** when it reaches 0.
- Completing any order (by its owner) adds +5 seconds to the shared timer and gives that player +1 personal completed order.
- The match is organized into **rounds**, independent from the shared timer:
  - Each round, every player receives a **fixed number of orders (target: 3)** to complete.
  - A round ends only when **all** players in the room have completed their round's orders.
  - When a round ends: processing stations are **reassigned randomly** among players, and a new round begins with a fresh set of orders.
- Recipe difficulty increases by round: early rounds draw only from easy recipes (1 ingredient / 1 step); later rounds draw from a pool that includes harder recipes (multiple ingredients, multiple stations). The recipe pool has **3 to 5 recipes** total.

**Stations**
- At least **4** processing stations exist (recipe-dependent; conceptually knife/cutting board, blender, juicer, shaker, etc.).
- Each round, stations are assigned randomly to players. Unlike the original 10-player design, duplicate or missing station assignment can still occur even at 2–4 players (assignment is not forced to be 1-to-1).
- Each player's screen shows **one fixed station** for that round (the one assigned to them).

**Ingredients & items**
- Ingredients spawn on player screens periodically (~every 3 seconds).
- Each screen has a trash bin; players can drag unwanted ingredients there to clear space.
- Items (ingredients or partially/fully processed products) are passed by **swiping left or right**, sending the item to the adjacent player in the ring (wrap-around at the ends).

**Order submission**
- A player submits a completed order by **dragging the finished product into a "submit" zone** on their own screen. Submission is a manual action, not automatic on receipt.

**Sensors & feedback**
- Most stations use touch/drag interactions.
- At least one station (the shaker) uses phone-shake detection via `sensors_plus`.
- Haptic feedback (vibration) on key events: receiving an item, completing a processing step, submitting an order, and low time remaining.

**End of match**
- When the shared timer reaches 0, the match ends for the whole room.
- Show a results screen: total survival time, total team orders completed, and a per-player ranking by personal completed orders.

### Constraints
- **Team/tech constraint:** must be built as an isolated feature under `lib/games/bartender/`, integrating with the rest of the app only through the single `BartenderScreen` entry point and the `onBartenderTap` wiring in `lobby_screen.dart` — no direct dependency on `lib/games/rubik/` or other mini-games.
- **Cost constraint:** student project, backend must run on a free tier (Firebase Realtime Database Spark plan).
- **Platform constraint:** the team's iOS user has no Mac available; Android is the primary target, iOS build is attempted later if time allows.
- **Developer experience constraint:** the developer is building their first mobile app and does not intend to deeply learn Dart/Flutter; implementation work is expected to be done by a coding agent following this documentation, with the developer running, testing, and reviewing on real devices.
- **Device constraint:** sensor-based interactions (shake) must be verified on a real device — simulators/emulators cannot reliably test this.

## Tiếng Việt

### Mục tiêu
- Hoàn thành một mini-game pha chế nhiều người chơi có thể chạy demo được, là một trong 4 mini-game theo yêu cầu môn học.
- Chạy ổn định trên chính thiết bị của nhóm cho bản MVP: **2 đến 4 người chơi**, ưu tiên Android, iOS là mục tiêu cộng thêm.
- Nằm trong repo Flutter dùng chung (`Game_Bartender`) dưới dạng một tính năng độc lập trong `lib/games/bartender/`, theo đúng quy ước phẳng mà `lib/games/rubik/` đã dùng, để các mini-game còn lại (kể cả trò giải Rubik bắt buộc) có thể phát triển độc lập.
- Giữ độ phức tạp đủ đơn giản để một người lần đầu làm mobile app có thể hoàn thành với sự hỗ trợ của coding agent, dựa theo bộ tài liệu này.

### Ngoài phạm vi (MVP)
- Không có matchmaking ngoài việc vào phòng bằng mã.
- Không có logic chống gian lận phía server (chấp nhận tin tưởng client cho đồ án này).
- Không dùng thao tác nghiêng (tilt) cho trạm nào, chỉ chạm/kéo thả và một trạm dùng lắc.
- Không kiểm thử hay đảm bảo hoạt động với hơn 4 người chơi cùng lúc (thiết kế gốc hỗ trợ đến 10 người, nhưng chỉ 2-4 người được xác nhận hoạt động).
- Không lưu lại lịch sử trận đấu ngoài màn hình kết quả của trận hiện tại.
- Không có đăng nhập/tài khoản — người chơi chỉ được nhận diện bằng tên hiển thị và vị trí trong vòng tròn của phòng.
- Không có mua hàng trong ứng dụng.
- Không tăng độ khó theo công thức/thuật toán — độ khó tăng dần bằng cách rút từ một tập công thức cố định được sắp từ dễ đến khó, không phải bằng công thức scale động.

### Người dùng
- 4 thành viên của nhóm, dùng điện thoại cá nhân (3 Android, 1 iOS) để demo cho giảng viên.
- Phụ: giảng viên, người sẽ chơi thử hoặc xem demo.

### Yêu cầu chức năng

**Phòng & người chơi**
- Một người tạo phòng và nhận được mã phòng được sinh ra (ví dụ 4 số); người khác vào phòng bằng cách nhập mã đó.
- Người chơi được gán vị trí tuần tự (1, 2, 3, ...) tạo thành một vòng tròn.
- Trận có thể bắt đầu khi có **từ 2 người trở lên** trong phòng (không bắt buộc đủ 4).
- Nếu một người thoát giữa trận, trận vẫn tiếp tục với những người còn lại.

**Vòng lặp trận đấu**
- Trận có một đồng hồ đếm ngược chung, bắt đầu ở 60 giây. Đồng hồ này chỉ dùng để **kết thúc trận** khi về 0.
- Hoàn thành bất kỳ đơn nào (bởi chủ đơn) cộng +5 giây vào đồng hồ chung, và +1 đơn cá nhân cho người đó.
- Trận được tổ chức theo **round**, độc lập với đồng hồ chung:
  - Mỗi round, mỗi người nhận **một số đơn cố định (mục tiêu: 3)** cần hoàn thành.
  - Round chỉ kết thúc khi **tất cả** người chơi trong phòng đã hoàn thành hết đơn của round đó.
  - Khi round kết thúc: các trạm chế biến được **phân lại ngẫu nhiên** giữa các người chơi, và một round mới bắt đầu với bộ đơn mới.
- Độ khó công thức tăng theo round: round đầu chỉ rút từ công thức dễ (1 nguyên liệu / 1 công đoạn); round sau rút từ tập bao gồm cả công thức khó hơn (nhiều nguyên liệu, nhiều trạm). Tập công thức có tổng cộng **3 đến 5 công thức**.

**Trạm chế biến**
- Có ít nhất **4** trạm chế biến (tuỳ theo công thức; về mặt khái niệm gồm dao/thớt, máy xay, máy ép, bình lắc, v.v.).
- Mỗi round, trạm được phân ngẫu nhiên cho người chơi. Khác với thiết kế gốc cho 10 người, việc thiếu hoặc trùng trạm vẫn có thể xảy ra dù chỉ 2-4 người (không bắt buộc phân theo kiểu 1-1).
- Màn hình của mỗi người chỉ hiển thị **một trạm cố định** cho round đó (trạm được phân cho họ).

**Nguyên liệu & vật phẩm**
- Nguyên liệu xuất hiện trên màn hình người chơi theo chu kỳ (khoảng 3 giây một lần).
- Mỗi màn hình có một thùng rác; người chơi có thể kéo nguyên liệu không cần dùng vào đó để giải phóng không gian.
- Vật phẩm (nguyên liệu hoặc sản phẩm đã/đang chế biến) được chuyền bằng cách **vuốt trái hoặc phải**, gửi cho người liền kề trong vòng tròn (người ở đầu/cuối nối vòng với nhau).

**Nộp đơn**
- Người chơi nộp đơn đã hoàn thành bằng cách **kéo sản phẩm vào khung "nộp đơn"** trên màn hình của chính mình. Nộp đơn là thao tác thủ công, không tự động khi nhận được sản phẩm.

**Cảm biến & phản hồi**
- Hầu hết các trạm dùng thao tác chạm/kéo thả.
- Ít nhất một trạm (bình lắc) dùng cảm biến lắc điện thoại qua `sensors_plus`.
- Rung phản hồi (haptic) cho các sự kiện chính: nhận vật phẩm, hoàn thành công đoạn, nộp đơn, và khi sắp hết giờ.

**Kết thúc trận**
- Khi đồng hồ chung về 0, trận kết thúc cho toàn bộ phòng.
- Hiển thị màn hình kết quả: tổng thời gian sống sót, tổng số đơn cả đội đã hoàn thành, và bảng xếp hạng cá nhân theo số đơn đã hoàn thành.

### Ràng buộc
- **Ràng buộc nhóm/kỹ thuật:** phải xây dựng như một tính năng độc lập trong `lib/games/bartender/`, chỉ tích hợp với phần còn lại của app qua điểm vào duy nhất `BartenderScreen` và việc nối `onBartenderTap` trong `lobby_screen.dart` — không phụ thuộc trực tiếp vào `lib/games/rubik/` hay mini-game khác.
- **Ràng buộc chi phí:** đồ án sinh viên, backend phải chạy trên gói miễn phí (Firebase Realtime Database gói Spark).
- **Ràng buộc nền tảng:** người dùng iOS trong nhóm không có Mac; Android là mục tiêu chính, build iOS thử sau nếu còn thời gian.
- **Ràng buộc kinh nghiệm người phát triển:** đây là lần đầu làm mobile app, và không có ý định học sâu Dart/Flutter; phần code dự kiến do coding agent thực hiện dựa theo bộ tài liệu này, người phát triển chịu trách nhiệm chạy, test và review trên thiết bị thật.
- **Ràng buộc thiết bị:** các thao tác dùng cảm biến (lắc) phải được kiểm chứng trên thiết bị thật — giả lập không test đáng tin cậy được.
