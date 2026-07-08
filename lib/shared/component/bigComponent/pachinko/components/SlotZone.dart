import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'TreatBody.dart';
import 'WallBody.dart';
import '../PachinkoGameWorld.dart';
import '../PachinkoAssets.dart';

/// Sensor zone for individual slot with score multiplier
class SlotZone extends BodyComponent with ContactCallbacks {
  final Vector2 position;
  final Vector2 size;
  final double multiplier;
  final int slotNumber;
  final PachinkoAssets assets;
  final bool createLeftWall;
  final double wallHeight;

  late PachinkoGameWorld _game;  // Cached game reference
  late TextPainter _textPainter;  // Cached to avoid recreation every frame
  late Paint _fillPaint;  // Cached paint object

  SlotZone({
    required this.position,
    required this.size,
    required this.multiplier,
    required this.slotNumber,
    required this.assets,
    this.createLeftWall = false, 
    required this.wallHeight,  // Most slots don't create left wall by default
  }) : super(priority: 10);  // Render on top of treats (default priority 0)

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

    // Calculate slot color once based on multiplier
    Color slotColor;
    if (multiplier >= 1.7) {
      slotColor = Colors.amber.withValues(alpha: 0.2);  // Gold for x1.7
    } else if (multiplier >= 1.5) {
      slotColor = Colors.orange.withValues(alpha: 0.15);  // Orange for x1.5
    } else {
      slotColor = Colors.green.withValues(alpha: 0.1);  // Green for x1.2
    }

    // Initialize paint object once
    _fillPaint = Paint()
      ..color = slotColor
      ..style = PaintingStyle.fill;

    // Initialize TextPainter once
    _textPainter = TextPainter(
      text: TextSpan(
        text: 'x$multiplier',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Add pipe sprite component
    // Move pipe up by wall height (5 units) to align with slot walls
    final pipeSprite = SpriteComponent(
      sprite: assets.pipe,
      size: Vector2(size.x, wallHeight),  // Scale pipe to match slot size
      position: Vector2(0, size.y/2 - wallHeight/2),  // Move up by half wall height (5/2)
      anchor: Anchor.center,
      paint: Paint()..filterQuality = FilterQuality.none,
    );
    add(pipeSprite);

    // Create left divider wall if requested
    if (createLeftWall && parent != null) {
      final double wallX = position.x - (size.x / 2);  // Left edge of slot
      final double wallYTop = position.y + size.y/2 - wallHeight;
      final double wallYBottom = position.y + (size.y / 2);

      final leftWall = WallBody(
        start: Vector2(wallX, wallYTop),
        end: Vector2(wallX, wallYBottom),
        // color: const Color.fromARGB(255, 139, 69, 19),  // Brown divider
      );

      parent?.add(leftWall);
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is TreatBody) {
      // Update game logic
      // _game.game.treatCaught(multiplier: multiplier);

      // Trigger coordinator callback (async, fire-and-forget)
      unawaited(_game.onTreatCaughtCallback(multiplier));

      // Use a timer to delay removal slightly for visual feedback
      final timer = TimerComponent(
        period: 0.0,
        repeat: false,
        onTick: () => _game.removeTreat(),
        removeOnFinish: true,
      );
      parent?.add(timer);
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw slot zone using cached paint (no object creation!)
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      ),
      _fillPaint,
    );

    // Draw multiplier text using cached TextPainter (no recreation!)
    _textPainter.paint(
      canvas,
      Offset(-_textPainter.width / 2, -_textPainter.height / 2),
    );
  }

  @override
  void onRemove() {
    _textPainter.dispose();
    super.onRemove();
  }
}
