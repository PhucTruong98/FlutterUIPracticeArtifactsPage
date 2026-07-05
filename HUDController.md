# HUD Controller Refactor — Implementation Instructions (v2: controller-owned animations)

## Goal

Move HUD animation orchestration out of widget `State` and into per-element
controllers, coordinated by a thin facade. The key architectural decision that
makes this version better than a GlobalKey approach:

> **The controller owns the `AnimationController`s (it is the `TickerProvider`).**
> The widget is a pure `AnimatedBuilder` over the controller's animations.

Consequences:
- Awaitable methods like `await controller.animateEnergy(from, to)` are legitimate
  because the controller owns the thing it awaits — no reaching into `currentState`.
- Animation state survives widget rebuilds / route changes. The widget can be
  disposed and recreated; the animation keeps running on the controller.
- **No `GlobalKey`, no `currentState!`.** That entire class of null-crash and
  dead-State bugs disappears.
- Cancellation is natural: the controller owns both the generation token and the
  `AnimationController`s.

Keep the good ideas from the prior design: `Future`-based sequencing that reads
top-to-bottom, `Future.wait` for "fire together" coordination, and game rules in
the controller with a dumb widget.

---

## Step 1 — Base controller (TickerProvider + cancellation token)

Create `lib/hud/hud_element_controller.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Base for every HUD element controller.
/// - Is a TickerProvider so it can OWN AnimationControllers that outlive the
///   widget (this is what removes the GlobalKey-into-State fragility).
/// - Extends ChangeNotifier so it can also notify for non-animated display
///   changes (e.g. the level number text).
/// - Provides a generation token to cancel stale async sequences.
abstract class HudElementController extends ChangeNotifier
    implements TickerProvider {
  final Set<Ticker> _tickers = {};

  @override
  Ticker createTicker(TickerCallback onTick) {
    final ticker = Ticker(onTick);
    _tickers.add(ticker);
    return ticker;
  }

  int _generation = 0;

  /// Call at the start of every event. Capture the return value and re-check it
  /// with [isCurrent] after every `await` to detect supersession by a newer event.
  int beginSequence() => ++_generation;
  bool isCurrent(int gen) => gen == _generation;

  @override
  @mustCallSuper
  void dispose() {
    for (final t in _tickers) {
      t.dispose();
    }
    _tickers.clear();
    super.dispose();
  }
}
```

> **vsync caveat (decide now):** this simple `TickerProvider` does not implement
> `TickerMode` muting, so animations keep ticking even if the HUD is pushed
> off-screen behind a route. For an always-on gameplay HUD that is fine and is the
> recommended path. If you need off-screen muting, use the alternative in the
> Appendix (widget owns vsync, hands the `AnimationController`s to the controller
> on attach). Do **not** silently mix the two.

---

## Step 2 — EnergyBarController (owns the animations + game rules)

Create `lib/hud/energy_bar_controller.dart`:

