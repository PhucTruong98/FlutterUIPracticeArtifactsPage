# Pachinko Game - Architecture Documentation

## Overview

A physics-based Pachinko game built with Flutter, Flame, and Forge2D featuring:
- Physics-based treat dropping through pegs
- Slot multipliers for scoring
- Animated puppy companion with energy/level system
- Pixel art retro aesthetic

**Tech Stack:**
- Flutter (UI framework)
- Flame (game engine)
- Forge2D (physics simulation)
- Custom architecture mixing Flutter widgets + Flame game worlds

---

## High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  PachinkoGame (StatefulWidget - Main Coordinator)           │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │  GameState   │  │HudController │  │ PuppyGameWorld  │   │
│  │(ChangeNotifier)│  │   (Facade)   │  │  (FlameGame)    │   │
│  └──────┬───────┘  └──────┬───────┘  └─────────────────┘   │
│         │                  │                                 │
│         │ notifies         │ controls                        │
│         ▼                  ▼                                 │
│  ┌──────────────────────────────────────┐                   │
│  │ PachinkoGameWorld (Forge2DGame)      │                   │
│  │  ├─ PegBody (collision detection)    │                   │
│  │  ├─ TreatBody (physics)              │                   │
│  │  ├─ SlotZone (scoring)               │                   │
│  │  └─ WallBody (boundaries)            │                   │
│  └──────────────────────────────────────┘                   │
│                                                              │
│  Widgets: HorizontalEnergyBar, ScoreDisplayWidget, etc.    │
└─────────────────────────────────────────────────────────────┘

Config: PachinkoConfig (static constants)
```

---

## Component Responsibilities

### 1. PachinkoGame (StatefulWidget)
**File:** `PachinkoGame.dart`

**Role:** Main coordinator/mediator for the entire game

**Responsibilities:**
- Creates and owns GameState, HudController, game worlds
- Coordinates Flutter UI with Flame game worlds
- Manages widget tree (top HUD, game board, puppy area, buttons)
- **CURRENT ISSUE:** Does NOT coordinate HUD updates (GameState does this directly)

**Key Methods:**
- `initState()` - Initialize all components
- `_loadTreat()` - Load treat into launcher
- `_dropTreat()` - Drop treat with chosen position

---

### 2. GameState (ChangeNotifier)
**File:** `models/GameState.dart`

**Role:** Core game logic and state management

**Responsibilities:**
- Track game state (treats remaining, loaded status, round score)
- Enforce game rules (can load treat?, game over?)
- Record game events (peg hits, treats caught/missed)
- **CURRENT ISSUE:** Directly calls HudController methods (tight coupling)

**Key Properties:**
```dart
int remainingTreats;
bool isTreatLoaded;
String? statusMessage;  // User-facing feedback
int currentRoundScore;
int currentRoundCollisions;
HudController? hudController;  // ⚠️ ARCHITECTURAL ISSUE
```

**Key Methods:**
- `recordPegHit()` - Increment score, call HUD
- `treatCaught(multiplier)` - Calculate final score, call HUD, return score
- `reset()` - Reset game to initial state

**Problem:**
GameState has a reference to HudController and calls it directly:
```dart
void recordPegHit() {
  currentRoundScore += PachinkoConfig.pegHitPoints;
  notifyListeners();
  unawaited(hudController?.onPegHit(PachinkoConfig.pegHitPoints)); // ⚠️
}
```

This violates separation of concerns - game logic should not depend on UI.

---

### 3. HudController (Facade)
**File:** `hud/hud_controller.dart`

**Role:** Coordinate HUD element controllers

**Responsibilities:**
- Own leaf controllers (EnergyBarController, ScoreboardController)
- Route events to appropriate controllers
- Provide unified API for HUD updates

**Key Methods:**
- `onPegHit(points)` - Update score with pop animation
- `onTreatCaught(finalScore, currentEnergy)` - Handle energy/level-up

**Structure:**
```dart
class HudController {
  final EnergyBarController energy;
  final ScoreboardController score;

  Future<void> onPegHit(int points) async {
    await score.addPointsAndCollision(points);
  }

