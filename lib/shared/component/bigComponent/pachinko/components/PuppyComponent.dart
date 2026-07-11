import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../PachinkoAssets.dart';
import 'PuppyAnimationController.dart';
import 'AnimationSequence.dart';

/// Animated puppy component that reacts to treats
///
/// Uses sprite sheet animations for smooth frame-by-frame animations.
/// Delegates animation sequencing to PuppyAnimationController.
class PuppyComponent extends SpriteAnimationComponent {
  final PachinkoAssets assets;

  // Animation controller manages state machine and queue
  late PuppyAnimationController _animationController;

  // Cached animations
  late SpriteAnimation _idleAnimation;
  late SpriteAnimation _eatingAnimation;
  late SpriteAnimation _happyAnimation;
  late SpriteAnimation _levelUpAnimation;


  PuppyComponent({
    required super.position,
    required super.size,
    required this.assets,
  }) : super(
          anchor: Anchor.center,
          paint: Paint()..filterQuality = FilterQuality.none, // Pixel-perfect
        );

  /// Public getter for current state
  PuppyState get state => _animationController.currentState;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load all animations from preloaded assets
    _idleAnimation = assets.dogIdleAnimation;
    _eatingAnimation = assets.dogEatingAnimation;
    _happyAnimation = assets.dogHappyAnimation;
    _levelUpAnimation = assets.dogLevelUpAnimation;

    // Initialize animation controller with duration lookup function
    _animationController = PuppyAnimationController(
      getDuration: assets.getDuration,
    );

    // Register callback to update animation when state changes
    _animationController.onStateChanged = (newState) {
      animation = _getAnimationForState(newState);
    };

    // Set initial animation to idle
    animation = _idleAnimation;
  }

  /// Trigger celebration animation when puppy receives treat
  void celebrateTreat() {
    _animationController.play(
      AnimationSequence([
        PuppyState.eating,
        PuppyState.happy,
        // PuppyState.idle,
      ]),
    );
  }

  /// Queue a level-up animation (can be called multiple times)
  /// Animations will play sequentially without interruption
  void queueLevelUp() {
    _animationController.queue(
      AnimationSequence([
        PuppyState.levelUp,
        // PuppyState.idle,
      ]),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // No sync needed - controller notifies us via onStateChanged callback
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
      case PuppyState.levelUp:
        return _levelUpAnimation;
    }
  }

  @override
  void onRemove() {
    _animationController.dispose();
    super.onRemove();
  }
}
