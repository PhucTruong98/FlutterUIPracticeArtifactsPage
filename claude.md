# Pachinko Game - Architecture & Implementation Plan

## Overview
Pachinko mini-game for Geodyssey app featuring physics-based gameplay with animated puppy companion. Uses hybrid Flutter+Flame architecture for optimal balance between game performance and UI flexibility.

---

## Architecture Decision: Hybrid Flutter + Flame

### Why Hybrid (Not Full-Flame)?
- ✅ **UI Quality**: Polished Flutter widgets (EnergyGaugeWidget, LoadTreatButton, ScoreDisplayWidget)
- ✅ **Development Speed**: Reuse existing working UI components
- ✅ **Maintainability**: Widget composition patterns easier than manual Flame UI
- ✅ **No Performance Issues**: Current architecture runs smoothly
- ✅ **Best of Both Worlds**: Flame for physics/animations, Flutter for UI/state

### Architecture Layout
```
PachinkoGame (StatefulWidget)
├─ Top Section (Flutter)
│  ├─ Background: cloudTop.jpg
│  ├─ TreatInventoryWidget
│  └─ ScoreDisplayWidget
│
├─ Middle Section (Flame Game World #1)
│  └─ PachinkoGameWorld (Forge2DGame)
│      ├─ Physics simulation (pegs, walls, slots)
│      ├─ TreatBody with physics
│      └─ SlotZone collision detection
│
└─ Bottom Section (Hybrid Stack)
   ├─ Background: grassGroundBottom.jpg
   ├─ PuppyGameWorld (Flame Game World #2) - NEW
   │  ├─ Puppy sprite animations
   │  ├─ Treat drop animations
   │  └─ Sparkle particle effects
   └─ UI Overlay (Flutter widgets on top)
      ├─ EnergyGaugeWidget
      └─ LoadTreatButton
```

### Communication Flow
- **Shared State**: `GameState` (ChangeNotifier) - single source of truth
- **Main Game → Puppy Game**: Via GameState.notifyListeners()
- **No Direct Coupling**: Both game worlds independently listen to GameState

---

## Puppy Animation System - Implementation Plan

### Stage 1: Foundation ✅ (CURRENT)
**Goal**: Basic puppy animation responding to game events

**Assets**: Use existing static sprites
- `puppy_normal.png` (64x64)
- `puppy_happy.png` (64x64)
- `treat.png` (16x16)
- `grassGroundBottom.jpg`

**Files Created**:
1. `PuppyGameWorld.dart` - FlameGame instance for animations
2. `components/PuppyComponent.dart` - Puppy sprite with state switching

**Behavior**:
- Default: Show puppy_normal.png
- On treat caught: Switch to puppy_happy.png + bounce effect (2s)
- Return to normal

**Communication**:
```
SlotZone.treatCaught()
  → gameState.treatCaught(multiplier)
  → gameState.notifyListeners()
  → PuppyGameWorld._onGameStateChanged()
  → puppyComponent.celebrateTreat()
```

---

### Stage 2: Treat Drop Animation (TODO)
**Goal**: Animate treat falling from slot to puppy

**Assets Needed**:
- Option A: Reuse `treat.png` (start with this)
- Option B: `treat_falling.png` sprite sheet (4 frames, rotating) - future

**File to Create**:
- `components/TreatDropComponent.dart`

**Implementation**:
- SpriteComponent with MoveEffect.to() (0.5s drop)
- ScaleEffect for squash on landing
- onComplete() triggers puppy happy state
- Removes itself after animation

**Sequence**:
```
Treat lands in slot
  → TreatDropComponent created at top of puppy world
  → MoveEffect animates to puppy position
  → On complete: trigger puppy.celebrateTreat()
  → Component removes itself
```

---

### Stage 3: Sparkle Particle Effects (TODO)
**Goal**: Add visual polish when puppy eats treat

**Assets Needed**:
- Option A: Procedural rendering (colored circles/stars) - start with this
- Option B: `sparkle.png` (8x8 pixel art star) - future