  Future<void> onTreatCaught({
    required int finalScore,
    required double currentEnergy,
  }) async {
    await energy.onTreatCaught(finalScore);
    score.resetRound();
  }
}
```

---

### 4. EnergyBarController (HudElementController)
**File:** `hud/energy_bar_controller.dart`

**Role:** Manage energy bar state and animations

**Responsibilities:**
- Track current energy, level, max energy
- Own fill and flash AnimationControllers
- Handle level-up sequences (fill → flash → refill)
- **NEW:** `onTreatCaught(newScore)` handles multi-level-ups

**Key Features:**
- Controller-owned animations (survive widget rebuilds)
- Generation token pattern for cancellation
- Async/await animation sequencing

**Key Methods:**
- `setEnergy(current)` - Normal energy update
- `levelUp({newLevel, overflow, newMax})` - Single level-up (deprecated?)
- `onTreatCaught(newScore)` - Handle multi-level-ups with while loop

---

### 5. ScoreboardController (HudElementController)
**File:** `hud/scoreboard_controller.dart`

**Role:** Manage score and collision count with pop animation

**Key Methods:**
- `addPoints(points)` - Add score with pop
- `addPointsAndCollision(points)` - Add both score and collision (used by peg hits)
- `incrementCollision()` - Just increment collision
- `resetRound()` - Clear score/collision after treat caught

---

### 6. PachinkoGameWorld (Forge2DGame)
**File:** `PachinkoGameWorld.dart`

**Role:** Physics simulation for the game board

**Responsibilities:**
- Manage physics world (gravity, bodies)
- Create board layout (pegs, walls, slots)
- Spawn and remove treats
- Provide board dimensions as static getters

**Key Components:**
- `List<PegBody> pegs` - All peg bodies
- `List<SlotZone> slots` - Bottom slot zones
- `TreatBody? currentTreat` - Currently active treat

**Key Methods:**
- `_createPegs()` - Generate peg layout from config
- `_createSlots()` - Create slot zones with multipliers
- `spawnTreat(position)` - Add treat to physics world
- `removeTreat()` - Remove treat from world

---

### 7. Game Components

#### PegBody (BodyComponent)
**File:** `components/PegBody.dart`

**Responsibilities:**
- Static physics body for pegs
- Detect collisions with treats
- Play hit animation (sprite change + scale effect)
- **Call GameState.recordPegHit()** on collision

**State Machine:** normal ↔ hit (0.3s duration)

#### TreatBody (BodyComponent)
**File:** `components/TreatBody.dart`

**Responsibilities:**
- Dynamic physics body for falling treat
- Apply physics properties (mass, friction, bounciness)

#### SlotZone (BodyComponent)
**File:** `components/SlotZone.dart`

**Responsibilities:**
- Sensor zones at bottom of board
- Detect when treat enters slot
- **Call GameState.treatCaught(multiplier)** on collision
- Render slot visual (color based on multiplier)
- Create divider walls between slots

#### WallBody (BodyComponent)
**File:** `components/WallBody.dart`

**Responsibilities:**
- Static edge shapes for board boundaries
- Apply wall physics (restitution, friction)

---

### 8. UI Widgets

#### HorizontalEnergyBar (StatelessWidget)
**File:** `widgets/HorizontalEnergyBar.dart`

**Pure view widget** - No state, just renders from EnergyBarController

**Listens to:**
- `controller` (level, displayEnergy changes)
- `controller.fill` (fill animation ticks)
- `controller.flash` (flash animation ticks)

**Renders:**
- Level number with flash color
- Progress bar with fill animation
- Flash effect during level-up

#### ScoreDisplayWidget (StatelessWidget)
**File:** `widgets/ScoreDisplayWidget.dart`

**Pure view widget** - Renders from ScoreboardController

**Listens to:**
- `controller` (score, collisionCount changes)
- `controller.pop` (pop animation ticks)

**Renders:**
- Score number
- Collision count (hits)
- Pop scale effect

---

### 9. PuppyGameWorld (FlameGame)
**File:** `PuppyGameWorld.dart`

**Role:** Animate puppy companion separate from physics

**Responsibilities:**
- Listen to GameState changes
- Trigger puppy animations (idle, eating, happy)
- Manage PuppyComponent

**Listens to GameState:**
- When treats caught → play eating animation → play happy animation

---

### 10. PachinkoConfig (Static Constants)
**File:** `config/PachinkoConfig.dart`

**Role:** Centralized game constants for easy tuning

**Categories:**
- Scoring & Game Rules (maxPuppyEnergy, pegHitPoints, slotMultipliers)
- Physics (gravity, restitution, friction, body sizes)
- Board Layout (dimensions, peg arrangement, slot count)
- Animations (durations, cycles, effects)

**Access:** `PachinkoConfig.pegHitPoints`

---

## Data Flow & Communication

### Current Flow (PROBLEMATIC)

**Peg Hit Event:**
```
1. Treat hits peg
2. PegBody.onHit() called
3. PegBody → gameState.recordPegHit()
4. GameState increments score
5. GameState → hudController.onPegHit(50)  ⚠️ COUPLING
6. HudController → scoreboardController.addPointsAndCollision(50)
7. ScoreboardController animates pop
```

**Treat Caught Event:**
```
1. Treat enters slot
2. SlotZone.beginContact() called
3. SlotZone → gameState.treatCaught(multiplier)
4. GameState calculates finalScore
5. GameState → hudController.onTreatCaught(...)  ⚠️ COUPLING
6. HudController → energyBarController.onTreatCaught(finalScore)
7. EnergyBarController handles level-up logic
8. SlotZone → gameWorld.removeTreat()
```

### Why Current Flow is Problematic

1. **Bidirectional Dependency**
   - GameState → HudController (calls HUD methods)
   - HudController → GameState (reads energy for level-up logic)

2. **Violates Separation of Concerns**
   - GameState (core logic) depends on HudController (presentation)
   - Can't unit test GameState without mocking HudController
   - Can't reuse GameState with different UI

3. **Wrong Dependency Direction**
   - UI should depend on game logic, not vice versa
   - GameState should be pure, framework-agnostic

4. **Mixed Responsibilities**
   - GameState manages both game rules AND triggers UI updates

---

## Proposed Solutions

### Option A: Explicit Event Fields in GameState

**Concept:** GameState emits events that PachinkoGame consumes

**Implementation:**
```dart
class GameState extends ChangeNotifier {
  // Event fields (cleared after read)
  int? _pendingPegHitPoints;
  int? _pendingTreatScore;

