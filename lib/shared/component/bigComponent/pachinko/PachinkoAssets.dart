import 'package:flame/components.dart';
import 'package:flame/flame.dart';

/// Centralized asset loader for Pachinko pixel art sprites
class PachinkoAssets {
  // Asset paths
  static const String _basePath = 'pachinko/';

  static const String pegNormalPath = '${_basePath}peg_normal.png';
  static const String pegHitPath = '${_basePath}peg_hit.png';
  static const String treatPath = '${_basePath}treat.png';
  static const String puppyNormalPath = '${_basePath}puppy_normal.png';
  static const String puppyHappyPath = '${_basePath}puppy_happy.png';

  // Cached sprites
  static Sprite? _pegNormal;
  static Sprite? _pegHit;
  static Sprite? _treat;
  static Sprite? _puppyNormal;
  static Sprite? _puppyHappy;

  /// Preload all pachinko assets
  static Future<void> loadAll() async {
    await Future.wait([
      _loadPegSprites(),
      _loadTreatSprite(),
      _loadPuppySprites(),
    ]);
  }

  /// Load peg sprites
  static Future<void> _loadPegSprites() async {
    _pegNormal = await Sprite.load(
      pegNormalPath,
      srcSize: Vector2.all(8), // Assuming 32x32 sprites
    );
    _pegHit = await Sprite.load(
      pegHitPath,
      srcSize: Vector2.all(8),
    );
  }

  /// Load treat sprite
  static Future<void> _loadTreatSprite() async {
    _treat = await Sprite.load(
      treatPath,
      srcSize: Vector2.all(16),
    );
  }

  /// Load puppy sprites
  static Future<void> _loadPuppySprites() async {
    _puppyNormal = await Sprite.load(
      puppyNormalPath,
      srcSize: Vector2.all(64), // Assuming 64x64 or will scale
    );
    _puppyHappy = await Sprite.load(
      puppyHappyPath,
      srcSize: Vector2.all(64),
    );
  }

  // Getters for sprites
  static Sprite get pegNormal {
    assert(_pegNormal != null, 'Peg normal sprite not loaded. Call loadAll() first.');
    return _pegNormal!;
  }

  static Sprite get pegHit {
    assert(_pegHit != null, 'Peg hit sprite not loaded. Call loadAll() first.');
    return _pegHit!;
  }

  static Sprite get treat {
    assert(_treat != null, 'Treat sprite not loaded. Call loadAll() first.');
    return _treat!;
  }

  static Sprite get puppyNormal {
    assert(_puppyNormal != null, 'Puppy normal sprite not loaded. Call loadAll() first.');
    return _puppyNormal!;
  }

  static Sprite get puppyHappy {
    assert(_puppyHappy != null, 'Puppy happy sprite not loaded. Call loadAll() first.');
    return _puppyHappy!;
  }

  /// Clear all cached sprites
  static void clear() {
    _pegNormal = null;
    _pegHit = null;
    _treat = null;
    _puppyNormal = null;
    _puppyHappy = null;
  }
}
