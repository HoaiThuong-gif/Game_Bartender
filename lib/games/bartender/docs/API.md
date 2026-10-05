# API — Firebase Realtime Database schema

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
        ringIndex: int             # 0-based position in the ring; fixed within a round, compacted at round boundaries (D14)
        connected: bool            # false after leaving or dropping (RTDB onDisconnect)
        completedOrders: int       # personal counter, for ranking

    timer/
      endTime: <server timestamp>  # absolute time the match ends
      startedAt: <server timestamp>

    round/
      number: int                  # 1, 2, 3, ...
      ordersPerPlayer: int         # target, e.g. 3
      stationAssignment/
        {ringIndex}: string        # station id, e.g. "blender" — key may be absent for a player with no station
      progress/
        {ringIndex}: int           # orders this player has completed in the CURRENT round; round ends when progress[ringIndex] >= ordersPerPlayer for every ringIndex of a CONNECTED player

    orders/
      {playerId}/
        {orderId}/
          recipeId: string
          status: "pending" | "submitted"

    inbox/
      {ringIndex}/
        {itemId}/
          type: "ingredient" | "product"
          itemId: string            # references a recipe/ingredient definition
          fromRingIndex: int

    results/                        # written once, BEFORE status becomes "ended" (D17)
      totalSurvivalSeconds: int
      totalTeamOrders: int
      ranking: [ { playerId, completedOrders } ]  # sorted descending
```

### Notes
- `{playerId}` is the Firebase Anonymous Auth `uid` of the phone. There is no `totalPlayers` field: the ring size is the number of players in `players` when the match starts (D13).
- A room holds 2–4 players (D13). `joinRoom` is only allowed while `status == "lobby"` and the room already exists; it assigns `ringIndex` inside a transaction on `players` so two simultaneous joins never get the same position.
- `players/{playerId}/ringIndex` is assigned at join time and stays fixed **within a round**, so ring math (`(index ± 1) mod playerCount`) is stable while items are in flight. A player who drops gets `connected: false` and does not block the round. At the next round boundary, disconnected players are removed from `players` and the remaining `ringIndex` values are compacted to `0..k-1` in the same order; the remaining players' inbox contents move with them (D14). If fewer than 2 connected players remain while `playing`, the match ends. A client that regains its connection before the boundary sets `connected` back to `true` (`.info/connected`, re-arming `onDisconnect`). In the lobby a player who leaves is deleted, and `startMatch` compacts `ringIndex` to `0..k-1` over the connected players, so gaps left by leavers never reach the match.
- Round advance has no host (D17): any client that observes "all connected players done" runs a transaction on `round` that only commits if `round/number` is still the observed value; the single winner writes the new `round` node in that transaction, then one multi-path update with the new `orders`, the compacted `players`/`ringIndex`, and the `inbox`. Clients must tolerate the short gap where `round` is new but `orders`/`players` are not yet updated.
- `timer/endTime` is the only value clients need to poll/derive the countdown from; do not write a per-second tick to the database. `createdAt` and `startedAt` are written with `ServerValue.timestamp`; `endTime` is computed from the client clock corrected by `.info/serverTimeOffset` (`ARCHITECTURE.md`), and each submitted order adds its bonus with `ServerValue.increment`.
- `round/stationAssignment` is fully rewritten (not merged) whenever a round ends, since every player's station changes at once. Orders are only drawn from recipes that the new assignment can actually make (D15).
- Firebase returns a node whose keys are consecutive integers (`0, 1, 2…`) as a **List** instead of a Map. `inbox`, `progress` and `stationAssignment` are keyed by `ringIndex`, so every read must accept both shapes.
- `round/progress` is the single source of truth for round completion — do not derive it by scanning `orders/*/status`; submitting an order increments `round/progress/{ringIndex}` by 1 (`ServerValue.increment`) in the same multi-path update that marks the order `submitted`, bumps `completedOrders` and `timer/endTime`, and removes the product from the inbox. A repeated submit of the same `orderId` must be ignored (guard with a transaction on the order's `status`). This keeps the "has everyone finished this round?" check a single read of one small map instead of a scan across every player's order list.
- Match end (D17): the first client whose transaction on `results` commits writes `results`, then sets `status` to `ended`; other clients' attempts do nothing.
- Recipes themselves (`recipeId` → list of required ingredients/steps) are **not** stored in Firebase — they are static data bundled in the app (see `models/recipe.dart`), since they never change during a match. Only the *reference* (`recipeId`) is written to the database.

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