import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'TreatBody.dart';
import '../models/GameState.dart';
import '../PachinkoGameWorld.dart';

/// Sensor zone at bottom where puppy catches the treat
class PuppyCatchZone extends BodyComponent with ContactCallbacks {
  final Vector2 position;
  final Vector2 size;
  final GameState gameState;

  PuppyCatchZone({
    required this.position,
    required this.size,
    required this.gameState,
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
  void beginContact(Object other, Contact contact) {
    print('PuppyCatchZone collision with ${other.runtimeType}');
    if (other is TreatBody) {
      // Update game state
      gameState.treatCaught();

      // Get the world to clear currentTreat and cancel miss timer
      // We use a timer to delay removal slightly for visual feedback
      final gameWorld = parent?.parent;
      if (gameWorld != null) {
        final timer = TimerComponent(
          period: 0.5,
          repeat: false,
          onTick: () {
            // Call the world's removeTreat to properly clean up
            if (gameWorld is Forge2DWorld && gameWorld is PachinkoGameWorld) {
              (gameWorld as PachinkoGameWorld).removeTreat();
            }
          },
          removeOnFinish: true,
        );
        parent?.add(timer);
      }
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
