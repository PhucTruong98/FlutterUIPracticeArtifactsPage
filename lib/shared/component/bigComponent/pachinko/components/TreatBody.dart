import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'PegBody.dart';
import 'PuppyCatchZone.dart';

/// Dynamic physics body for the falling treat (dog bone)
class TreatBody extends BodyComponent with ContactCallbacks {
  final Vector2 position;
  final double radius;
  final Function()? onPegHit;
  final Function()? onCaught;

  TreatBody({
    required this.position,
    this.radius = 0.5,
    this.onPegHit,
    this.onCaught,
  });

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
      restitution: 0.5, // Bounciness
      friction: 0.3,
      density: 1.0,
    );

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PegBody) {
      onPegHit?.call();
    }
    // Note: PuppyCatchZone handles the onTreatCaught callback
  }

  @override
  void render(Canvas canvas) {
    // Draw treat as a bone shape using simple shapes
    final paint = Paint()
      ..color = const Color(0xFFD2B48C) // Tan color
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF8B7355) // Darker brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.03;

    // Simplified bone shape - horizontal bar with circles at ends
    final boneLength = radius * 1.5;
    final boneThickness = radius * 0.4;
    final endRadius = radius * 0.35;

    // Left end circles
    canvas.drawCircle(Offset(-boneLength / 2, -endRadius * 0.3), endRadius * 0.5, paint);
    canvas.drawCircle(Offset(-boneLength / 2, endRadius * 0.3), endRadius * 0.5, paint);

    // Right end circles
    canvas.drawCircle(Offset(boneLength / 2, -endRadius * 0.3), endRadius * 0.5, paint);
    canvas.drawCircle(Offset(boneLength / 2, endRadius * 0.3), endRadius * 0.5, paint);

    // Center bar
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: boneLength,
      height: boneThickness,
    );
    canvas.drawRect(rect, paint);

    // Outlines
    canvas.drawCircle(Offset(-boneLength / 2, -endRadius * 0.3), endRadius * 0.5, outlinePaint);
    canvas.drawCircle(Offset(-boneLength / 2, endRadius * 0.3), endRadius * 0.5, outlinePaint);
    canvas.drawCircle(Offset(boneLength / 2, -endRadius * 0.3), endRadius * 0.5, outlinePaint);
    canvas.drawCircle(Offset(boneLength / 2, endRadius * 0.3), endRadius * 0.5, outlinePaint);
    canvas.drawRect(rect, outlinePaint);
  }
}
