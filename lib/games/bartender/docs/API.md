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
      progress/
        {ringIndex}: int           # orders this player has completed in the CURRENT round; round ends when progress[ringIndex] == ordersPerPlayer for every ringIndex in the room

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

    results/                        # written once when status becomes "ended"
      totalSurvivalSeconds: int
      totalTeamOrders: int
      ranking: [ { playerId, completedOrders } ]  # sorted descending
```

### Notes
- `players/{playerId}/ringIndex` is assigned at room-creation/join time and does not change mid-match, so ring math (`(index ± 1) mod playerCount`) stays stable even if a player disconnects (`connected: false` — the slot is not removed, to avoid renumbering everyone else's ring position mid-match).
- `timer/endTime` is the only value clients need to poll/derive the countdown from; do not write a per-second tick to the database.
- `round/stationAssignment` is fully rewritten (not merged) whenever a round ends, since every player's station changes at once.
- `round/progress` is the single source of truth for round completion — do not derive it by scanning `orders/*/status`; submitting an order increments `round/progress/{ringIndex}` by 1 in the same write. This keeps the "has everyone finished this round?" check a single read of one small map instead of a scan across every player's order list.
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