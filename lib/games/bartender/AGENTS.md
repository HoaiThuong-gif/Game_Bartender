# AGENTS.md — game_kitchen (Bartender)

Rules for any coding agent (Antigravity, Claude Code, or similar) working in `lib/games/bartender/`. Read this file, and everything in the repo-root `docs/` folder relevant to this feature (`README.md`, `PROJECT_SPEC.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `API.md`, `DEVELOPMENT.md`), before writing or editing any code. Place this file at `lib/games/bartender/AGENTS.md` so it is found automatically by agents working inside this folder.

## English

### 1. Docs are the source of truth — you may read them, never edit them
- `docs/PROJECT_SPEC.md`, `docs/ARCHITECTURE.md`, and `docs/DECISIONS.md` (inside `lib/games/bartender/docs/`, this feature's own docs) describe locked decisions. **Do not edit these files.**
- If something you're asked to build contradicts these docs, or a doc is ambiguous/missing a detail you need, **stop and ask the developer** instead of guessing or silently changing the doc yourself.
- If the developer explicitly tells you a decision has changed, you may update `docs/DECISIONS.md` by **adding a new dated entry** (never rewrite or delete an old entry), and update the relevant section of `docs/PROJECT_SPEC.md` or `docs/ARCHITECTURE.md` to match — only when the developer has explicitly said so.
- `docs/API.md` and `docs/DEVELOPMENT.md` are reference material — same rule: don't edit them yourself; flag if they seem wrong.
- Also read (but never edit) `docs/rubik-foundation.md` and `docs/lobby.md` **at the repo root** (a different `docs/` folder from this feature's own, which lives inside `lib/games/bartender/docs/`) once, for context on this repo's existing naming and documentation conventions — they belong to the Rubik and lobby features, not this one.

### 2. `TASK.md` is yours to maintain
- `TASK.md` (at `lib/games/bartender/TASK.md`) is an operational log, not a decision record. **Keep it updated as you work.**
- Before starting work, check it for what's already done and what's in progress.
- Move items between "Đang làm / In progress", "Đã xong / Done", and "Chưa làm / Backlog" as you go. Add new backlog items if you discover necessary sub-tasks not yet listed.
- If blocked by a decision only the developer can make, add it under "Vướng mắc / Blocked" — do not guess and proceed silently on anything architecture- or scope-affecting.

### 3. Scope boundaries — this is the most important rule in this file
- Only write/edit files inside `lib/games/bartender/`. Do **not** modify anything inside `lib/games/rubik/`, `lib/screens/home/` (except the one exception below), `lib/shared/`, `assets/`, or any other part of the repo.
- **The one allowed exception:** wiring the `onBartenderTap` callback in `lib/screens/home/lobby_screen.dart`, and only as described in `DEVELOPMENT.md` step 7 — a single, minimal, isolated change (swap the placeholder snackbar for a `Navigator.push` to `BartenderScreen`), done as its own commit, never bundled with other changes. Do not touch anything else in that file, and never touch `lobby_layout.dart` or any asset under `assets/images/lobby/` — those belong to the lobby feature's own documented conventions in `docs/lobby.md`.
- Follow the internal layering in `docs/ARCHITECTURE.md` (`models` / `services` / `controllers` / `widgets` / `screens`) and match the naming style already used by `lib/games/rubik/` for consistency across the repo.
- `pubspec.yaml` currently has no Firebase or `sensors_plus` dependencies. Adding them is expected (see `DEVELOPMENT.md`), but do so as its own clearly-labeled change, since it affects the whole app's dependency tree, not just this feature.
- Follow the build order in `docs/DEVELOPMENT.md`. Don't jump ahead to a later stage while an earlier one is unverified.

### 4. Working style
- Prefer small, reviewable changes the developer can run and test on a real device before continuing, especially anything sensor-related (cannot be verified on an emulator).
- Do not perform your own code review or claim code is production-ready — the developer reviews and tests; your job is implementation against the docs.
- The developer is a first-time mobile developer who does not want to learn Dart/Flutter in depth — prefer clear, well-commented code and explain non-obvious choices in `TASK.md` notes rather than assuming familiarity.
