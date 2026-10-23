# DEVELOPMENT — game_kitchen (Bartender)

> Added beyond the required doc set because the developer is building their first mobile app and is deferring implementation to a coding agent (Claude Code / Antigravity). A clear, ordered setup and workflow reduces back-and-forth and avoids the agent making undocumented environment assumptions.

### Recommended build order
Follow this order; each stage should be runnable and demoable before moving to the next.

1. **Skeleton feature, no shared-file changes yet.** Create `lib/games/bartender/` with the `models / services / controllers / widgets / screens` folders from `ARCHITECTURE.md`. Add a minimal `BartenderScreen` showing placeholder text. Run it standalone (temporarily point `main.dart` at it, or add a debug route) — do not touch `lobby_screen.dart` yet.
2. **Models, no UI polish.** Implement the models and rules in `models/` (ring math, round completion, station assignment, recipe/difficulty pool) as plain Dart, with unit tests in `test/` at the repo root (same location as the existing Rubik tests, e.g. `test/cube_state_test.dart` — follow that pattern, e.g. `test/bartender_round_test.dart`).
3. **Single-device playable loop with `FakeRoomRepository`.** Wire up `widgets/`/`screens/` against the fake, in-memory repository. The full round loop, station display, swiping, trash bin, and order submission should work on one phone with simulated other players. No Firebase needed yet.
4. **Firebase project setup.** Done: Bartender uses the shared Firebase project `nhom-bar` (D18) and the config files are already committed. See "Firebase setup" below; do not create a new project or run `flutterfire configure`.
5. **`FirebaseRoomRepository`.** Implement the real repository against the schema in `API.md`. Test room creation and joining with 2 physical devices first, then 3–4.
6. **Sensors and haptics.** Add `sensors_plus` (already a dependency in `pubspec.yaml`) for the shaker station, plus haptic feedback for key events. Test only on real devices (see note below).
7. **Wire into the lobby.** This is the only step that touches a shared file. In `lib/screens/home/lobby_screen.dart`, change the `onBartenderTap` default from the "coming soon" snackbar to:
   ```dart
   onBartenderTap ?? () => Navigator.of(context).push(
     MaterialPageRoute<void>(builder: (_) => const BartenderScreen()),
   ),
   ```
   Make this its own small commit (or PR into `dev`), separate from the rest of the feature's commits, so the leader can review just this one-line change easily. Do not touch anything else in `lobby_screen.dart` or `lobby_layout.dart` (positioning/assets are the leader's area; the former `docs/lobby.md` was removed from the repo).
8. **Polish and results screen.** End-of-match results, ranking display, basic styling.

### Local development (steps 1–3, no Firebase)
```bash
flutter pub get
flutter test                 # runs unit tests, including the new bartender ones
flutter run -d <device-id>   # runs the app with FakeRoomRepository selected
```
Use a simple compile-time or runtime flag (e.g. a constant in a `bartender_config.dart` file) to choose between `FakeRoomRepository` and `FirebaseRoomRepository`, so gameplay can keep developing without touching Firebase at all until step 4. To exercise the real backend, set `useFakeRepository = false` locally (do not commit that change) and run with `--dart-define=DATABASE_URL=https://nhom-bar-default-rtdb.asia-southeast1.firebasedatabase.app`.

### Firebase setup (shared project, D18)
Bartender uses the same Firebase project as Rubik (`nhom-bar`). Do **not** create a new project and do **not** run `flutterfire configure`: `lib/firebase_options.dart` and `android/app/google-services.json` are already committed.
1. Realtime Database URL: `https://nhom-bar-default-rtdb.asia-southeast1.firebasedatabase.app`. Pass it with `--dart-define=DATABASE_URL=<url>` (the existing `RUBIK_DATABASE_URL` also works); it is also the default in `BartenderConfig.databaseUrl`.
2. Anonymous sign-in is already enabled (**Authentication → Sign-in method → Anonymous**). The app signs each phone in anonymously and uses its `uid` as the `playerId`; without it, creating or joining a room fails.
3. Security rules live in the shared `database.rules.json` (Rubik's rules plus the `bartender` block, see `API.md`). Deploy with `firebase deploy --only database` (run `firebase use nhom-bar` first, after `git pull`, one person at a time). Never replace the file with a Bartender-only version: that would delete Rubik's rules.
4. Access to the Firebase console is granted by the project owner (Project settings → Users and permissions); the **Editor** role is enough for the database, rules and authentication.
5. iOS: the equivalent config (`GoogleService-Info.plist`) requires a Mac-connected flow and the team's iOS user has no Mac, so Android is the priority target (see `DECISIONS.md`, D2).
6. Rubik's Cloud Functions need the Blaze plan; Bartender does not use Cloud Functions and works on the free Spark plan.

### Testing on real devices
- **Shake detection cannot be reliably tested on an emulator/simulator.** Test on at least one real Android phone from the first moment shake logic is added.
- **Multi-device testing:** devices just need any internet connection (Wi-Fi or mobile data) to reach Firebase — they don't need to share a network. Run each device with `useFakeRepository = false` (local only) and the `--dart-define=DATABASE_URL=...` above. Besides the normal flow, also try: two phones pressing Join at the same moment, a room of exactly 2 players, a room of 3–4 players, and one phone dropping mid-match (airplane mode) to confirm the round still advances and the player is removed at the next round boundary.
- **The Rubik feature already builds for Android.** Its former build notes (`docs/rubik-foundation.md`) were removed from the repo, but the offline Gradle fallback (`gradlew.bat --offline ...`) is still a useful option if dependency downloads are slow.
- **iOS:** if attempted, budget extra time for provisioning/signing issues (see `DECISIONS.md`, D2).

### Working with a coding agent
- Give the agent this documentation set (`PROJECT_SPEC.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `API.md`) plus this file as context before asking it to implement a stage.
- Also point it at `lib/games/rubik/` once, so it sees the naming convention (`models/services/controllers/widgets/screens`) already established by the other feature and stays consistent with it.
- Ask for one stage of the build order above at a time, and run/test each stage on a device before asking for the next.
- Step 7 (wiring `lobby_screen.dart`) should be a deliberately small, isolated request to the agent — remind it explicitly not to touch anything else in that file or in `lobby_layout.dart`.
- If a requirement turns out to be wrong or needs to change while building, update the relevant doc (usually `PROJECT_SPEC.md` or a new entry in `DECISIONS.md`) rather than only telling the agent verbally.
- Code review is expected to be done by the coding agent itself (or a second agent), not by asking Claude.ai for a code review.