**File to Create**:
- `components/SparkleEffect.dart`

**Implementation**:
- ParticleSystemComponent with custom particle generator
- Burst of 20-30 particles around puppy
- 0.5s duration, fade out + scale down
- Triggered after treat lands

---

### Stage 4: Full Sprite Sheet Animations (TODO)
**Goal**: Replace static sprites with frame-by-frame animations

**Assets to Create**:

1. **puppy_idle_sheet.png**
   - Size: 256x64 (4 frames × 64x64)
   - Frames: [ears twitch] → [blink] → [tail wag] → [neutral]
   - Loop: 0.2s per frame (0.8s total loop)

2. **puppy_eating_sheet.png**
   - Size: 384x64 (6 frames × 64x64)
   - Frames: [mouth open] → [chomp] → [chew1] → [chew2] → [swallow] → [lick lips]
   - One-shot: 0.15s per frame (0.9s total)

3. **puppy_happy_sheet.png**
   - Size: 256x64 (4 frames × 64x64)
   - Frames: [bounce up] → [bounce down] → [wag tail fast] → [sparkle eyes]
   - One-shot: 0.2s per frame (0.8s total)

**Implementation**:
- Update `PachinkoAssets.dart` with sprite sheet paths
- Convert PuppyComponent to use `SpriteAnimationComponent`
- State machine: idle (loop) → eating (once) → happy (once) → idle (loop)
- Use `SpriteAnimation.fromFrameData()` for sprite sheets

**Animation State Machine**:
```
┌─────────┐
│  IDLE   │ ←─────────────────────┐
│ (loop)  │                       │
└────┬────┘                       │
     │ treat caught              │ 2s timer
     ↓                           │
┌─────────┐                       │
│ EATING  │                       │
│ (once)  │                       │
└────┬────┘                       │
     │ animation complete         │
     ↓                           │
┌─────────┐                       │
│  HAPPY  │ ──────────────────────┘
│ (once)  │
└─────────┘
```

---

## Current File Structure

```
lib/shared/component/bigComponent/pachinko/
├── PachinkoGame.dart              # Main screen (StatefulWidget)
├── PachinkoGameWorld.dart         # Physics game world (Forge2DGame)
├── PuppyGameWorld.dart            # Animation game world (FlameGame) - NEW
├── PachinkoAssets.dart            # Asset loader
├── models/
│   └── GameState.dart             # Shared state (ChangeNotifier)
├── components/
│   ├── PegBody.dart               # Peg with collision/animation
│   ├── TreatBody.dart             # Treat physics body
│   ├── WallBody.dart              # Wall boundaries
│   ├── SlotZone.dart              # Slot collision zones
│   ├── PuppyComponent.dart        # Puppy sprite - NEW
│   ├── TreatDropComponent.dart    # Treat drop animation - TODO
│   └── SparkleEffect.dart         # Particle effects - TODO
├── widgets/
│   ├── TreatInventoryWidget.dart  # Shows remaining treats
│   ├── ScoreDisplayWidget.dart    # Score + collision count
│   ├── EnergyGaugeWidget.dart     # Puppy energy bar
│   └── LoadTreatButton.dart       # Load treat button
├── theme/
│   └── pixel_art_theme.dart       # Pixel art styling
└── painters/
    └── puppy_painter.dart         # OLD painter (will be deprecated)
```

---

## Network Integration (Future TODO)

### API Endpoints
- `GET /treats/count` - Fetch user's treat count
- `POST /session/start` - Start game session
- `POST /treats/dropped` - Send score after treat caught

### Integration Points
```dart
class _PachinkoGameState extends State<PachinkoGame> {
  @override
  void initState() async {
    // Fetch treat count from API
    final treatCount = await apiService.fetchTreatCount();
    gameState = GameState(remainingTreats: treatCount);

    // POST session started
    await apiService.postSessionStarted();
  }

  @override
  void dispose() {
    // Optional: POST session ended
    apiService.postSessionEnded();
    super.dispose();
  }

  void _onSlotCaught(double multiplier) {
    final score = (gameState.currentScore * multiplier).toInt();

    // POST treat dropped with score
    apiService.postTreatDropped(score);

    // Update local state
    gameState.treatCaught(multiplier: multiplier);
  }
}
```

