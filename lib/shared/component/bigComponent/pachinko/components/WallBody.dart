import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../config/PachinkoConfig.dart';

/// Static wall boundaries for the Pachinko board
class WallBody extends BodyComponent {
  final Vector2 start;
  final Vector2 end;
  final Color? color;

  WallBody({
    required this.start,
    required this.end,
    this.color, // Optional - if null, wall is invisible
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: Vector2.zero(),
      userData: this,
    );

    final body = world.createBody(bodyDef);

    // Create edge shape from start to end
    final shape = EdgeShape()..set(start, end);

    final fixtureDef = FixtureDef(
      shape,
      restitution: PachinkoConfig.wallRestitution,
      friction: PachinkoConfig.wallFriction,
    );

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    // Only render if color is provided
    if (color == null) return;

    final paint = Paint()
      ..color = color!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    canvas.drawLine(
      Offset(start.x, start.y),
      Offset(end.x, end.y),
      paint,
    );
  }
}
