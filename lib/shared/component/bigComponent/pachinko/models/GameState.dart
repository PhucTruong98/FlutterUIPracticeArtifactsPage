import 'package:flutter/foundation.dart';

/// Game state model for Pachinko game
class GameState extends ChangeNotifier {
  static const double maxPuppyEnergy = 2000.0;

  int remainingTreats;
  int currentScore;
  int collisionCount;
  double puppyEnergy;
  bool isTreatLoaded;
  String? statusMessage;

  GameState({
    this.remainingTreats = 5,
    this.currentScore = 0,
    this.collisionCount = 0,
    this.puppyEnergy = 0,
    this.isTreatLoaded = false,
    this.statusMessage,
  });

  /// Reset game to initial state
  void reset() {
    remainingTreats = 5;
    currentScore = 0;
    collisionCount = 0;
    puppyEnergy = 0;
    isTreatLoaded = false;
    statusMessage = null;
    notifyListeners();
  }

  /// Load a treat (consume from inventory)
  bool loadTreat() {
    if (remainingTreats > 0 && !isTreatLoaded) {
      remainingTreats--;
      isTreatLoaded = true;
      statusMessage = 'Tap to Drop';
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Drop the loaded treat
  bool dropTreat() {
    if (isTreatLoaded) {
      isTreatLoaded = false;
      statusMessage = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Record a peg collision
  void recordPegHit() {
    collisionCount++;
    currentScore += 50;
    notifyListeners();
  }

  /// Treat caught by puppy - end round
  void treatCaught() {
    // Add energy based on score
    puppyEnergy += currentScore;
    if (puppyEnergy > GameState.maxPuppyEnergy) {
      puppyEnergy = GameState.maxPuppyEnergy;
    }

    statusMessage = 'Treat Collected! $currentScore Points';

    // Reset round score and collision count
    currentScore = 0;
    collisionCount = 0;
    notifyListeners();
  }

  /// Treat missed (timed out or settled without being caught)
  void treatMissed() {
    statusMessage = 'Missed!';

    // Reset round score and collision count
    currentScore = 0;
    collisionCount = 0;
    notifyListeners();
  }

  /// Get energy percentage (0.0 to 1.0)
  double get energyPercentage => puppyEnergy / GameState.maxPuppyEnergy;

  /// Check if can load treat (note: caller should also check world.currentTreat == null)
  bool get canLoadTreat => remainingTreats > 0 && !isTreatLoaded;

  /// Check if game is over (note: caller should also check world.currentTreat == null)
  bool get isGameOver => remainingTreats == 0 && !isTreatLoaded;
}
