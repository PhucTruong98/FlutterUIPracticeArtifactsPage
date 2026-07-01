import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/components.dart';
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

  PuppyGameWorld({
    required this.gameState,
  }) : super();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize assets with global image cache and preload all images
    pachinkoAssets = PachinkoAssets(Flame.images);
    await pachinkoAssets.loadAll();

    // Create puppy component
    puppyComponent = PuppyComponent(
      position: Vector2(80, size.y / 2), // Left side, vertically centered
      size: Vector2.all(80), // 80x80 for better visibility
      assets: pachinkoAssets,
    );

    await add(puppyComponent);

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
}
