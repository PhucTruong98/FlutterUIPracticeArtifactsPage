# State Management Pattern for Game Components

## Overview

This project uses an **Enum-based State Pattern** for managing component states. This provides type-safe, maintainable state management that's easy to extend.

## Current Implementation: PegBody

### PegState Enum

```dart
enum PegState {
  normal,   // Default state
  hit,      // Peg was just hit by treat
  // Easy to add more states:
  // poweredUp,
  // damaged,
  // frozen,
}
```

### State Management Structure

```dart
class PegBody extends BodyComponent with ContactCallbacks {
  // State management
  PegState _state = PegState.normal;
  TimerComponent? _stateTimer;  // ← Using TimerComponent instead of manual timer!

  /// Public getter for current state
  PegState get state => _state;

  /// Set the peg to a new state
  void _setState(PegState newState, {double? duration}) {
    if (_state != newState) {
      _state = newState;
      _spriteComponent.sprite = _getSpriteForState(newState);

      // Cancel previous timer if exists
      _stateTimer?.removeFromParent();
      _stateTimer = null;

      // Create new timer if duration specified
      if (duration != null) {
        _stateTimer = TimerComponent(
          period: duration,
          repeat: false,
          onTick: () => _handleStateTimeout(),
          removeOnFinish: true,
        );
        add(_stateTimer!);
      }
    }
  }

  /// Get the sprite corresponding to a state
  Sprite _getSpriteForState(PegState state) {
    switch (state) {
      case PegState.normal:
        return PachinkoAssets.pegNormal;
      case PegState.hit:
        return PachinkoAssets.pegHit;
    }
  }

  /// Handle what happens when state timer expires
  void _handleStateTimeout() {
    switch (_state) {
      case PegState.hit:
        _setState(PegState.normal);
        break;
      case PegState.normal:
        break;
    }
  }

  @override
  void onRemove() {
    // Clean up timer when component is removed
    _stateTimer?.removeFromParent();
    _stateTimer = null;
    super.onRemove();
  }
}
```

### Why TimerComponent?

We use Flame's `TimerComponent` instead of manually managing timers because:

✅ **Declarative** - Clear intent with less code
✅ **Automatic cleanup** - `removeOnFinish: true` cleans itself up
✅ **No update() needed** - No manual countdown logic
✅ **Pausable/resumable** - Easy to control
✅ **Flame-idiomatic** - Integrates with component lifecycle

**Old approach (❌ manual):**
```dart
double _stateTimer = 0;

void update(double dt) {
  if (_stateTimer > 0) {
    _stateTimer -= dt;
    if (_stateTimer <= 0) {
      _handleStateTimeout();
    }
  }
}
```

**New approach (✅ TimerComponent):**
```dart
TimerComponent? _stateTimer;

// No update() method needed!
// Timer automatically calls _handleStateTimeout() when expired
```

## How to Add New States

### Example: Adding a "Powered Up" State

**Step 1:** Add to enum
```dart
enum PegState {
  normal,
  hit,
  poweredUp,  // ← New state
}
```

**Step 2:** Add sprite to PachinkoAssets
```dart
// In PachinkoAssets.dart
static const String pegPoweredUpPath = '${_basePath}peg_powered_up.png';
static Sprite? _pegPoweredUp;

static Future<void> _loadPegSprites() async {
  _pegNormal = await Sprite.load(pegNormalPath, srcSize: Vector2.all(8));
  _pegHit = await Sprite.load(pegHitPath, srcSize: Vector2.all(8));
  _pegPoweredUp = await Sprite.load(pegPoweredUpPath, srcSize: Vector2.all(8));  // ← New
}

static Sprite get pegPoweredUp {
  assert(_pegPoweredUp != null);
  return _pegPoweredUp!;
}
```

**Step 3:** Add to sprite mapping
```dart
Sprite _getSpriteForState(PegState state) {
  switch (state) {
    case PegState.normal:
      return PachinkoAssets.pegNormal;
    case PegState.hit:
      return PachinkoAssets.pegHit;
    case PegState.poweredUp:  // ← New case
      return PachinkoAssets.pegPoweredUp;
  }
}
```

**Step 4:** Add timeout behavior (if needed)
```dart
void _handleStateTimeout() {
  switch (_state) {
    case PegState.hit:
      _setState(PegState.normal);
      break;
    case PegState.poweredUp:  // ← New case
      _setState(PegState.normal);
      break;
    case PegState.normal:
      break;
  }
}
```

**Step 5:** Add public method to trigger state
```dart
void powerUp() {
  if (_state == PegState.normal) {
    _setState(PegState.poweredUp, duration: 5.0);  // Power up for 5 seconds
  }
}
```

## Benefits

✅ **Type-safe**: Compiler catches typos and missing cases
✅ **No invalid states**: Can't be "hit" AND "normal" at the same time
✅ **Self-documenting**: Enum names clearly describe states
✅ **Easy to extend**: Just add enum value, sprite, and case
✅ **Automatic sprite switching**: Sprite updates when state changes
✅ **Centralized logic**: All state behavior in one place

## Example: Adding Multiple States

```dart
enum PegState {
  normal,
  hit,
  poweredUp,
  frozen,
  damaged,
}

// Usage:
void freeze() {
  _setState(PegState.frozen, duration: 3.0);
}

void damage() {
  if (_state != PegState.frozen) {  // Can't damage frozen pegs
    _setState(PegState.damaged);
  }
}

void repair() {
  if (_state == PegState.damaged) {
    _setState(PegState.normal);
  }
}
```

## State Transition Rules

You can add complex transition logic:

```dart
void _setState(PegState newState, {double? duration}) {
  // Validate transition
  if (!_isValidTransition(_state, newState)) {
    return;  // Invalid transition, ignore
  }

  if (_state != newState) {
    final oldState = _state;
    _state = newState;
    _stateTimer = duration ?? 0;
    _spriteComponent.sprite = _getSpriteForState(newState);

    // Optional callback
    _onStateTransition(oldState, newState);
  }
}

bool _isValidTransition(PegState from, PegState to) {
  // Example: Can't go from frozen directly to powered up
  if (from == PegState.frozen && to == PegState.poweredUp) {
    return false;
  }
  return true;
}
```

## Applying to Other Components

This pattern can be used for any component with multiple states:

```dart
enum TreatState {
  normal,
  golden,  // Worth more points
  rotten,  // Worth negative points
}

enum PuppyState {
  normal,
  happy,
  sad,
  excited,
}
```

Use the same structure: enum → _setState() → _getSpriteForState() → _handleStateTimeout()
