import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import '../PachinkoAssets.dart';

/// Dynamic physics body for the falling treat (dog bone)
class TreatBody extends BodyComponent with ContactCallbacks {
  final Vector2 position;
  final double radius;
  final PachinkoAssets assets;  // Asset manager for sprites

  late SpriteComponent _spriteComponent;

  TreatBody({
    required this.position,
    required this.assets,
    this.radius = 0.5,
  });

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
      type: BodyType.dynamic,
      position: position,
      userData: this,
    );

    final body = world.createBody(bodyDef);

    // Create circular shape for physics
    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.1, // Bounciness
      friction: 0.3,
      density: 10.0,
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
}
