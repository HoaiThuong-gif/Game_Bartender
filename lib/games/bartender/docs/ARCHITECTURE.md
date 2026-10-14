# ARCHITECTURE — game_kitchen (Bartender)

### Position in the app
Unlike an earlier plan that assumed a `packages/` monorepo with a shared `MiniGame` plugin interface, the actual repo (`Game_Bartender`) uses a **flat structure**: every game lives directly under `lib/games/<name>/`, and the lobby screen imports and navigates to each game's entry screen directly. This mirrors `lib/games/rubik/` exactly.

```dart
// lib/screens/home/lobby_screen.dart (existing file, shared)
_game(
  LobbyLayout.bartender,
  'Quầy Bartender',
  onBartenderTap ?? () => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const BartenderScreen()),
  ),
),
```
`BartenderScreen` (in `lib/games/bartender/screens/`) is the single entry point this feature exposes to the rest of the app — everything else in `lib/games/bartender/` is private to this feature and not imported from outside it.

### Internal layers
Inside `lib/games/bartender/`, the same three-layer split from the original plan is kept — it is an internal convention of this feature, not something the rest of the repo enforces, but it keeps gameplay logic testable and keeps the backend swappable.

```
lib/games/bartender/
├── models/        # Pure Dart — no Flutter, no Firebase imports
│                   # Player, Room, Order, Recipe, Station, Round, ring math
├── services/
│   ├── room_repository.dart          # Abstract interface
│   ├── firebase_room_repository.dart # Real implementation (RTDB)
│   └── fake_room_repository.dart     # In-memory implementation for local dev
├── controllers/   # Round/timer state management — reads/writes via RoomRepository,
│                   # exposes state to widgets (similar role to game_kitchen's old
│                   # "domain/rules" + Rubik's CubeInputController pattern)
├── widgets/        # Station widgets, swipe targets, trash bin, order tray
└── screens/         # BartenderScreen, lobby/waiting, match, results
```

This follows the naming style already used by `lib/games/rubik/` (`models/`, `services/`, `controllers/`, `widgets/`, `screens/`) rather than the earlier `domain/data/presentation` naming, so the two features read consistently to anyone browsing the repo.

**`models/`** contains the game rules described in `PROJECT_SPEC.md`: ring position math (`(index ± 1) mod playerCount`), round completion checks, station reassignment together with winnable order generation (D15), recipe/difficulty selection, and timer bonus rules — plain Dart, unit-testable without a device or emulator, same as Rubik's `CubeState`/`CubeValidationService`.

**`services/`** exposes one interface, `RoomRepository`, with methods such as `createRoom()`, `joinRoom(code)`, `submitOrder(...)`, `sendItem(...)`, `watchRoom(code)` (a stream of room state), plus `endMatch(code)` and a `localPlayerId` getter (the id of the player on this device: `p_0`-style in the fake, the anonymous Auth `uid` in Firebase). Two implementations exist, same reasoning as Rubik keeping scanning and solving behind interfaces (`CubeScanner`, `CubeSolver`):
- `FakeRoomRepository` — in-memory, used for early development and testing without any backend.
- `FirebaseRoomRepository` — talks to Firebase Realtime Database for real multi-device play.

**`controllers/`** and **`widgets/`/`screens/`** only depend on `models/` and the `RoomRepository` interface — never directly on Firebase. Switching backend later only requires a new `services/` implementation, not a UI rewrite.

### Data flow (per round)

```mermaid
sequenceDiagram
    participant P1 as Player 1
    participant P2 as Player 2 (adjacent)
    participant RTDB as Firebase RTDB
    P1->>RTDB: sendItem(toIndex: 2, item)
    RTDB-->>P2: room/{code}/inbox/2 updated
    P2->>P2: process item at assigned station
    P2->>RTDB: sendItem(toIndex: 1, finishedProduct)
    RTDB-->>P1: room/{code}/inbox/1 updated
    P1->>RTDB: submitOrder(orderId) — one multi-path update
    Note over P1,RTDB: order status, round/progress +1, completedOrders +1, timer.endTime +5s (ServerValue.increment)
    RTDB-->>P2: every client observes the new room state
    P2->>RTDB: if all connected players are done: transaction on round (D17)
    Note over P2,RTDB: only one client wins; it writes new orders, compacts the ring (D14), refills the inbox
```

