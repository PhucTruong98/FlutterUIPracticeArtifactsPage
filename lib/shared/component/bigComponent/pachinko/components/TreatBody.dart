import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import '../PachinkoAssets.dart';
import '../config/PachinkoConfig.dart';

/// Dynamic physics body for the falling treat (dog bone)
/// Starts in oscillating state (kinematic body moving left-right)
class TreatBody extends BodyComponent with ContactCallbacks {
  final Vector2 position;
  final double radius;
  final PachinkoAssets assets;  // Asset manager for sprites

  late SpriteComponent _spriteComponent;

  // Oscillation state - starts as true (oscillating by default)
  bool isOscillating = true;
  final double oscillationSpeed = PachinkoConfig.treatOscillationSpeed;
  final double maxX = PachinkoConfig.treatOscillationMaxX;

  TreatBody({
    required this.position,
    required this.assets,
    double? radius,
  }) : radius = radius ?? PachinkoConfig.treatRadius;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create sprite component for pixel art rendering
    final spriteSize = radius * 2;

    _spriteComponent = SpriteComponent(
      sprite: assets.treat,
      size: Vector2.all(spriteSize),
      anchor: Anchor.center,
      paint: Paint()..filterQuality = FilterQuality.none, // Pixel-perfect rendering
    );

    add(_spriteComponent);
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.kinematic,  // Start as kinematic (oscillating)
      position: position,
      userData: this,
      linearVelocity: Vector2(oscillationSpeed, 0),  // Start moving right
    );

    body = world.createBody(bodyDef);

    // Create circular shape for physics
    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      restitution: PachinkoConfig.treatRestitution, // Bounciness
      friction: PachinkoConfig.treatFriction,
      density: PachinkoConfig.treatDensity,
    );

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    // Contact logic handled by other components:
    // - PegBody: Handles peg collisions and scoring
    // - SlotZone: Handles treat catching with multipliers
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Handle oscillation boundary checking and reversal
    if (isOscillating && body.bodyType == BodyType.kinematic) {
      final currentX = body.position.x;

      // Reverse direction if treat reaches boundaries
      if (currentX >= maxX || currentX <= -maxX) {
        body.linearVelocity = Vector2(-body.linearVelocity.x, 0);
      }
    }
  }

  /// Start oscillating left-right at the top of the board
  void startOscillating() {
    body.setType(BodyType.kinematic);
    body.linearVelocity = Vector2(oscillationSpeed, 0); // Start moving right
    isOscillating = true;
  }

  /// Drop the treat (switch to normal physics)
  void drop() {
    isOscillating = false;
    body.linearVelocity = Vector2.zero();
    body.setType(BodyType.dynamic);
  }
}
