/// Game state model for Pachinko game
class GameState {
  int remainingTreats;
  int currentScore;
  int collisionCount;
  double puppyEnergy;
  double maxPuppyEnergy;
  bool isTreatLoaded;
  bool isTreatFalling;
  String? statusMessage;

  GameState({
    this.remainingTreats = 5,
    this.currentScore = 0,
    this.collisionCount = 0,
    this.puppyEnergy = 0,
    this.maxPuppyEnergy = 2000,
    this.isTreatLoaded = false,
    this.isTreatFalling = false,
    this.statusMessage,
  });

  /// Reset game to initial state
  void reset() {
    remainingTreats = 5;
    currentScore = 0;
    collisionCount = 0;
    puppyEnergy = 0;
    maxPuppyEnergy = 2000;
    isTreatLoaded = false;
    isTreatFalling = false;
    statusMessage = null;
  }

  /// Load a treat (consume from inventory)
  bool loadTreat() {
    if (remainingTreats > 0 && !isTreatLoaded && !isTreatFalling) {
      remainingTreats--;
      isTreatLoaded = true;
      statusMessage = 'Tap to Drop';
      return true;
    }
    return false;
  }

  /// Drop the loaded treat
  bool dropTreat() {
    if (isTreatLoaded && !isTreatFalling) {
      isTreatLoaded = false;
      isTreatFalling = true;
      statusMessage = null;
      return true;
    }
    return false;
  }

  /// Record a peg collision
  void recordPegHit() {
    collisionCount++;
    currentScore += 50;
  }

  /// Treat caught by puppy - end round
  void treatCaught() {
    isTreatFalling = false;

    // Add energy based on score
    puppyEnergy += currentScore;
    if (puppyEnergy > maxPuppyEnergy) {
      puppyEnergy = maxPuppyEnergy;
    }

    statusMessage = 'Treat Collected! $currentScore Points';

    // Reset round score and collision count
    currentScore = 0;
    collisionCount = 0;
  }

  /// Get energy percentage (0.0 to 1.0)
  double get energyPercentage => puppyEnergy / maxPuppyEnergy;

  /// Check if can load treat
  bool get canLoadTreat => remainingTreats > 0 && !isTreatLoaded && !isTreatFalling;

  /// Check if game is over
  bool get isGameOver => remainingTreats == 0 && !isTreatLoaded && !isTreatFalling;

  /// Create a copy with updated values
  GameState copyWith({
    int? remainingTreats,
    int? currentScore,
    int? collisionCount,
    double? puppyEnergy,
    double? maxPuppyEnergy,
    bool? isTreatLoaded,
    bool? isTreatFalling,
    String? statusMessage,
  }) {
    return GameState(
      remainingTreats: remainingTreats ?? this.remainingTreats,
      currentScore: currentScore ?? this.currentScore,
      collisionCount: collisionCount ?? this.collisionCount,
      puppyEnergy: puppyEnergy ?? this.puppyEnergy,
      maxPuppyEnergy: maxPuppyEnergy ?? this.maxPuppyEnergy,
      isTreatLoaded: isTreatLoaded ?? this.isTreatLoaded,
      isTreatFalling: isTreatFalling ?? this.isTreatFalling,
      statusMessage: statusMessage,
    );
  }
}
