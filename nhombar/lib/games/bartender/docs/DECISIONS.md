# DECISIONS — game_kitchen

Each entry records a locked decision, why it was made, and what was considered instead. Entries are dated by when they were locked during planning (2026-09-30 session). If a requirement or architecture assumption changes later, the affected entry must be revisited and the dependent docs (`PROJECT_SPEC.md`, `ARCHITECTURE.md`) updated accordingly.

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

### D12 — Visual assets: free CC0 16x16 pixel-art sprite packs
**Decision:** Use free, CC0/commercial-permitted 16x16 pixel-art sprite packs for ingredients, stations, UI, and background, rather than hand-drawn or paid art: `infpixel` Free Pixel Fruits & Vegetables for ingredients; Kenney "Generic Items", "Roguelike Indoor pack", "UI Pack Adventure", and "Background elements" (all CC0) for stations/items/UI/background. Accepted that this gives the Bartender screen a different visual style from the existing hand-drawn lobby and Rubik screens.
**Rationale:** Finding free, ready-made hand-drawn art matching the lobby's detailed style across fruits/stations/bottles/UI was judged unlikely to succeed and not worth the search time — that style is typically paid or custom-commissioned, not freely available as a matching set. Pixel art packs from a consistent source (mostly Kenney, CC0) are readily available, match each other, and need no attribution. The style mismatch is low-risk because the Bartender screen is a separate full-screen destination reached via `Navigator.push`, never shown alongside the lobby or Rubik screens at the same time. Matches the project's overall MVP-first approach (same reasoning as D6's sensor scope and D5's simplified station assignment): ship something working first, revisit polish later if time allows.
**Alternatives considered:** Search further for hand-drawn-style free assets matching the lobby (deferred — may revisit later if time allows, per developer's explicit request); emoji/Material Icons only, no sprite packs (rejected — developer chose real sprite assets over icons for this feature); commissioning or hand-drawing custom art (rejected — too much effort for a free, pass-the-course student project).

### D13 — Player count: 2–4 per room, ring size fixed at match start
**Decision (2026-10-05):** A room holds **2 to 4** players; the maximum is a single constant in `bartender_config.dart` (default 4) enforced in `joinRoom`. Players can only join while the room status is `lobby`. When the match starts, the ring size is the number of players in the room at that moment. There is no `totalPlayers` field in the database. This refines D3 ("2+ players").
**Rationale:** Only 2–4 players is verified (see `PROJECT_SPEC.md`, non-goals). An earlier implementation stored a `totalPlayers` chosen at room creation and used it for the ring, station assignment and the round-completion check, so a room that started with fewer players than `totalPlayers` could never finish round 1. Locking the ring to the players actually present at start removes that whole class of bugs and matches D3's "do not wait for exactly N players".
**Alternatives considered:** Requiring at least 3 players (rejected: 2 players is still playable once D15/D16 are in place and 2 devices is the most common test setup); allowing joins mid-match (rejected: changes the ring size and every `ringIndex` while items are in flight).

### D14 — Disconnected players: ignored for round completion, removed at the next round boundary
**Decision (2026-10-05):** A player with `connected: false` does not count toward round completion — a round ends when every **connected** player has reached `ordersPerPlayer`. `connected` becomes false when the player leaves or when the client drops (RTDB `onDisconnect`). `ringIndex` is fixed *within a round*. At every round boundary the disconnected players are removed from `players` and the remaining players' `ringIndex` values are compacted to `0..k-1`, preserving order (a remaining player's inbox moves with them). If fewer than 2 connected players remain while the match is `playing`, the match ends and shows the results screen. A removed player whose app comes back is told they were removed and returns to the lobby. A client that regains its connection *before* the round boundary sets `connected` back to `true` and re-arms `onDisconnect`, so a short network blip does not get the player removed. In the lobby there is no ring yet: a player who leaves is deleted immediately, and `startMatch` compacts `ringIndex` to `0..k-1` over the remaining connected players (same compaction as at a round boundary). This refines D3 and replaces the API.md wording "slot is not removed mid-match" with "not removed within a round".
**Rationale:** D3 requires the match to continue with the remaining players, but the earlier wording ("every `ringIndex` in the room") would let one dropped phone block the round forever. The round boundary is the cheapest moment to renumber, because stations, orders and progress are all reset then anyway. Removing the player there also stops later rounds from passing items to a dead neighbour. Two players are the minimum because station assignment assumes at least 2.
**Alternatives considered:** Keeping disconnected slots for the whole match and only skipping them in the completion check (rejected: items passed to the ghost neighbour stay stuck all match and the ring never shrinks); removing the player immediately mid-round (rejected: renumbers the ring while items are in flight, the original reason for "not removed mid-match"); letting a dropped player rejoin the same slot (deferred, not needed for the demo).