```dart
import 'package:flutter/material.dart';
import 'hud_element_controller.dart';

class EnergyBarController extends HudElementController {
  EnergyBarController({required this.maxEnergy});

  // ---- Display state (drives text; not animated) ----
  int level = 1;
  double maxEnergy;
  double displayEnergy = 0; // shown as "displayEnergy/maxEnergy"

  // ---- Owned animation controllers (stable references) ----
  late final AnimationController fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final AnimationController flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  // Swapped on each fill; the widget reads `.value` off this.
  Animation<double> fillAnimation = const AlwaysStoppedAnimation(0.0);
  double _lastPercent = 0.0;

  // ---- Events (game rules live here, not in the widget) ----

  /// Normal energy gain with no level-up. Interrupts any in-flight sequence.
  Future<void> setEnergy(double current) async {
    final gen = beginSequence();
    displayEnergy = current;
    notifyListeners(); // update text immediately
    await _animateFill(_lastPercent, current / maxEnergy, gen);
  }

  /// Level-up: fill to full, flash 3 cycles, reset, fill to the overflow amount.
  Future<void> levelUp({
    required int newLevel,
    required double overflow,
    required double newMax,
  }) async {
    final gen = beginSequence();

    if (!await _animateFill(_lastPercent, 1.0, gen)) return;
    if (!await _flashCycles(3, gen)) return;

    // Commit the new level at the moment of the flash.
    level = newLevel;
    maxEnergy = newMax;
    displayEnergy = overflow;
    notifyListeners();

    _lastPercent = 0.0;
    await _animateFill(0.0, overflow / newMax, gen);
  }

  // ---- Internals ----

  Future<bool> _animateFill(double from, double to, int gen) async {
    fill.reset();
    fillAnimation = Tween<double>(begin: from, end: to)
        .animate(CurvedAnimation(parent: fill, curve: Curves.easeInOut));
    await fill.forward();
    if (!isCurrent(gen)) return false; // a newer event superseded us
    _lastPercent = to;
    return true;
  }

  /// Counted cycles driven by the flash controller itself — NOT Future.delayed —
  /// so it is frame-synced and always ends cleanly at 0.
  Future<bool> _flashCycles(int cycles, int gen) async {
    for (var i = 0; i < cycles; i++) {
      flash.reset();
      await flash.forward();
      if (!isCurrent(gen)) return false;
      await flash.reverse();
      if (!isCurrent(gen)) return false;
    }
    flash.value = 0.0;
    return true;
  }

  @override
  void dispose() {
    fill.dispose();
    flash.dispose();
    super.dispose();
  }
}
```

Notes for the agent:
- `fill` and `flash` are **stable** references the widget listens to; only the
  `fillAnimation` *tween* is swapped. The widget reads `fillAnimation.value`.
- Every event calls `beginSequence()` and every `await` is followed by an
  `isCurrent(gen)` check. This is the cancellation guard — a newer event abandons
  the older suspended sequence instead of two flows fighting the same controllers.
- The flash uses counted `forward()`/`reverse()`, replacing the old
  `Future.delayed(600ms)` that could stop mid-cycle.

---

## Step 3 — Rewrite `HorizontalEnergyBar` as a pure view

The widget loses: all `AnimationController`s, `initState` animation setup,
`didUpdateWidget`, `_startLevelUpSequence`, `levelUpOccurred`, and every energy
prop. It takes only the controller.

```dart
class HorizontalEnergyBar extends StatelessWidget {
  const HorizontalEnergyBar({super.key, required this.controller});
  final EnergyBarController controller;

  @override
  Widget build(BuildContext context) {
    // Rebuild on: display changes (ChangeNotifier) + fill ticks + flash ticks.
    return AnimatedBuilder(
      animation: Listenable.merge([controller, controller.fill, controller.flash]),
      builder: (context, _) {
        final fillPercent = controller.fillAnimation.value;
        final flashValue = controller.flash.value; // 0..1

        // ... build exactly the same visual tree as before, but read:
        //   level      -> controller.level
        //   fill width -> fillPercent (FractionallySizedBox widthFactor)
        //   flash lerp -> Color.lerp(base, Colors.white, flashValue)
        //   text       -> '${controller.displayEnergy.toInt()}/${controller.maxEnergy.toInt()}'
        return const SizedBox(); // replace with the real tree
      },
    );
  }
}
```

- It can be a `StatelessWidget` now — no ticker lives here.
- Keep the existing `PixelArtTheme` visual structure; only the data sources change.
- Because it's a single `AnimatedBuilder`, you also fix the earlier nested-builder
  redundant-rebuild issue for free.

---

## Step 4 — Second controller (replicate the pattern)

Create `lib/hud/scoreboard_controller.dart` the same way. Own whatever animation
the score-pop needs; expose an event method:

```dart
class ScoreboardController extends HudElementController {
  int score = 0;

  late final AnimationController pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  Future<void> addPoints(int points) async {
    final gen = beginSequence();
    score += points;
    notifyListeners();
    pop.reset();
    await pop.forward();
    if (!isCurrent(gen)) return;
    await pop.reverse();
  }

  @override
  void dispose() {
    pop.dispose();
    super.dispose();
  }
}
```

