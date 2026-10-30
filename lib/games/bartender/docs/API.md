# API — Bartender HTTP + WebSocket (replaces the Firebase schema)

Base URL: `https://<service>.onrender.com` (set in `BartenderConfig.apiBaseUrl`). JSON, UTF-8.
Rooms live in server memory and are lost on restart.

## Identity
`POST /rooms` and `POST /rooms/{code}/join` return `playerId` and `playerToken`.
Every other call sends `Authorization: Bearer <playerToken>`.
WebSocket sends the token as a query parameter: `?token=<playerToken>`.
The server derives the acting player (and its `ringIndex`) from the token; clients never send their own ringIndex.

## Errors
HTTP status plus body `{ "error": { "code": "<CODE>", "message": "<text>" } }`.
| Code | HTTP | Meaning |
|---|---|---|
| INVALID_REQUEST | 400 | Missing or malformed field (empty name, bad station...) |
| UNAUTHORIZED | 401 | Missing/unknown token, or token not in this room |
| ROOM_NOT_FOUND | 404 | No room with this code |
| ITEM_NOT_FOUND | 404 | Item not in the caller's inbox |
| ROOM_FULL | 409 | Room already has 4 players (D13) |
| ROOM_NOT_JOINABLE | 409 | Room status is not `lobby` |
| NOT_ENOUGH_PLAYERS | 409 | Fewer than 2 connected players on start |
| INVALID_STATE | 409 | Action not allowed in the current status |
| INVALID_MOVE | 422 | Not an adjacent player, wrong station, no such recipe step (D19) |
| ORDER_MISMATCH | 422 | Product does not match the order's recipe, or order already submitted |

## Room snapshot (shared by all responses that return `room`, and by WebSocket messages)
```json
{
  "code": "4821",
  "status": "lobby | playing | ended",
  "serverNowMs": 1760000000000,
  "players": { "<playerId>": { "id": "...", "name": "An", "ringIndex": 0, "connected": true, "completedOrders": 0 } },
  "timer": { "startedAt": 0, "endTime": 0 },
  "currentRound": {
    "number": 1,
    "ordersPerPlayer": 3,
    "stationAssignment": { "0": "blender", "1": "juicer" },
    "progress": { "0": 1, "1": 0 },
    "playerOrders": { "<playerId>": [ { "id": "...", "recipeId": "...", "status": "pending | submitted" } ] }
  },
  "inbox": { "0": [ { "id": "...", "type": "ingredient | product", "itemId": "...", "fromRingIndex": 1 } ] },
  "results": { "totalSurvivalSeconds": 0, "totalTeamOrders": 0, "ranking": [ { "playerId": "...", "name": "...", "completedOrders": 0 } ] }
}
```
`timer`, `currentRound`, `results` are `null` until they exist. Map keys keyed by ringIndex are strings.
Clients compute `serverOffsetMs = serverNowMs - localNowMs` when a snapshot arrives (feeds `MatchTimer`).
Station values: `cuttingBoard`, `blender`, `juicer`, `shaker`.

## Endpoints
| Method + path | Body | Success |
|---|---|---|
| `POST /rooms` | `{ "playerName": "An" }` | 201 `{ room, playerId, playerToken }` (new unique 4-digit code) |
| `POST /rooms/{code}/join` | `{ "playerName": "Binh" }` | 200 `{ room, playerId, playerToken }` |
| `POST /rooms/{code}/leave` | none | 204. Lobby: player removed. Playing: `connected=false`. Empty room is deleted |
| `POST /rooms/{code}/start` | none | 204. Needs status `lobby` and >= 2 connected players. Any player may call it; repeated calls are ignored |
| `GET /rooms/{code}` | none | 200 `{ room }` (for reconnecting) |
| `POST /rooms/{code}/items/send` | `{ "itemId": "<instance id>", "toRingIndex": 1 }` | 204. Target must be adjacent in the ring |
| `POST /rooms/{code}/items/trash` | `{ "itemId": "<instance id>" }` | 204 |
| `POST /rooms/{code}/items/process` | `{ "itemId": "<instance id>", "station": "blender" }` | 200 `{ item }` (the processed item). Station must match the caller's assignment |
| `POST /rooms/{code}/orders/submit` | `{ "orderId": "...", "itemId": "<product instance id>" }` | 204. Adds time bonus, bumps progress |
| `GET /health` | none | 200 `{ "status": "ok", "rooms": 3, "timeMs": 0 }` (no token) |

There is no `endMatch` endpoint: the server ends the match.

## WebSocket `GET /rooms/{code}/ws?token=...`
- On connect the server sends `{ "type": "snapshot", "room": { ... } }`, then a new snapshot after every change in that room.
- Client sends nothing required. Server sends `{ "type": "ping" }` every 25 s; client may answer `{ "type": "pong" }`.
- Close codes: 4401 bad token, 4404 room not found.
- When a player's last socket closes: `connected=false`. A new socket with the same token sets it back to `true`.

## Server-side rules (replace D17)
- All state changes for one room run one at a time, so no transactions are needed.
- Round advance: when every connected player has `progress >= ordersPerPlayer`, the server compacts players (drops disconnected ones, D14), assigns stations, creates winnable orders (D13, D15, D16) and refills inboxes in one step.
- Match end: when the timer expires, or fewer than 2 connected players remain, the server writes `results` first, then sets status `ended`.
- Cleanup: ended rooms are deleted after 10 minutes; lobby rooms with no connected player after 30 minutes.

## Curl smoke test
```
curl https://<service>.onrender.com/health
curl -X POST https://<service>.onrender.com/rooms -H "Content-Type: application/json" -d '{"playerName":"Test"}'
curl https://<service>.onrender.com/rooms/<code> -H "Authorization: Bearer <playerToken>"
```