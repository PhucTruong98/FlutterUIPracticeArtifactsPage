import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../PachinkoAssets.dart';

/// Enum representing puppy animation states
enum PuppyState {
  idle,    // Looping idle animation
  eating,  // One-shot eating animation
  happy,   // One-shot happy celebration
}

/// Animated puppy component that reacts to treats
///
/// Uses sprite sheet animations for smooth frame-by-frame animations
class PuppyComponent extends SpriteAnimationComponent {
  final PachinkoAssets assets;

  PuppyState _state = PuppyState.idle;
  TimerComponent? _stateTransitionTimer;

  // Cached animations
  late SpriteAnimation _idleAnimation;
  late SpriteAnimation _eatingAnimation;
  late SpriteAnimation _happyAnimation;

  PuppyComponent({
    required super.position,
    required super.size,
    required this.assets,
  }) : super(
          anchor: Anchor.center,
          paint: Paint()..filterQuality = FilterQuality.none, // Pixel-perfect
        );

  /// Public getter for current state
  PuppyState get state => _state;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load all animations from preloaded assets
    _idleAnimation = assets.dogIdleAnimation;
    _eatingAnimation = assets.dogEatingAnimation;
    _happyAnimation = assets.dogHappyAnimation;

    // Set initial animation to idle
    animation = _idleAnimation;
  }

  /// Trigger celebration animation when puppy receives treat
  void celebrateTreat() {
    if (_state == PuppyState.eating || _state == PuppyState.happy) {
      return; // Already celebrating
    }

    _setState(PuppyState.eating);
  }

  /// Update puppy state and animation
  void _setState(PuppyState newState) {
    if (_state == newState) return;

    _state = newState;
    animation = _getAnimationForState(_state);

    // Cancel any pending transition
    _stateTransitionTimer?.removeFromParent();

    // Schedule state transitions
    if (_state == PuppyState.eating) {
      // After eating animation finishes, transition to happy
      _stateTransitionTimer = TimerComponent(
        period: 0.9, // 9 frames × 0.1s
        repeat: false,
        onTick: () => _setState(PuppyState.happy),
        removeOnFinish: true,
      );
      add(_stateTransitionTimer!);
    } else if (_state == PuppyState.happy) {
      // After happy animation finishes, return to idle
      _stateTransitionTimer = TimerComponent(
        period: 1.04, // 13 frames × 0.08s
        repeat: false,
        onTick: () => _setState(PuppyState.idle),
        removeOnFinish: true,
      );
      add(_stateTransitionTimer!);
    }
  }

  /// Get animation for given state
  SpriteAnimation _getAnimationForState(PuppyState state) {
    switch (state) {
      case PuppyState.idle:
        return _idleAnimation;
      case PuppyState.eating:
        return _eatingAnimation;
      case PuppyState.happy:
        return _happyAnimation;
    }
  }

  @override
  void onRemove() {
    _stateTransitionTimer?.removeFromParent();
    super.onRemove();
  }
}
