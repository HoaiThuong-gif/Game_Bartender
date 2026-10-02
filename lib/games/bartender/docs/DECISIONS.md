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
