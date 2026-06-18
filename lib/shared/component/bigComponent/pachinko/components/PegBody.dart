import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'TreatBody.dart';

/// Static physics body for Pachinko pegs
class PegBody extends BodyComponent with ContactCallbacks {
  final Vector2 position;
  final double radius;
  bool isHit = false;
  double hitAnimationTimer = 0;

  PegBody({
    required this.position,
    this.radius = 0.3,
  });

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
      restitution: 0.8, // High bounciness for pegs
      friction: 0.1,
    );

    body.createFixture(fixtureDef);

    return body;
  }

  /// Mark peg as hit and start animation
  void onHit() {
    isHit = true;
    hitAnimationTimer = 0.3; // Animation duration in seconds
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is TreatBody) {
      onHit();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Countdown hit animation
    if (hitAnimationTimer > 0) {
      hitAnimationTimer -= dt;
      if (hitAnimationTimer <= 0) {
        isHit = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw peg as a simple circle with gradient effect
    final paint = Paint()
      ..color = isHit ? const Color(0xFFFFD700) : const Color(0xFFFF8C00)
      ..style = PaintingStyle.fill;

    // Main circle
    canvas.drawCircle(Offset.zero, radius, paint);

    // Shine effect
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-radius * 0.25, -radius * 0.25), radius * 0.3, shinePaint);

    // Outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF8B4513).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.05;
    canvas.drawCircle(Offset.zero, radius, outlinePaint);

    // Glow when hit
    if (isHit) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.2);
      canvas.drawCircle(Offset.zero, radius * 1.5, glowPaint);
    }
  }
}
