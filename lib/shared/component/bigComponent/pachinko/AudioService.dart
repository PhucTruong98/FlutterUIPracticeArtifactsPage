import 'package:flame_audio/flame_audio.dart';

/// Centralized audio service for Pachinko game sounds
///
/// This class manages all audio assets following the same pattern as PachinkoAssets:
/// 1. Preload audio files with loadAll()
/// 2. Play sounds synchronously via helper methods
class AudioService {
  // Private constructor to prevent instantiation
  AudioService._();

  // Singleton instance
  static final AudioService instance = AudioService._();

  // Audio paths
  static const String _basePath = 'pachinko/';

  static const String popSoundPath = '${_basePath}popSound.mp3';

  // Add more sound paths here as needed:
  // static const String treatDropPath = '${_basePath}treatDrop.mp3';
  // static const String levelUpPath = '${_basePath}levelUp.mp3';
  // static const String pegHitPath = '${_basePath}pegHit.mp3';

  /// Preload all pachinko audio files
  ///
  /// Call this once during game initialization (in onLoad).
  /// Audio files are loaded asynchronously and cached for instant playback.
  Future<void> loadAll() async {
    await FlameAudio.audioCache.loadAll([
      popSoundPath,
      // Add more sound paths here when available
    ]);
  }

  /// Play the pop sound when treat lands in slot
  void playPopSound() {
    FlameAudio.play(popSoundPath);
  }

  // Add more sound playback methods here:
  // void playTreatDrop() {
  //   FlameAudio.play(treatDropPath);
  // }
  //
  // void playLevelUp() {
  //   FlameAudio.play(levelUpPath);
  // }
  //
  // void playPegHit() {
  //   FlameAudio.play(pegHitPath);
  // }
}