### Firebase Realtime Database usage
- No other feature in this repo uses Firebase yet (`pubspec.yaml` currently has no `firebase_*` packages) — this feature will be the first to add it. Flag this to the team so adding the Firebase config files doesn't surprise anyone touching `android/`/`ios/`.
- Chosen because it requires no backend server, has a free tier well above this project's expected load, and has first-class Flutter support (FlutterFire).
- The shared timer is synced as an absolute `endTime` timestamp (not a per-second countdown stream), with each client computing remaining time locally and correcting for clock drift using Firebase's `.info/serverTimeOffset`.
- Item passing uses a small per-player "inbox" node so each client only listens to its own inbox, not the whole room state.
- There is no server-side logic: the "is the round finished?" check and the round/match transitions run on the clients and are made safe by transactions (D17).
- Players are identified by a Firebase **Anonymous Auth** `uid` used as `playerId` (no login screen, no accounts). Anonymous sign-in must be enabled in the Firebase console.
- Full schema is documented in `API.md`.

### Technologies
| Concern | Choice | Why |
|---|---|---|
| UI framework | Flutter | Fixed by the overall project |
| Realtime sync | Firebase Realtime Database | No server to host/maintain, free tier is enough, good Flutter support, first feature to add it |
| Player identity | `firebase_auth` (anonymous) | Gives each phone a unique `playerId` without any login UI |
| Shake detection | `sensors_plus` | Standard, well-documented Flutter package, not yet in `pubspec.yaml` |
| Haptics | `HapticFeedback` (Flutter built-in) or `vibration` package | Simple event-based feedback |

### Visual assets
No custom art is drawn for this feature. All visuals are free, pre-made, CC0 or permissively-licensed pixel-art (16x16 style) packs, stored under `assets/images/bartender/` (parallel to the leader's existing `assets/images/lobby/`) and declared in the repo-root `pubspec.yaml` under `flutter: assets:`.

| Asset type | Source | License |
|---|---|---|
| Fruits / ingredients | [Free Pixel Fruits & Vegetables](https://infpixel.itch.io/pixelfruitsvegetables) (infpixel, itch.io) | Free, commercial use allowed, credit optional |
| Drinks, bottles, kitchen items | [Kenney — Generic Items](https://opengameart.org/node/64179) | CC0 |
| Stations / kitchen furniture | [Kenney — Roguelike Indoor pack](https://opengameart.org/content/roguelike-indoor-pack) | CC0 |
| UI buttons / panels | [Kenney — UI Pack Adventure](https://opengameart.org/content/ui-pack-adventure) | CC0 |
| Background | [Kenney — Background elements](https://opengameart.org/content/background-elements) | CC0 |

None of these require attribution, though crediting "Kenney.nl" where Kenney packs are used is appreciated. This pixel-art style is visually distinct from the lobby's hand-drawn style — see `DECISIONS.md` (D12) for why that trade-off was accepted.

### Trade-offs
- **No authoritative server:** game logic runs on each client; Firebase Security Rules provide only basic write validation, not full anti-cheat. Accepted because this is a student demo, not a public game.
- **RTDB over Firestore:** lower latency for frequent small updates (item passing), free tier billed by connections/bandwidth rather than per operation.
- **Round model adds a second piece of state on top of the shared timer:** explicit request from the team lead so future updates (harder rounds, more mechanics) can extend round logic without touching match-ending timer logic.
- **Duplicate/missing station assignment kept even at 2–4 players:** intentionally keeps the "sometimes you have no station and must rely on teammates" tension from the original design. It is bounded by D15 (every round must be winnable) and D16 (no recipe needs more than 3 stations).
- **Touching `lobby_screen.dart`:** this is the one place this feature's code reaches outside `lib/games/bartender/`. Keep that change to the single line wiring `onBartenderTap`, done as its own small, clearly-labeled commit/PR, so the leader can review it in isolation from the rest of the feature's code.