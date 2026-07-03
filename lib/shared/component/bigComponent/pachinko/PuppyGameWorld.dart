import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'models/GameState.dart';
import 'components/PuppyComponent.dart';
import 'PachinkoAssets.dart';

/// Flame game world for puppy animations
///
/// Separate from main physics world to keep animations isolated.
/// Listens to GameState for treat caught events and triggers puppy animations.
class PuppyGameWorld extends FlameGame {
  final GameState gameState;

  late PuppyComponent puppyComponent;
  late PachinkoAssets pachinkoAssets;

  final double puppyZoom  = 2.0;

  PuppyGameWorld({
    required this.gameState,
  }) : super();

  @override
  Future<void> onLoad() async {
    await super.onLoad();


    // Initialize assets with global image cache and preload all images
    pachinkoAssets = PachinkoAssets(Flame.images);
    await pachinkoAssets.loadAll();

    _createBackground();

    // Create puppy component
    puppyComponent = PuppyComponent(
      // position: Vector2(size.x / 2, size.y / 2), // Left side, vertically centered

      position: Vector2(0,0), // Left side, vertically centered

      size: Vector2.all(120 * puppyZoom), // 120x120 to match sprite sheet frame size
      assets: pachinkoAssets,
    );

    await world.add(puppyComponent);

    // Apply 2x zoom to camera
    camera.viewfinder.zoom = 1.0;

    // Listen to game state changes
    gameState.addListener(_onGameStateChanged);
  }

  @override
  void onRemove() {
    gameState.removeListener(_onGameStateChanged);
    super.onRemove();
  }

  /// Handle game state changes
  void _onGameStateChanged() {
    // Trigger puppy celebration when treat is caught
    if (gameState.statusMessage?.contains('Collected') == true) {
      puppyComponent.celebrateTreat();
    }
  }

  void _createBackground()
  {
    final background = SpriteComponent(
      sprite: pachinkoAssets.grassGroundBottom,
      size: Vector2(size.x, size.y),
      position: Vector2.zero(),
      anchor: Anchor.center,
      paint: Paint()..filterQuality = FilterQuality.none, // Pixel-perfect rendering

      
      );

    world.add(background);
  }
}