---

## Performance Considerations

### Two GameWidget Instances
- **Main Game**: ~60 FPS (physics + sprites)
- **Puppy Game**: ~30 FPS (animations only)
- **Overhead**: Negligible on modern devices
- **Optimization**: Can pause puppy world when not visible

### State Management
- Single GameState instance shared between both worlds
- Only notifies listeners on actual changes
- UI rebuilds throttled (max 10 updates/sec for peg hits)

### Rendering Optimizations
- Pixel-perfect rendering: `filterQuality: FilterQuality.none`
- Cached Paint/TextPainter objects (no per-frame allocations)
- Sprite batching handled automatically by Flame

---

## Testing Checklist

### Stage 1 (Foundation)
- [ ] PuppyGameWorld renders in bottom section
- [ ] Puppy appears on grassGroundBottom.jpg background
- [ ] Puppy switches to happy when treat caught
- [ ] Puppy returns to normal after 2 seconds
- [ ] Energy gauge and button still functional
- [ ] No performance degradation

### Stage 2 (Treat Drop)
- [ ] Treat sprite appears at top when caught
- [ ] Treat animates smoothly to puppy
- [ ] Puppy happy state triggers after treat lands
- [ ] Treat component removes itself after animation

### Stage 3 (Sparkles)
- [ ] Sparkles appear when treat lands
- [ ] Particle animation completes in 0.5s
- [ ] No performance impact from particles

### Stage 4 (Sprite Sheets)
- [ ] Idle animation loops continuously
- [ ] Eating animation plays once when treat caught
- [ ] Happy animation plays after eating
- [ ] State machine transitions smoothly
- [ ] All animations are pixel-perfect

---

## Assets Roadmap

### Current Assets ✅
- `peg_normal.png` (8x8)
- `peg_hit.png` (8x8)
- `treat.png` (16x16)
- `puppy_normal.png` (64x64)
- `puppy_happy.png` (64x64)
- `skyBackDrop.png` (772x1030)
- `pipe.png` (458x409)
- `cloudTop.jpg`
- `grassGroundBottom.jpg`

### To Create (Priority Order)
1. **puppy_idle_sheet.png** (256x64, 4 frames) - Stage 4
2. **puppy_eating_sheet.png** (384x64, 6 frames) - Stage 4
3. **puppy_happy_sheet.png** (256x64, 4 frames) - Stage 4
4. **sparkle.png** (8x8, optional) - Stage 3
5. **treat_falling.png** (64x16, 4 frames, optional) - Stage 2

---

## Known Issues & Future Improvements

### Current Limitations
- Puppy uses static sprites (Stage 1) - will be replaced with animations
- No treat drop animation yet
- No sparkle effects yet

### Future Enhancements
- Animated background (grass/flowers swaying)
- More puppy animations (sad when out of treats, excited when loaded)
- Sound effects integration
- Combo system (multiple treats in quick succession)
- Different puppy reactions based on score multiplier

---

## References

### Flame Documentation
- [SpriteAnimationComponent](https://docs.flame-engine.org/latest/flame/components.html#spriteanimationcomponent)
- [Effects](https://docs.flame-engine.org/latest/flame/effects.html)
- [Particle System](https://docs.flame-engine.org/latest/flame/rendering/particles.html)

### Performance Patterns
- Cached objects: `SlotZone.dart:84` (TextPainter/Paint caching)
- State machine: `PegBody.dart:45` (PegState enum)
- Effects usage: `PegBody.dart:76` (ScaleEffect for bounce)
- Timer sequencing: `PegBody.dart:95` (TimerComponent for state transitions)

---

**Last Updated**: 2026-06-29
**Current Stage**: Stage 1 - Foundation (In Progress)
**Next Steps**: Create PuppyGameWorld.dart and PuppyComponent.dart
