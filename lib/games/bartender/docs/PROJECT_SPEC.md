# PROJECT_SPEC — game_kitchen

### Goals
- Deliver a working, demoable multiplayer cooperative drink-making mini-game as one of the 4 mini-games required by the course assignment.
- Run reliably on the team's own devices for the MVP: **2 to 4 players**, Android-first, iOS as a stretch goal.
- Fit into the shared Flutter repo (`Game_Bartender`) as an isolated feature under `lib/games/bartender/`, following the same flat convention already used by `lib/games/rubik/`, so the other mini-games (including the mandatory Rubik solver) can be developed independently.
- Keep the implementation simple enough for a first-time mobile developer to build with the help of a coding agent, working from this documentation.

### Non-goals (MVP)
- No matchmaking beyond joining by a room code.
- No server-authoritative anti-cheat logic (client-trusted gameplay is acceptable for this project).
- No tilt-based station interaction (only touch/drag + one shake-based station).
- No testing or guaranteed support beyond 4 concurrent players (design supports up to 10 per the original concept, but only 2–4 is verified).
- No persistence of match history beyond the current match's end screen.
- No login/accounts — players are identified only by their display name and ring position within a room.
- No in-app purchases or monetization.
- No dynamic/algorithmic difficulty scaling — difficulty progression is achieved by drawing from a fixed pool of recipes ordered from easy to hard, not by a scaling formula.

### Users
- The team's own 4 members, using their personal phones (3 Android, 1 iOS) to demo the game to the instructor.
- Secondary: the course instructor, who will play or observe a demo session.

### Requirements

**Room & players**
- A player creates a room and receives a generated room code (e.g. 4 digits); other players join by entering that code.
- Players are assigned a sequential position (1, 2, 3, ...) forming a ring.
- A match can start once **2 or more** players are in the room (does not require all 4).
- If a player disconnects mid-match, the match continues with the remaining players.

**Match loop**
- A match has one shared countdown timer, starting at 60 seconds. It only serves to **end the match** when it reaches 0.
- Completing any order (by its owner) adds +5 seconds to the shared timer and gives that player +1 personal completed order.
- The match is organized into **rounds**, independent from the shared timer:
  - Each round, every player receives a **fixed number of orders (target: 3)** to complete.
  - A round ends only when **all** players in the room have completed their round's orders.
  - When a round ends: processing stations are **reassigned randomly** among players, and a new round begins with a fresh set of orders.
- Recipe difficulty increases by round: early rounds draw only from easy recipes (1 ingredient / 1 step); later rounds draw from a pool that includes harder recipes (multiple ingredients, multiple stations). The recipe pool has **3 to 5 recipes** total.

**Stations**
- At least **4** processing stations exist (recipe-dependent; conceptually knife/cutting board, blender, juicer, shaker, etc.).
- Each round, stations are assigned randomly to players. Unlike the original 10-player design, duplicate or missing station assignment can still occur even at 2–4 players (assignment is not forced to be 1-to-1).
- Each player's screen shows **one fixed station** for that round (the one assigned to them).

**Ingredients & items**
- Ingredients spawn on player screens periodically (~every 3 seconds).
- Each screen has a trash bin; players can drag unwanted ingredients there to clear space.
- Items (ingredients or partially/fully processed products) are passed by **swiping left or right**, sending the item to the adjacent player in the ring (wrap-around at the ends).

**Visual assets**
- Ingredient, station, UI, and background art uses free, CC0/commercial-use-permitted 16x16 pixel-art sprite packs (ingredients: `infpixel` Free Pixel Fruits & Vegetables; stations/items/background/UI: Kenney "Generic Items", "Roguelike Indoor pack", "UI Pack Adventure", "Background elements" — all CC0) rather than custom-made or paid art.
- This gives this feature a different visual style from the existing lobby (hand-drawn PNG art) and Rubik screens. This is accepted for the MVP — the Bartender screen is a separate full-screen destination reached via navigation, not shown alongside the other styles — and may be revisited later if time allows.

**Order submission**
- A player submits a completed order by **dragging the finished product into a "submit" zone** on their own screen. Submission is a manual action, not automatic on receipt.

**Sensors & feedback**
- Most stations use touch/drag interactions.
- At least one station (the shaker) uses phone-shake detection via `sensors_plus`.
- Haptic feedback (vibration) on key events: receiving an item, completing a processing step, submitting an order, and low time remaining.

**End of match**
- When the shared timer reaches 0, the match ends for the whole room.
- Show a results screen: total survival time, total team orders completed, and a per-player ranking by personal completed orders.

**Visual assets**
- Ingredients, stations, drinks/items, UI chrome, and background use free, pre-made pixel-art (16x16 style) assets rather than custom-drawn art — see `ARCHITECTURE.md` for the specific packs and licenses.
- This deliberately differs from the hand-drawn style of the existing lobby screen; the two are visually distinct (the player leaves the lobby's scene entirely when entering the Bartender game via `Navigator.push`), and this is accepted for MVP rather than spending time sourcing or commissioning matching art. The team lead should be informed of this choice.

### Constraints
- **Team/tech constraint:** must be built as an isolated feature under `lib/games/bartender/`, integrating with the rest of the app only through the single `BartenderScreen` entry point and the `onBartenderTap` wiring in `lobby_screen.dart` — no direct dependency on `lib/games/rubik/` or other mini-games.
- **Cost constraint:** student project, backend must run on a free tier (Firebase Realtime Database Spark plan).
- **Platform constraint:** the team's iOS user has no Mac available; Android is the primary target, iOS build is attempted later if time allows.
- **Developer experience constraint:** the developer is building their first mobile app and does not intend to deeply learn Dart/Flutter; implementation work is expected to be done by a coding agent following this documentation, with the developer running, testing, and reviewing on real devices.
- **Device constraint:** sensor-based interactions (shake) must be verified on a real device — simulators/emulators cannot reliably test this.