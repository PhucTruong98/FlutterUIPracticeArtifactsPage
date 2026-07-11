Refactor the puppy animation system from a simple state-transition graph into an animation sequence engine.

## Background

The current controller assumes every animation has exactly one predetermined next state.

Example:

Eating -> Happy -> Idle

LevelUp -> Idle

This works for simple linear animations but is too limiting.

Examples that are difficult with the current architecture:

* Petting the puppy
* Random idle behaviors
* Different celebration chains
* Reusing the same animation in different contexts
* Branching animation flows
* User interaction during an animation

I want to move away from a fixed "nextState" graph.

---

# Goal

The animation controller should become a generic animation sequencing engine.

Instead of saying

```dart
controller.play(PuppyState.eating);
```

I should be able to build animation sequences like

```dart
AnimationSequence([
    PuppyState.eating,
    PuppyState.happy,
    PuppyState.idle,
]);
```

or

```dart
AnimationSequence([
    PuppyState.bark,
    PuppyState.tailWag,
    PuppyState.idle,
]);
```

or

```dart
AnimationSequence([
    PuppyState.jump,
    PuppyState.spin,
    PuppyState.levelUp,
    PuppyState.idle,
]);
```

The controller's responsibility is simply executing sequences.

It should not know why a sequence exists.

---

# Responsibilities of the controller

The controller should own:

* current animation
* currently executing sequence
* queue of sequences
* animation completion
* moving to the next animation in the current sequence
* starting the next queued sequence when the current one finishes

The controller should NOT contain hardcoded logic like

Eating -> Happy

Happy -> Idle

Those relationships should exist only inside the sequence that requested them.

---

# AnimationSequence

Create an AnimationSequence class.

Example API:

```dart
AnimationSequence([
    PuppyState.eating,
    PuppyState.happy,
    PuppyState.idle,
]);
```

The sequence should internally keep track of which animation is currently executing.

The controller simply asks the sequence for the next animation until it completes.

---

# Queue

The queue should become

```dart
Queue<AnimationSequence>
```

instead of

```dart
Queue<PuppyState>
```

Only one sequence executes at a time.

When a sequence finishes:

* if another sequence exists, start it
* otherwise return to Idle

---

# Completion

The controller should advance through a sequence whenever an animation completes.

If possible, prefer animation completion callbacks over hardcoded timers.

If timers are required, derive the duration from the animation instead of hardcoding values.

---

# No hardcoded transition graph

Remove:

* transition rules map
* nextState definitions
* hardcoded state graph

The controller should never know that Eating normally leads to Happy.

That relationship belongs to the sequence that requested it.

---

# Extensibility

The design should make it easy to support future systems like:

CelebrateTreatBehavior

PetBehavior

SleepBehavior

RandomIdleBehavior

LevelUpBehavior

Those systems should only create AnimationSequence objects.

They should not modify controller internals.

---

# Example usage

These should all be possible:

```dart
controller.play(
    AnimationSequence([
        PuppyState.eating,
        PuppyState.happy,
        PuppyState.idle,
    ]),
);
```

```dart
controller.queue(
    AnimationSequence([
        PuppyState.jump,
        PuppyState.spin,
        PuppyState.idle,
    ]),
);
```

```dart
controller.queue(
    AnimationSequence([
        PuppyState.bark,
        PuppyState.tailWag,
        PuppyState.idle,
    ]),
);
```

The controller should simply execute sequences in order.

---

# Code quality goals

* Single responsibility
* No hardcoded animation graph
* Sequence-driven instead of graph-driven
* Easy to add new animations without modifying the controller
* Easy to build future behavior classes on top of this
* Clean object-oriented design

After implementing, explain:

1. The new architecture.
2. How animation sequences work.
3. Why this design is more extensible than a fixed transition graph.
4. How future behavior classes would be built on top of it.
