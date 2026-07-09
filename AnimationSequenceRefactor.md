Refactor the `PuppyComponent` animation system into a dedicated `PuppyAnimationController` that is solely responsible for animation flow.

## Goal

Currently, animation logic is split between:

* `_setState()`
* `_processQueue()`
* `_animationQueue`
* `_isPlayingQueued`
* `TimerComponent` transition logic

This results in two different systems making animation decisions.

Instead, create a dedicated `PuppyAnimationController` that becomes the single source of truth for:

* current animation
* animation queue
* animation transitions
* animation completion
* deciding what animation plays next

The `PuppyComponent` should become mostly a rendering component that delegates animation behavior to the controller.

---

## Desired architecture

```
Game Events
     │
     ▼
PuppyAnimationController
     │
     ▼
PuppyComponent (SpriteAnimationComponent)
```

The controller owns all animation sequencing.

The component should not contain queue logic or transition logic.

---

## Controller responsibilities

Create a `PuppyAnimationController` class.

It should own:

* current animation/state
* queue of pending animations
* transition rules
* completion callbacks
* play/queue APIs

Public API should look similar to:

```dart
controller.play(PuppyState.eating);

controller.queue(PuppyState.levelUp);

controller.queue(PuppyState.levelUp);
```

The caller should not need to know whether an animation interrupts immediately or gets queued.

The controller decides.

---

## Queue behavior

Replace the current `_animationQueue` implementation with a real queue (`Queue<T>` from `dart:collection`).

The queue should contain animation requests.

When an animation finishes:

* if queue is empty → transition to Idle
* otherwise → dequeue next animation and play it

The controller should be the only place that decides this.

---

## Transition rules

Instead of a large `_setState()` method with multiple `if/else` branches, move transition behavior into the controller.

Each animation should define its next animation.

For example:

Eating
→ Happy

Happy
→ Idle

LevelUp
→ Idle

The controller should automatically follow these transitions when an animation completes.

---

## Animation durations

Do not hardcode animation durations like:

```dart
period: 1.04
```

Instead derive the duration from the SpriteAnimation itself if possible (frame count × stepTime or another Flame API).

The goal is for artists to be able to change frame counts without requiring code changes.

---

## State

Keep `PuppyState` for now.

However, the controller should become the only class responsible for changing it.

`PuppyComponent` should never manually transition between states.

---

## Timers

If Flame provides a way to detect when a non-looping animation finishes, prefer that over manually hardcoding timers.

If not, derive timer durations dynamically from the animation instead of using constants.

---

## Component responsibilities

After refactoring, `PuppyComponent` should primarily:

* load animations
* render the current animation
* expose high-level methods like `celebrateTreat()` or `queueLevelUp()`, which simply delegate to the controller
* forward update/completion events if needed

It should not manage queue state or transition state itself.

---

## Code quality goals

* Single Responsibility Principle
* One "brain" responsible for animation sequencing
* Easy to add future animations (Sniff, Bark, Dance, Sleep, etc.) without modifying controller logic
* No duplicated transition logic
* No circular flow between queue processing and state transitions
* Clean, extensible, object-oriented design

When complete, explain:

1. The new architecture.
2. Why it is easier to extend.
3. Any tradeoffs introduced.
