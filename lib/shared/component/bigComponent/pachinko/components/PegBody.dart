import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'TreatBody.dart';
import '../PachinkoAssets.dart';
import '../models/GameState.dart';

/// Enum representing all possible states for a peg
enum PegState {
  normal,   // Default state
  hit,      // Peg was just hit by treat
  // Easy to add more states:
  // poweredUp,
  // damaged,
  // frozen,
}

/// Static physics body for Pachinko pegs
class PegBody extends BodyComponent with ContactCallbacks {
  final Vector2 position;
  final double radius;
  final PachinkoAssets assets;  // Asset manager for sprites
  final GameState gameState;

  // State management
  PegState _state = PegState.normal;
  TimerComponent? _stateTimer;

  late SpriteComponent _spriteComponent;

  PegBody({
    required this.position,
    required this.assets,
    required this.gameState,
    this.radius = 0.3,
  });

  /// Public getter for current state
  PegState get state => _state;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create sprite component for pixel art rendering
    // Sprite size should match physics body radius (radius * 2 for diameter)
    final spriteSize = radius * 2;

    _spriteComponent = SpriteComponent(
      sprite: _getSpriteForState(_state),
      size: Vector2.all(spriteSize),
      anchor: Anchor.center,
      paint: Paint()..filterQuality = FilterQuality.none, // Pixel-perfect rendering
    );

    add(_spriteComponent);
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: position,
      userData: this,
    );

    final body = world.createBody(bodyDef);

    // Create circular shape
    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      restitution: 1.3, // High bounciness for pegs
      friction: 0.1,
    );

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is TreatBody) {
      onHit();
    }
  }

  // No update() method needed - TimerComponent handles timing automatically!

  /// Mark peg as hit and start animation
  void onHit() {
    if (_state != PegState.hit) {
      // Update game state
      gameState.recordPegHit();

      _setState(PegState.hit, duration: 0.3); // Return to normal after 0.3s

      // Add elastic bounce scale animation
      _spriteComponent.add(
        ScaleEffect.by(
          Vector2.all(1.15), // Scale up by 15%
          EffectController(
            duration: 0.3,
            curve: Curves.elasticOut, // Springy overshoot effect
            alternate: true, // Return to normal size
          ),
        ),
      );
    }
  }

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
        return assets.pegNormal;
      case PegState.hit:
        return assets.pegHit;
      // When adding new states, add cases here:
      // case PegState.poweredUp:
      //   return assets.pegPoweredUp;
    }
  }

  /// Handle what happens when state timer expires
  void _handleStateTimeout() {
    switch (_state) {
      case PegState.hit:
        // Return to normal after hit animation
        _setState(PegState.normal);
        break;
      case PegState.normal:
        // Normal state doesn't timeout
        break;
      // Add timeout behavior for other states here
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
