import '../config/PachinkoConfig.dart';

/// Pure game logic for Pachinko game
/// Contains NO UI dependencies - just game rules and state
class GameLogic {
  int remainingTreats;
  bool isTreatLoaded;
  String? statusMessage;

  // Temporary round state (for calculating final score)
  int currentRoundScore;
  int currentRoundCollisions;

  double statusMessageHeight = 16.0;

  GameLogic({
    int? remainingTreats,
    this.isTreatLoaded = false,
    this.statusMessage,
    this.currentRoundScore = 0,
    this.currentRoundCollisions = 0,
  }) : remainingTreats = remainingTreats ?? PachinkoConfig.initialTreats;

  /// Reset game to initial state
  void reset() {
    remainingTreats = PachinkoConfig.initialTreats;
    currentRoundScore = 0;
    currentRoundCollisions = 0;
    isTreatLoaded = false;
    statusMessage = null;
  }

  /// Load a treat (consume from inventory)
  bool loadTreat() {
    if (remainingTreats > 0 && !isTreatLoaded) {
      remainingTreats--;
      isTreatLoaded = true;
      statusMessage = 'Tap to Drop';
      statusMessageHeight = 200.0;
      return true;
    }
    return false;
  }

  /// Drop the loaded treat
  bool dropTreat() {
    if (isTreatLoaded) {
      isTreatLoaded = false;
      statusMessage = null;
      statusMessageHeight = 16.0;
      return true;
    }
    return false;
  }

  /// Record a peg collision (temporary round state)
  void recordPegHit() {
    currentRoundCollisions++;
    currentRoundScore += PachinkoConfig.pegHitPoints;
  }

  /// Treat caught by puppy - returns the final score
  int treatCaught({double multiplier = 1.0}) {
    // Apply multiplier to score
    final finalScore = (currentRoundScore * multiplier).toInt();

    // Show status message
    if (multiplier == 1.0) {
      statusMessage = 'Treat Collected! $finalScore Points';
    } else {
      statusMessage = 'Treat Collected! $finalScore Points (x$multiplier)';
    }

    // Reset round state
    currentRoundScore = 0;
    currentRoundCollisions = 0;

    return finalScore;
  }

  /// Treat missed (timed out or settled without being caught)
  void treatMissed() {
    statusMessage = 'Missed!';

    // Reset round state
    currentRoundScore = 0;
    currentRoundCollisions = 0;
  }

  /// Check if can load treat (note: caller should also check world.currentTreat == null)
  bool get canLoadTreat => remainingTreats > 0 && !isTreatLoaded;

  /// Check if game is over (note: caller should also check world.currentTreat == null)
  bool get isGameOver => remainingTreats == 0 && !isTreatLoaded;
}