The repeating shape for every HUD element: extend `HudElementController`, own its
`AnimationController`(s), expose awaitable event methods, guard with the token,
dispose the controllers.

---

## Step 5 — Thin facade

Create `lib/hud/hud_controller.dart`. **Coordination and disposal only — no
element state, no animation flags.**

```dart
import 'energy_bar_controller.dart';
import 'scoreboard_controller.dart';

class HudController {
  HudController({required double maxEnergy})
      : energy = EnergyBarController(maxEnergy: maxEnergy);

  final EnergyBarController energy;
  final ScoreboardController score = ScoreboardController();

  /// Cross-element event: everything starts together via Future.wait.
  Future<void> onTreatCaught({required int points, required double newEnergy}) {
    return Future.wait([
      score.addPoints(points),
      energy.setEnergy(newEnergy),
    ]);
  }

  void dispose() {
    energy.dispose();
    score.dispose();
  }
}
```

Guardrail: if a score value or animation flag ever appears as a field on
`HudController`, it belongs on a leaf controller instead.

---

## Step 6 — Wire into the game

1. Construct one `HudController` where `PachinkoGameWorld` and the Flutter HUD
   overlay are created. Pass the leaves to the widgets:
   `HorizontalEnergyBar(controller: hud.energy)`, scoreboard gets `hud.score`, etc.
2. In game logic, at the moment an event fires, call the controller — do **not**
   route it through a bool prop. Level-up detection (energy crossing the threshold,
   near the `treatCaught` accrual) calls `hud.energy.levelUp(...)`. Multi-element
   events call `hud.onTreatCaught(...)`.
3. **Do not `await` HUD calls from the game loop.** Fire-and-forget so gameplay
   never blocks on animation duration:

   ```dart
   // treat caught in a burst — latest energy value wins via the token
   unawaited(hud.onTreatCaught(points: 50, newEnergy: xp));
   ```

   The generation token means a newer event supersedes an in-flight one, so bursts
   don't queue up a backlog of stale fills. (`unawaited` is in `dart:async`.)
4. Dispose the `HudController` when the game/screen tears down.
5. The game holds only `HudController`. It has no `GlobalKey`, no reference to any
   widget `State`, and no knowledge of animation timing.

---

## Definition of done

- [ ] No `GlobalKey`, no `currentState` access anywhere in the HUD path.
- [ ] `AnimationController`s live on the element controllers; widgets own none.
- [ ] `HorizontalEnergyBar` is a pure `AnimatedBuilder` view (Stateless is fine);
      `levelUpOccurred`, `didUpdateWidget`, and the energy props are gone.
- [ ] Every event method calls `beginSequence()` and re-checks `isCurrent(gen)`
      after every `await`.
- [ ] Flash is counted `forward()`/`reverse()` cycles, not `Future.delayed`.
- [ ] Each widget's `AnimatedBuilder` listens only to its own controller/animations
      (a score update does not rebuild the energy bar).
- [ ] `HudController` holds only leaf controllers, coordination methods, dispose.
- [ ] Game calls are fire-and-forget (`unawaited`); the game holds no widget/State
      references and no timing constants.
- [ ] Every controller disposes its `AnimationController`s; `HudController.dispose`
      disposes all leaves.

## Assumptions to confirm

- Scoreboard widget API and score-pop animation are unseen — adapt
  `ScoreboardController` to the real animation.
- Where `PachinkoGameWorld` meets the Flutter HUD overlay is unseen — Step 6 wiring
  lives there.
- If an observable game-state/event stream already exists, leaf controllers could
  subscribe to it and the facade's coordination methods could be dropped. Flag this
  if present; otherwise proceed as specified.

---

## Appendix — alternative if you need off-screen ticker muting

If the HUD can be pushed behind a route and you want animations to pause (proper
`TickerMode` behaviour), have the **widget** provide vsync and hand the
`AnimationController`s to the controller on attach, detaching on dispose. The
controller degrades to no-ops (`?.`) while detached. This keeps muting but
reintroduces a small amount of lifecycle coupling — use it only if the muting
actually matters. Do not combine it with the self-vsync base in Step 1.
