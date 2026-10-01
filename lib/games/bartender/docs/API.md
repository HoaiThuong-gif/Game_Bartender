# API — Firebase Realtime Database schema

## English

> Added beyond the required doc set because the game's core mechanics (item passing, shared timer, round state) depend entirely on this schema being consistent across all clients. Documenting it here avoids re-deriving it from code and keeps `ARCHITECTURE.md` free of implementation-level detail.

### Root structure
```
rooms/
  {roomCode}/                     # e.g. "4821"
    createdAt: <server timestamp>
    status: "lobby" | "playing" | "ended"

    players/
      {playerId}/
        name: string
        ringIndex: int             # 0-based position in the ring
        connected: bool
        completedOrders: int       # personal counter, for ranking

    timer/
      endTime: <server timestamp>  # absolute time the match ends
      startedAt: <server timestamp>

    round/
      number: int                  # 1, 2, 3, ...
      ordersPerPlayer: int         # target, e.g. 3
      stationAssignment/
        {ringIndex}: string        # station id, e.g. "blender" — key may be absent for a player with no station

    orders/
      {playerId}/
        {orderId}/
          recipeId: string
          completedCount: int       # how many of this round's orders this player has finished so far
          status: "pending" | "submitted"

    inbox/
      {ringIndex}/
        {itemId}/
          type: "ingredient" | "product"
          itemId: string            # references a recipe/ingredient definition
          fromRingIndex: int

    results/                        # written once when status becomes "ended"
      totalSurvivalSeconds: int
      totalTeamOrders: int
      ranking: [ { playerId, completedOrders } ]  # sorted descending
```

### Notes
- `players/{playerId}/ringIndex` is assigned at room-creation/join time and does not change mid-match, so ring math (`(index ± 1) mod playerCount`) stays stable even if a player disconnects (`connected: false` — the slot is not removed, to avoid renumbering everyone else's ring position mid-match).
- `timer/endTime` is the only value clients need to poll/derive the countdown from; do not write a per-second tick to the database.
- `round/stationAssignment` is fully rewritten (not merged) whenever a round ends, since every player's station changes at once.
- Recipes themselves (`recipeId` → list of required ingredients/steps) are **not** stored in Firebase — they are static data bundled in the app (see `domain/models/recipe.dart`), since they never change during a match. Only the *reference* (`recipeId`) is written to the database.

### Security Rules (MVP-level)
For MVP, rules only need to prevent a client from writing into another room's or player's slot arbitrarily; they are not meant to fully prevent cheating (see `ARCHITECTURE.md`, Trade-offs). A minimal example:
```json
{
  "rules": {
    "rooms": {
      "$roomCode": {
        ".read": true,
        ".write": true
      }
    }
  }
}
```
This should be tightened (e.g. requiring Firebase Anonymous Auth and matching `auth.uid` to `playerId`) before any public deployment, but is acceptable for a supervised classroom demo.

## Tiếng Việt

> Thêm ngoài bộ tài liệu bắt buộc vì các cơ chế cốt lõi của game (chuyền vật phẩm, đồng hồ chung, trạng thái round) phụ thuộc hoàn toàn vào việc schema này nhất quán giữa mọi client. Ghi lại ở đây để tránh phải suy ngược từ code, và giữ cho `ARCHITECTURE.md` không lẫn quá nhiều chi tiết cấp implementation.

### Cấu trúc gốc
```
rooms/
  {roomCode}/                     # ví dụ "4821"
    createdAt: <server timestamp>
    status: "lobby" | "playing" | "ended"

    players/
      {playerId}/
        name: string
        ringIndex: int             # vị trí trong vòng tròn, bắt đầu từ 0
        connected: bool
        completedOrders: int       # bộ đếm cá nhân, dùng để xếp hạng

    timer/
      endTime: <server timestamp>  # mốc thời gian tuyệt đối khi trận kết thúc
      startedAt: <server timestamp>

    round/
      number: int                  # 1, 2, 3, ...
      ordersPerPlayer: int         # mục tiêu, ví dụ 3
      stationAssignment/
        {ringIndex}: string        # id trạm, ví dụ "blender" — có thể vắng mặt với người không có trạm

    orders/
      {playerId}/
        {orderId}/
          recipeId: string
          completedCount: int       # số đơn đã hoàn thành trong round này của người chơi đó
          status: "pending" | "submitted"

    inbox/
      {ringIndex}/
        {itemId}/
          type: "ingredient" | "product"
          itemId: string            # tham chiếu đến định nghĩa nguyên liệu/công thức
          fromRingIndex: int

    results/                        # ghi một lần khi status chuyển thành "ended"
      totalSurvivalSeconds: int
      totalTeamOrders: int
      ranking: [ { playerId, completedOrders } ]  # sắp giảm dần
```

### Ghi chú
- `players/{playerId}/ringIndex` được gán lúc tạo/vào phòng và không đổi trong suốt trận, nên toán vòng tròn (`(index ± 1) mod playerCount`) luôn ổn định kể cả khi có người thoát (`connected: false` — không xoá slot, để tránh phải đánh số lại vị trí của tất cả người khác giữa trận).
- `timer/endTime` là giá trị duy nhất client cần đọc/tính đồng hồ đếm ngược từ đó; không ghi tick từng giây vào database.
- `round/stationAssignment` được ghi đè toàn bộ (không merge) mỗi khi round kết thúc, vì trạm của mọi người đổi cùng lúc.
- Bản thân công thức (`recipeId` → danh sách nguyên liệu/công đoạn cần) **không** lưu trong Firebase — đây là dữ liệu tĩnh đóng gói sẵn trong app (xem `domain/models/recipe.dart`), vì không đổi trong suốt trận. Chỉ có *tham chiếu* (`recipeId`) được ghi vào database.

### Security Rules (mức MVP)
Với MVP, rules chỉ cần ngăn một client ghi tuỳ tiện vào phòng hoặc slot người chơi khác; không nhằm chống gian lận hoàn toàn (xem phần Đánh đổi trong `ARCHITECTURE.md`). Ví dụ tối thiểu:
```json
{
  "rules": {
    "rooms": {
      "$roomCode": {
        ".read": true,
        ".write": true
      }
    }
  }
}
```
Nên siết chặt lại (ví dụ yêu cầu Firebase Anonymous Auth và khớp `auth.uid` với `playerId`) trước khi triển khai công khai, nhưng chấp nhận được cho một buổi demo trong lớp có giám sát.