### D15 — Station assignment stays random, but every round must be winnable
**Decision (2026-10-05):** D5 stays (random assignment; duplicate or missing stations allowed). One constraint is added: the orders of a round are drawn only from recipes whose every step station is held by at least one player in that round's assignment. The assignment is built so this always succeeds: pick an "anchor" recipe at random from the recipes allowed for the round whose number of distinct stations is ≤ the player count; give its stations to distinct random players; give the remaining players a random station or none (D5); then draw orders from all recipes feasible under the final assignment (the anchor guarantees at least one). This is a pure function in `models/`, shared by `FakeRoomRepository` and `FirebaseRoomRepository`.
**Rationale:** With four stations plus "none" equally likely per player, round 1 (only juicer recipes) had nobody holding a juicer in about 64% / 51% / 41% of rounds at 2 / 3 / 4 players (`(4/5)^N`). D5's intent is tension about *who* has the station, not rounds that cannot be completed at all. Raising the minimum player count would not fix this (still about 41% at 4 players).
**Alternatives considered:** Re-rolling a fully random assignment until a recipe is feasible (works, but non-deterministic and harder to unit-test); strict 1-to-1 station-to-player mapping (rejected by D5).

### D16 — Recipe pool: no recipe needs more than 3 distinct stations
**Decision (2026-10-05):** "Nước chanh dâu" (`strawberry_lemonade`) is reduced from 4 steps on 4 stations to 3 steps on 3 stations: juicer (squeeze lemon) → blender (blend strawberry with the lemon juice) → shaker (shake with ice and sugar). The cutting-board step is removed. The pool stays at 5 recipes (D7). No recipe needs more than 3 distinct stations.
**Rationale:** A player holds one station per round, so a recipe needing *k* distinct stations needs at least *k* players. The 4-station recipe was only possible with exactly 4 players holding 4 different stations. With a maximum of 3, rooms of 3 and 4 players can reach the whole recipe pool, and 2 players reach 4 of the 5 recipes (all except `strawberry_lemonade`), so a 2-player room hits a difficulty ceiling instead of an impossible round.
**Alternatives considered:** Letting each player hold several stations at low player counts (deferred past the MVP — a larger change to the station model, `stationAssignment` and the UI); difficulty levers that do not depend on stations, such as more orders per round or a smaller time bonus (deferred — would change D4).

### D17 — No host role: any client may advance the round or end the match, guarded by transactions
**Decision (2026-10-05):** Advancing to the next round and ending the match are triggered by any client that observes the condition; RTDB transactions make sure only one client performs each. Round advance: a transaction on `rooms/{code}/round` that only succeeds if the round number still equals the observed one and every connected player is done; the winner then writes the new orders, ring compaction (D14) and inbox in one multi-path update. Match end: a transaction on `results` acts as the claim; `results` is written first and `status` becomes `ended` after it. Submitting an order is one multi-path update that uses `ServerValue.increment` for `round/progress`, `completedOrders` and `timer/endTime`. All timestamps use RTDB server time (`ServerValue.timestamp`, `.info/serverTimeOffset`), as `API.md` and `ARCHITECTURE.md` already require.
**Rationale:** The earlier idea "only the host creates the next round" breaks whenever the host is not the one who completes the last order, or when the host disconnects. Read-then-write updates from several phones lose increments and can soft-lock a round. There is no backend to run this logic (D1), so transactions are the way to get a single writer.
**Alternatives considered:** Host-only round creation (rejected, see above); Cloud Functions (rejected: D1, no backend to maintain); a server-authoritative game loop (rejected: out of scope for the MVP, see `ARCHITECTURE.md` trade-offs).

### D18 — One shared Firebase project, Bartender data under `bartender/rooms/`
**Decision (2026-10-15):** Bartender and Rubik share a single Firebase project (`nhom-bar`). Bartender's data lives under `bartender/rooms/{roomCode}` (previously `rooms/{roomCode}`), so it never collides with the Rubik nodes (`rubikRooms`, `rubikCommands`, `rubikResponses`, `rubikRewards`, `rubikPresence`). Both games use the same anonymous Firebase Auth identity and the same Realtime Database instance, `https://nhom-bar-default-rtdb.asia-southeast1.firebasedatabase.app`, selected through the `DATABASE_URL` (or the existing `RUBIK_DATABASE_URL`) `--dart-define`; the same URL is the default in `BartenderConfig.databaseUrl`. `firebase_options.dart` and `google-services.json` are committed to the repository. Security rules live in one shared `database.rules.json`: the root stays closed and the `bartender` block lets any signed-in (anonymous) user read and write `bartender/rooms/{roomCode}`. Rules are deployed with `firebase deploy --only database`, by one person, after pulling the latest file. The earlier project `mobile-app-project-52a1d` is no longer used. The Firebase console (database, rules, Rubik's Cloud Functions) is administered by the Bartender developer, with the team leader's agreement.
**Rationale:** Rubik's online challenge already runs on `nhom-bar` with its own strict rules and Cloud Functions. A second project would mean two sign-ins per player, two sets of configuration and two rules files, whereas a path prefix is enough to keep the games' data apart. One anonymous sign-in also means a player does not need a separate identity for each game.
**Consequences:** Security is classroom-level: any signed-in user can write any room code, which is consistent with the client-trusted design in `ARCHITECTURE.md`. Rubik's Cloud Functions need the Blaze plan; Bartender does not use Cloud Functions and works on the free Spark plan.
**Alternatives considered:** Two separate Firebase projects with a named Firebase app per game (rejected: duplicated configuration, harder to demo); keeping the unprefixed `rooms/` path (rejected: too generic, risk of colliding with future Rubik data); the previous open rules `.read/.write: true` (rejected: the shared rules require sign-in).

