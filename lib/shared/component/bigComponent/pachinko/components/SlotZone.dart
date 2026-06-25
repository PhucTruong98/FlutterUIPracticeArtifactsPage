import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'TreatBody.dart';
import '../PachinkoGameWorld.dart';

/// Sensor zone for individual slot with score multiplier
class SlotZone extends BodyComponent with ContactCallbacks {
  final Vector2 position;
  final Vector2 size;
  final double multiplier;
  final int slotNumber;

  late PachinkoGameWorld _game;  // Cached game reference

  SlotZone({
    required this.position,
    required this.size,
    required this.multiplier,
    required this.slotNumber,
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
    print('SlotZone $slotNumber (x$multiplier) collision with ${other.runtimeType}');
    if (other is TreatBody) {
      // Update game state with multiplier via cached game reference
      _game.gameState.treatCaught(multiplier: multiplier);

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
    // Draw slot zone with color based on multiplier
    Color slotColor;
    if (multiplier >= 1.7) {
      slotColor = Colors.amber.withValues(alpha: 0.2);  // Gold for x1.7
    } else if (multiplier >= 1.5) {
      slotColor = Colors.orange.withValues(alpha: 0.15);  // Orange for x1.5
    } else {
      slotColor = Colors.green.withValues(alpha: 0.1);  // Green for x1.2
    }

    final paint = Paint()
      ..color = slotColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      ),
      paint,
    );

    // Draw multiplier text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'x$multiplier',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }
}
