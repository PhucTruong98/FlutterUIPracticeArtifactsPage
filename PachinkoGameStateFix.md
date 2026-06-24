# Task: Refactor a Flutter + Flame (Forge2D) Pachinko game's state management

## Context
This is a Pachinko-style game built with Flutter and `flame_forge2d`. The player
loads treats, aims, and drops them; treats bounce off pegs (scoring points) and
ideally land in a catch zone to feed a puppy (adding energy). Key files:

- `PachinkoGame` (StatefulWidget) — the screen/UI.
- `GameState` — a plain mutable Dart model holding scoring/session state.
- `PachinkoGameWorld` (extends `Forge2DGame`) — the physics world.
- Components under `components/`: `TreatBody`, `PegBody`, `WallBody`,
  `PuppyCatchZone`. Read these before editing — their collision logic matters
  for several fixes below.

## The core problem
Game-world events currently drive Flutter `setState`, and the `PachinkoGame`
widget acts as a synchronization hub: the world fires callbacks UP to the widget,
the widget mutates `GameState`, and the widget commands the world back DOWN
(spawnTreat, scheduleTreatRemoval, overlay toggles). State that means the same
thing is tracked in two places (`GameState.isTreatFalling` vs
`PachinkoGameWorld.currentTreat`), which lets them desync.

## Architectural goal (IMPORTANT — follow precisely)
Consolidate to a SINGLE OWNER without collapsing into a single class:

- KEEP `GameState` as a pure, Flame-free, widget-free Dart model. Do NOT merge
  it into `Forge2DGame` — scoring rules must stay unit-testable without a physics
  world. `GameState` holds rules/session state (score, treats remaining, energy,
  status message).
- Make `PachinkoGameWorld` OWN the `GameState` instance and drive it directly
  from physics events. The world owns physics truth (bodies, positions,
  currentTreat).
- Make `PachinkoGame` a PURE VIEW: it observes state and sends user intents down
  to the world. It must not orchestrate consequences and must not call setState
  for game events.

Data flow must be one-directional: physics event → world mutates GameState →
GameState notifies → only the affected HUD widget rebuilds. User input flows the
other way: widget calls a method on the world → world updates physics + rules.

## Implement in these stages (each stage must compile)

### Stage 1 — Make GameState observable
- Make `GameState` extend `ChangeNotifier`; call `notifyListeners()` at the end
  of every mutating method. Do not change the scoring logic.
- Delete the dead `copyWith` method (it's unused and buggy — it nulls
  statusMessage). The model is mutable; don't keep half an immutable API.

### Stage 2 — World owns GameState
- `PachinkoGameWorld` takes `final GameState gameState` via constructor. Create
  the `GameState` once in the widget's `initState` and pass it in.
- Remove the `onPegHit` / `onTreatCaught` callback fields from the world.

### Stage 3 — Move mutation into the world's components
- Inspect `PegBody`/`TreatBody`/`PuppyCatchZone` collision logic. Peg contact
  should call `gameState.recordPegHit()` directly; the catch zone should call
  `gameState.treatCaught()` then remove the treat.
- FIX A DOUBLE-FIRE BUG: the catch event is currently wired to TWO things
  (`PuppyCatchZone.onTreatCaught` AND `TreatBody.onCaught`). Ensure the catch is
  handled by exactly ONE owner (the catch zone is the natural choice) so energy/
  score/removal don't happen twice.

### Stage 4 — Collapse the duplicated flag + fix the soft-lock
- Remove `GameState.isTreatFalling` as independent state; derive "treat in play"
  from the world's `currentTreat`.
- FIX A SOFT-LOCK: if a treat is never caught (it settles in a corner or the
  body sleeps), `isTreatFalling`/`currentTreat` never clear, so the player can
  never load/drop again, and `isGameOver` never becomes true. Add a
  `treatMissed()` path on `GameState` (clears in-play status, resets round score/
  collisions, sets a "Missed!" message) and a detector in the world that fires it
  — either when the treat body goes to sleep, or a per-drop timeout (~10s after
  spawn) as a reliable fallback. Remove the treat on miss.