  void recordPegHit() {
    currentRoundScore += PachinkoConfig.pegHitPoints;
    _pendingPegHitPoints = PachinkoConfig.pegHitPoints;
    notifyListeners();
  }

  int treatCaught({double multiplier = 1.0}) {
    final finalScore = (currentRoundScore * multiplier).toInt();
    _pendingTreatScore = finalScore;
    notifyListeners();
    return finalScore;
  }

  (int?, int?) consumeEvents() {
    final peg = _pendingPegHitPoints;
    final treat = _pendingTreatScore;
    _pendingPegHitPoints = null;
    _pendingTreatScore = null;
    return (peg, treat);
  }
}

// In PachinkoGame:
void _onGameStateChanged() {
  final (pegHit, treatScore) = gameState.consumeEvents();

  if (pegHit != null) {
    unawaited(hudController.onPegHit(pegHit));
  }

  if (treatScore != null) {
    unawaited(hudController.onTreatCaught(
      finalScore: treatScore,
      currentEnergy: hudController.energy.displayEnergy,
    ));
  }
}
```

**Pros:**
✅ Type safe - events are strongly typed
✅ Clear intent - explicit event declarations
✅ Decoupled - statusMessage independent of logic
✅ No string parsing
✅ Testable - can assert events fired
✅ Extensible - can pass complex objects

**Cons:**
❌ More boilerplate - event fields, consume method
❌ Manual clearing - must remember to clear events
❌ More state - additional fields in GameState

---

### Option B: Check statusMessage in PachinkoGame

**Concept:** PachinkoGame parses statusMessage to detect events

**Implementation:**
```dart
// In PachinkoGame:
void _onGameStateChanged() {
  final msg = gameState.statusMessage;

  if (msg != null && msg.contains("Treat Collected!")) {
    // Parse score from "Treat Collected! 150 Points (x1.5)"
    final scoreMatch = RegExp(r'(\d+) Points').firstMatch(msg);
    if (scoreMatch != null) {
      final score = int.parse(scoreMatch.group(1)!);
      unawaited(hudController.onTreatCaught(
        finalScore: score,
        currentEnergy: hudController.energy.displayEnergy,
      ));
    }
  }

  // Detect peg hit by checking if currentRoundScore changed?
  // ... complicated logic ...
}
```

**Pros:**
✅ Simpler - no extra fields
✅ Already exists - statusMessage is there

**Cons:**
❌ String fragility - changing message text breaks logic
❌ Mixed concerns - statusMessage serves dual purpose
❌ No type safety - must parse strings
❌ Localization breaks it - translated messages break detection
❌ Ambiguous - hard to extract data reliably
❌ No structured data - can't pass complex info
❌ Timing issues - message might change before read

---

### Option C: Track State Changes (Diff-based)

**Concept:** PachinkoGame tracks previous state and detects deltas

**Implementation:**
```dart
// In PachinkoGame:
int _lastRoundScore = 0;

