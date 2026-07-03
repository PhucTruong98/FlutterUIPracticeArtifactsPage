import 'package:flutter/foundation.dart';

/// Game state model for Pachinko game
class GameState extends ChangeNotifier {
  static const double maxPuppyEnergy = 2000.0;

  int remainingTreats;
  int currentScore;
  int collisionCount;
  double puppyEnergy;
  int currentLevel;
  bool isTreatLoaded;
  bool levelUpOccurred;
  String? statusMessage;

  GameState({
    this.remainingTreats = 5,
    this.currentScore = 0,
    this.collisionCount = 0,
    this.puppyEnergy = 0,
    this.currentLevel = 1,
    this.isTreatLoaded = false,
    this.levelUpOccurred = false,
    this.statusMessage,
  });

  /// Reset game to initial state
  void reset() {
    remainingTreats = 5;
    currentScore = 0;
    collisionCount = 0;
    puppyEnergy = 0;
    currentLevel = 1;
    isTreatLoaded = false;
    levelUpOccurred = false;
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
  void treatCaught({double multiplier = 1.0}) {
    // Apply multiplier to score before adding to energy
    final finalScore = (currentScore * multiplier).toInt();
    puppyEnergy += finalScore;

    // Reset level-up flag at start
    levelUpOccurred = false;

    // Check for level-up(s) and handle excess energy
    while (puppyEnergy >= GameState.maxPuppyEnergy) {
      currentLevel++;
      puppyEnergy -= GameState.maxPuppyEnergy; // Carry over excess
      levelUpOccurred = true; // Set flag for UI animation
    }

    // Show appropriate status message
    if (levelUpOccurred) {
      statusMessage = 'LEVEL UP to $currentLevel! +$finalScore Points';
    } else if (multiplier == 1.0) {
      statusMessage = 'Treat Collected! $finalScore Points';
    } else {
      statusMessage = 'Treat Collected! $finalScore Points (x$multiplier)';
    }

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

  /// Trigger UI update (called when world state changes that aren't tracked in GameState)
  void triggerUpdate() {
    notifyListeners();
  }

  /// Get energy percentage (0.0 to 1.0)
  double get energyPercentage => puppyEnergy / GameState.maxPuppyEnergy;

  /// Check if can load treat (note: caller should also check world.currentTreat == null)
  bool get canLoadTreat => remainingTreats > 0 && !isTreatLoaded;

  /// Check if game is over (note: caller should also check world.currentTreat == null)
  bool get isGameOver => remainingTreats == 0 && !isTreatLoaded;
}
