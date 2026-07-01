import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../PachinkoAssets.dart';

/// Enum representing puppy animation states
enum PuppyState {
  normal,   // Idle/default state
  happy,    // Celebrating after receiving treat
}

/// Animated puppy component that reacts to treats
///
/// Stage 1: Uses static sprites (puppy_normal.png, puppy_happy.png)
/// Future: Will be converted to SpriteAnimationComponent with sprite sheets
class PuppyComponent extends SpriteComponent {
  final PachinkoAssets assets;

  PuppyState _state = PuppyState.normal;
  TimerComponent? _celebrationTimer;

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

    // Set initial sprite from preloaded assets
    sprite = assets.puppyNormal;
  }

  /// Trigger celebration animation when puppy receives treat
  void celebrateTreat() {
    if (_state == PuppyState.happy) {
      return; // Already celebrating
    }

    _setState(PuppyState.happy);

    // Add bounce effect
    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(
          duration: 0.3,
          curve: Curves.elasticOut,
          alternate: true,
        ),
      ),
    );

    // Return to normal after 2 seconds
    _celebrationTimer?.removeFromParent();
    _celebrationTimer = TimerComponent(
      period: 2.0,
      repeat: false,
      onTick: () => _setState(PuppyState.normal),
      removeOnFinish: true,
    );
    add(_celebrationTimer!);
  }

  /// Update puppy state and sprite
  void _setState(PuppyState newState) {
    if (_state == newState) return;

    _state = newState;
    sprite = _getSpriteForState(_state);
  }

  /// Get sprite for given state
  Sprite _getSpriteForState(PuppyState state) {
    switch (state) {
      case PuppyState.normal:
        return assets.puppyNormal;
      case PuppyState.happy:
        return assets.puppyHappy;
    }
  }

  @override
  void onRemove() {
    _celebrationTimer?.removeFromParent();
    super.onRemove();
  }
}