void _onGameStateChanged() {
  final scoreDelta = gameState.currentRoundScore - _lastRoundScore;

  if (scoreDelta > 0) {
    // But how do we know if it's peg hit or treat caught?
    // Need additional signals...
    hudController.onPegHit(scoreDelta);
  }

  _lastRoundScore = gameState.currentRoundScore;
}
```

**Pros:**
✅ No new fields in GameState

**Cons:**
❌ Ambiguous - can't distinguish event types
❌ Complex logic - need to track multiple previous values
❌ State explosion - what if multiple events fire simultaneously?
❌ Fragile - easy to miss edge cases

---

## Additional Architectural Question: Puppy Level-Up Animation

**Context:** We want to add a puppy level-up animation that plays when the puppy reaches a new level.

**Requirements:**
- Play during energy bar flash (simultaneous feedback)
- Queue after current puppy animation (don't interrupt eating/happy)

**Question:** Who should trigger the puppy level-up animation?

### Option A: GameState coordinates
```dart
// GameState has reference to both HudController AND PuppyGameWorld
gameState.treatCaught() → detects level-up → puppyGameWorld.onLevelUp()
```
**Issue:** Same coupling problem, now with PuppyGameWorld too

### Option B: EnergyBarController triggers via callback
```dart
// EnergyBarController has onLevelUpCallback
energyBarController.onTreatCaught() → detects level-up → onLevelUpCallback()
  → (wired by HudController) → GameState method → PuppyGameWorld
```
**Issue:** Complex chain, hard to follow

### Option C: PachinkoGame monitors energy level
```dart
// PachinkoGame listens to both GameState and HudController
void _onGameStateChanged() {
  // Handle HUD updates
  // Also check if hudController.energy.level changed
  // If so, trigger puppyGameWorld.onLevelUp()
}
```
**Issue:** PachinkoGame needs to track previous level

### Option D: Event-based (if we use Option A for HUD)
```dart
// GameState emits levelUpEvent
// PachinkoGame consumes and routes to PuppyGameWorld
```
**Most Consistent:** Aligns with event-based HUD coordination

---

## Questions for Architectural Review

1. **Primary Question:** How should PachinkoGame coordinate HUD updates?
   - Option A: Explicit event fields (type safe, more code)
   - Option B: Parse statusMessage (simple, fragile)
   - Option C: Track state changes (complex, ambiguous)
   - Other alternatives?

2. **Consistency:** Should we use the same pattern for PuppyGameWorld coordination?

3. **Trade-offs:** Is the additional boilerplate of event fields worth the type safety and clarity?

4. **Scalability:** If we add more game events (combos, achievements, power-ups), which pattern scales best?

5. **Testing:** Which approach makes unit testing GameState easiest?

6. **Best Practices:** What's the industry standard for game state → UI coordination in Flutter/Flame games?

---

## Current File Structure

```
lib/shared/component/bigComponent/pachinko/
├── PachinkoGame.dart              # Main coordinator (StatefulWidget)
├── PachinkoGameWorld.dart         # Physics world (Forge2DGame)
├── PuppyGameWorld.dart            # Animation world (FlameGame)
├── PachinkoAssets.dart            # Asset loader
│
├── models/
│   └── GameState.dart             # Game logic (ChangeNotifier)
│
├── hud/
│   ├── hud_element_controller.dart    # Base class
│   ├── energy_bar_controller.dart     # Energy/level state
│   ├── scoreboard_controller.dart     # Score/collision state
│   └── hud_controller.dart            # Facade coordinator
│
├── components/
│   ├── PegBody.dart               # Peg collision/animation
│   ├── TreatBody.dart             # Treat physics
│   ├── WallBody.dart              # Wall boundaries
│   ├── SlotZone.dart              # Slot collision/scoring
│   └── PuppyComponent.dart        # Puppy sprite animations
│
├── widgets/
│   ├── HorizontalEnergyBar.dart   # Energy bar view
│   ├── ScoreDisplayWidget.dart    # Score view
│   ├── TreatInventoryWidget.dart  # Treat count view
│   └── LoadTreatButton.dart       # Load treat button
│
├── config/
│   └── PachinkoConfig.dart        # Centralized constants
│
└── theme/
    └── pixel_art_theme.dart       # Pixel art styling
```

---

## Key Design Patterns Used

1. **Mediator Pattern** - PachinkoGame coordinates between GameState, HudController, game worlds
2. **Observer Pattern** - ChangeNotifier/notifyListeners for state updates
3. **Facade Pattern** - HudController provides unified API for HUD elements
4. **Composition** - Game built from small, focused components
5. **Controller-View Separation** - Controllers own animations, widgets are pure views

---

## Summary

**Current Problem:** GameState has direct reference to HudController, creating tight coupling and violating separation of concerns.

**Goal:** Refactor so PachinkoGame acts as clean mediator between game logic (GameState) and presentation (HudController).

**Need Decision On:** Best pattern for event communication from GameState to PachinkoGame.
