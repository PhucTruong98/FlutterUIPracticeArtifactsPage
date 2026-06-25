import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'TreatBody.dart';
import '../PachinkoGameWorld.dart';

/// Sensor zone at bottom where puppy catches the treat
class PuppyCatchZone extends BodyComponent with ContactCallbacks {
  final Vector2 position;
  final Vector2 size;

  late PachinkoGameWorld _game;  // Cached game reference

  PuppyCatchZone({
    required this.position,
    required this.size,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: position,
      userData: this,
    );

    final body = world.createBody(bodyDef);

    // Create rectangular sensor
    final shape = PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2);

    final fixtureDef = FixtureDef(
      shape,
      isSensor: true, // Make it a sensor (no physical collision)
    );

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Cache game reference once during load
    _game = findGame() as PachinkoGameWorld;
  }

  @override
  void beginContact(Object other, Contact contact) {
    print('PuppyCatchZone collision with ${other.runtimeType}');
    if (other is TreatBody) {
      // Update game state via cached game reference
      _game.gameState.treatCaught();

      // Use a timer to delay removal slightly for visual feedback
      final timer = TimerComponent(
        period: 0.5,
        repeat: false,
        onTick: () => _game.removeTreat(),
        removeOnFinish: true,
      );
      parent?.add(timer);
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw semi-transparent catch zone
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      ),
      paint,
    );
  }
}