- Note the catch zone is `boardWidth - 2` (18) wide but walls are at ±10, leaving
  a ~1-unit gutter where a radius-1 treat can rest OUTSIDE the sensor. Either
  widen the catch zone / narrow the gutter so treats can't permanently rest
  uncaught, or rely on the miss detector above — but make sure a treat in the
  gutter cannot lock the game.
- Make `scheduleTreatRemoval` lifecycle-safe: use a Flame `TimerComponent` added
  to the world instead of a bare `Future.delayed`, so it can't fire against a
  disposed world.

### Stage 5 — Turn the widget into a view
- Replace every game-event `setState` with `ListenableBuilder` (or
  `ValueListenableBuilder`) wrapping only the relevant HUD section
  (score, treats, energy, status, game-over).
- Delete all `SchedulerBinding.instance.addPostFrameCallback` wrappers — once the
  world drives state directly, the "setState during build" timing conflict is
  gone.
- Remove orchestration from the old `_handleTreatCaught` (the in-setState side
  effects and nested `Future.delayed`). User actions become method calls on the
  world (e.g. `requestLoad`, `dropTreatAt(x)`).
- Convert the aim/`tapToDrop` overlay from an imperatively toggled Flame overlay
  to a conditional Flutter `Stack` child driven by the observable `isTreatLoaded`
  flag. Move the aim X position into a `ValueNotifier<double>` so only the aim
  painter repaints on drag — update it synchronously (no post-frame defer), which
  fixes the laggy drag.

## Additional specific bugs to fix along the way
1. `class PachinkoGame <T extends Game>` — the generic param is unused and the
   `State` type doesn't carry it. Delete `<T extends Game>` entirely.
2. `EnergyGaugeWidget` is passed `currentEnergy` and `targetEnergy` with the SAME
   value, defeating any animation. Inspect the widget and pass the correct
   distinct values (or remove the redundant param).
3. Stacking puppy-happiness timers: each catch starts a 2s `Future.delayed` reset,
   so an earlier timer un-happies the puppy too soon. Use a single cancelable
   `Timer` (cancel before restarting) tied to an observable `isPuppyHappy`.
4. Preview/drop clamp mismatch: the drop path clamps X to the walls but the drag
   handler sets the preview X unclamped, so the aim line can sit outside the
   playfield while the treat drops at the wall. Clamp both in the same place.
5. Replace deprecated `withOpacity(x)` with `withValues(alpha: x)` throughout.
6. The four walls use a hardcoded debug red (255,0,0). Make them themed or
   invisible. The top wall is redundant (treats spawn below it, gravity is down)
   — remove it unless it's load-bearing.
7. `maxPuppyEnergy` never varies — make it a constant. `collisionCount` is always
   `currentScore / 50`; leave both if used in UI, but don't add new duplication.

## Constraints & deliverables
- Rename files to snake_case to satisfy Dart's `file_names` lint:
  `GameState.dart` → `game_state.dart`, `PachinkoGameWorld.dart` →
  `pachinko_game_world.dart`, and the same for component files using PascalCase
  filenames. Update imports. (`puppy_painter.dart` is already correct.)
- After each stage, ensure the project compiles and `flutter analyze` is clean.
- Add unit tests for `GameState`: loadTreat, dropTreat, treatCaught (energy +
  score reset), treatMissed, and isGameOver transitions. These should run without
  any Flame/physics dependency — if they can't, GameState isn't pure enough.
- Do not introduce a heavyweight app-wide state management package; a
  `ChangeNotifier` on the world-owned `GameState` is sufficient for this scope.

Before starting, read all the files listed above (especially the components under
`components/`) and confirm the collision wiring before changing Stage 3. If any
assumption here contradicts the actual code, follow the code and note the
discrepancy.