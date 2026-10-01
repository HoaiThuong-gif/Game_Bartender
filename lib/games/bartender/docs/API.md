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