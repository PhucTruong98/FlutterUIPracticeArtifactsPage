import 'package:flame/components.dart';
import 'package:flame/cache.dart';
import 'components/PuppyAnimationController.dart';

/// Centralized asset loader for Pachinko pixel art sprites
///
/// This class wraps the game's image cache and provides convenient
/// access to sprites following Flame's best practices pattern:
/// 1. Preload images with loadAll()
/// 2. Access sprites synchronously via getters using game.images.fromCache()
class PachinkoAssets {
  final Images images;  // Game's image cache instance

  PachinkoAssets(this.images);

  // Asset paths
  static const String _basePath = 'pachinko/';

  static const String pegNormalPath = '${_basePath}peg_normal.png';
  static const String pegHitPath = '${_basePath}peg_hit.png';
  static const String treatPath = '${_basePath}treat.png';
  static const String puppyNormalPath = '${_basePath}puppy_normal.png';
  static const String puppyHappyPath = '${_basePath}puppy_happy.png';
  static const String skyBackdropPath = '${_basePath}skyBackDrop.png';
  static const String pipePath = '${_basePath}pipe.png';
  static const String cloudTopPath = '${_basePath}cloudTop.jpg';
  static const String grassGroundBottomPath = '${_basePath}grassGroundBottom.png';
  static const String grassGroundBottom2Path = '${_basePath}grassGroundBottom2.png';
  static const String dogIdlePath = '${_basePath}dogIdle.png';
  static const String dogEatingPath = '${_basePath}dogEating.png';
  static const String dogHappyPath = '${_basePath}dogHappy.png';
  static const String dogLevelUpPath = '${_basePath}dogLevelUp.png';

  // Sprite metadata (srcSize values for pixel art)
  static final Vector2 pegSize = Vector2.all(8);
  static final Vector2 treatSize = Vector2.all(16);
  static final Vector2 puppySize = Vector2.all(64);

  /// Preload all pachinko images into the game's image cache
  ///
  /// Call this once during game initialization (in onLoad).
  /// Images are loaded asynchronously and cached for instant synchronous access.
  Future<void> loadAll() async {
    await images.loadAll([
      pegNormalPath,
      pegHitPath,
      treatPath,
      puppyNormalPath,
      puppyHappyPath,
      skyBackdropPath,
      pipePath,
      cloudTopPath,
      grassGroundBottomPath,
      grassGroundBottom2Path,
      dogIdlePath,
      dogEatingPath,
      dogHappyPath,
      dogLevelUpPath
    ]);
  }

  /// Getters create sprites on-demand from cached images
  ///
  /// These are synchronous and fast - just wrapping the cached image
  /// with sprite metadata. Can be called repeatedly without performance impact.

  Sprite get pegNormal => Sprite(
        images.fromCache(pegNormalPath),
        srcSize: pegSize,
      );

  Sprite get pegHit => Sprite(
        images.fromCache(pegHitPath),
        srcSize: pegSize,
      );

  Sprite get treat => Sprite(
        images.fromCache(treatPath),
        srcSize: treatSize,
      );

  Sprite get puppyNormal => Sprite(
        images.fromCache(puppyNormalPath),
        // srcSize: puppySize,
      );

  Sprite get puppyHappy => Sprite(
        images.fromCache(puppyHappyPath),
        // srcSize: puppySize,
      );

  Sprite get skyBackdrop => Sprite(
        images.fromCache(skyBackdropPath),
        // No srcSize - use full image dimensions (772x1030)
      );

  Sprite get pipe => Sprite(
        images.fromCache(pipePath),
        // No srcSize - use full image dimensions (458x409)
      );

  Sprite get cloudTop => Sprite(
        images.fromCache(cloudTopPath),
        // No srcSize - use full image dimensions
      );

  Sprite get grassGroundBottom => Sprite(
        images.fromCache(grassGroundBottomPath),
        // No srcSize - use full image dimensions
      );

  /// Grass sway animation - 2-frame alternating background
  SpriteAnimation get grassSwayAnimation => SpriteAnimation.spriteList(
        [
          Sprite(images.fromCache(grassGroundBottomPath)),
          Sprite(images.fromCache(grassGroundBottom2Path)),
        ],
        stepTime: 1.0, // 1.5 seconds per frame = 3s full cycle
        loop: true,
      );

  /// Dog sprite sheet animations
  SpriteAnimation get dogIdleAnimation => SpriteAnimation.fromFrameData(
        images.fromCache(dogIdlePath),
        SpriteAnimationData.sequenced(
          amount: 9,
          stepTime: 0.15,
          textureSize: Vector2.all(120),
          loop: true,
        ),
      );

  SpriteAnimation get dogEatingAnimation => SpriteAnimation.fromFrameData(
        images.fromCache(dogEatingPath),
        SpriteAnimationData.sequenced(
          amount: 9,
          stepTime: 0.1,
          textureSize: Vector2.all(120),
          loop: false,
        ),
      );

  SpriteAnimation get dogHappyAnimation => SpriteAnimation.fromFrameData(
        images.fromCache(dogHappyPath),
        SpriteAnimationData.sequenced(
          amount: 13,
          stepTime: 0.08,
          textureSize: Vector2.all(120),
          loop: false,
        ),
      );

    SpriteAnimation get dogLevelUpAnimation => SpriteAnimation.fromFrameData(
        images.fromCache(dogLevelUpPath),
        SpriteAnimationData.sequenced(
          amount: 13,
          stepTime: 0.08,
          textureSize: Vector2.all(120),
          loop: false,
        ),
      );

  // Animation duration helpers
  // Calculated from frame count × step time

  /// Duration of dog eating animation in seconds
  double get dogEatingDuration => 9 * 0.1; // 0.9s

  /// Duration of dog happy animation in seconds
  double get dogHappyDuration => 13 * 0.08; // 1.04s

  /// Duration of dog level-up animation in seconds
  double get dogLevelUpDuration => 13 * 0.08; // 1.04s

  /// Get animation duration by state
  ///
  /// This function is used by PuppyAnimationController to lookup
  /// how long each animation should play before transitioning.
  double getDuration(PuppyState state) {
    switch (state) {
      case PuppyState.eating:
        return dogEatingDuration;
      case PuppyState.happy:
        return dogHappyDuration;
      case PuppyState.levelUp:
        return dogLevelUpDuration;
      case PuppyState.idle:
        return 0; // Idle loops forever, no transition
    }
  }
}