### D19 — One processing rule table; final recipe list
**Decision (2026-10-15):** Item processing at stations is defined in one place, the pure function `processItem(itemId, station)` in `models/processing_rules.dart`, used by `FakeRoomRepository`, `FirebaseRoomRepository` and the station widget. A station that cannot process an item leaves it unchanged. Rules: juicer: orange → orange_juice, lemon → lemon_juice; cutting board: strawberry → cut_strawberry; blender: cut_strawberry → strawberry_smoothie, lemon_juice → strawberry_lemonade_blend; shaker: orange_juice or lemon_juice → citrus_cocktail, strawberry_lemonade_blend → strawberry_lemonade. Final recipes: orange_juice (juicer), lemonade (juicer; the product is lemon_juice), strawberry_smoothie (cutting board, blender), citrus_cocktail (juicer, shaker), strawberry_lemonade (juicer, blender, shaker). Every one of the four stations is used by at least one recipe, and no recipe needs more than three stations (D16).
**Rationale:** Processing used to be defined three times (fake repository, Firebase repository, station widget) and the copies had drifted apart: some recipes could not be completed through the UI and the two repositories gave different results. One pure function removes that drift and can be unit-tested against every recipe.
**Alternatives considered:** Keeping three copies in sync by comments (rejected: it had already failed); dropping the cutting step from strawberry_smoothie (rejected: the cutting board would then be used by no recipe, leaving players with a useless station).

### D20 — Independent API backend with Swagger / Backend riêng qua API

**Decision (2026-10-30):** The developer explicitly requested separate frontend
and backend to meet the instructor's requirement, including Swagger. Flutter
stays in the repository root and uses `ApiRoomRepository` by default; Node.js
lives in `backend/` with independent installation/start/tests. It exposes
versioned HTTP JSON APIs, anonymous Bearer sessions, room polling/heartbeat and
OpenAPI 3 at `/docs` and `/openapi.json`. Backend owns Bartender transitions and
persists JSON on disk for a single-process demo. Offline bots require
`BARTENDER_OFFLINE=true`. Existing Firebase implementations/functions are legacy
and are not selected by the new online entry points.

**Rationale:** The new requirement supersedes D1 and the client-side
transition/storage choices in D17/D18. Gameplay D13–D16/D19 stays intact.
Backend has its own processing rules; Dart rules support UI hints and offline
testing. Integration tests exercise the real HTTP boundary. Future database or
hosting migrations should preserve the API contract.

**Tiếng Việt:** Tách trách nhiệm và tiến trình chạy: backend kiểm tra thành viên,
trạm, vật phẩm, đơn hàng; tự cộng giờ, chuyển vòng và kết thúc trận. Flutter
không ghi database trong luồng mới. Giữ layout Flutter để bảo toàn cấu hình
Android/tài nguyên. Firebase cũ giữ để tham khảo, không cần deploy để demo API.

### D21 — Sibling frontend/backend folders / Hai folder con cùng dự án

**Decision (2026-10-30):** Per the developer's explicit follow-up, move the full
Flutter application into `nhombar/`, next to `backend/` inside the existing outer
repository. This supersedes D20's physical layout choice to keep Flutter at the
root. Backend includes the Python scan service/tools/runtime and legacy Firebase
functions/config; Android, assets, Dart code and frontend tests belong to
`nhombar/`. Update integration-test, SDK discovery and editor launch paths.

**Tiếng Việt:** Giữ một repo/thư mục lớn, bên trong có `backend/` và `nhombar/`
(frontend). Chạy Flutter từ `nhombar/`; không đổi tên package Dart `nhom_bar`
hoặc applicationId Android, vì đây là tên kỹ thuật chứ không phải vị trí folder.
