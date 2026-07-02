import 'package:flame/components.dart';
import 'package:flame/cache.dart';

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
  static const String grassGroundBottomPath = '${_basePath}grassGroundBottom.jpg';
  static const String dogIdlePath = '${_basePath}dogIdle.png';
  static const String dogEatingPath = '${_basePath}dogEating.png';
  static const String dogHappyPath = '${_basePath}dogHappy.png';

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
      dogIdlePath,
      dogEatingPath,
      dogHappyPath,
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
}
