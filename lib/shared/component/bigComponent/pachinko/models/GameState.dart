import 'dart:async';
import 'package:flutter/foundation.dart';
import '../hud/hud_controller.dart';
import '../config/PachinkoConfig.dart';

/// Game state model for Pachinko game
/// Now focused on game mechanics only - HUD state lives in HudController
class GameState extends ChangeNotifier {

  int remainingTreats;
  bool isTreatLoaded;
  String? statusMessage;

  // Temporary round state (for calculating final score)
  int currentRoundScore;
  int currentRoundCollisions;

  // HUD controller reference (set after construction to avoid circular dependency)
  HudController? hudController;

  GameState({
    int? remainingTreats,
    this.isTreatLoaded = false,
    this.statusMessage,
    this.currentRoundScore = 0,
    this.currentRoundCollisions = 0,
  }) : remainingTreats = remainingTreats ?? PachinkoConfig.initialTreats;

  /// Set HUD controller reference (called after construction)
  void setHudController(HudController controller) {
    hudController = controller;
  }

  /// Reset game to initial state
  void reset() {
    remainingTreats = PachinkoConfig.initialTreats;
    currentRoundScore = 0;
    currentRoundCollisions = 0;
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

  /// Record a peg collision (temporary round state)
  void recordPegHit() {
    currentRoundCollisions++;
    currentRoundScore += PachinkoConfig.pegHitPoints;
    notifyListeners();

    // Trigger HUD animation (fire-and-forget)
    unawaited(hudController?.onPegHit(PachinkoConfig.pegHitPoints));
  }

  /// Treat caught by puppy - returns the final score for HUD update
  int treatCaught({double multiplier = 1.0}) {
    // Apply multiplier to score
    final finalScore = (currentRoundScore * multiplier).toInt();

    // Show status message
    if (multiplier == 1.0) {
      statusMessage = 'Treat Collected! $finalScore Points';
    } else {
      statusMessage = 'Treat Collected! $finalScore Points (x$multiplier)';
    }

    // Trigger HUD animation (fire-and-forget)
    if (hudController != null) {
      unawaited(hudController!.onTreatCaught(
        finalScore: finalScore,
      ));
    }

    // Reset round state
    final score = finalScore;
    currentRoundScore = 0;
    currentRoundCollisions = 0;
    notifyListeners();

    return score;
  }

  /// Treat missed (timed out or settled without being caught)
  void treatMissed() {
    statusMessage = 'Missed!';

    // Reset round state
    currentRoundScore = 0;
    currentRoundCollisions = 0;
    notifyListeners();
  }

  /// Trigger UI update (called when world state changes that aren't tracked in GameState)
  void triggerUpdate() {
    notifyListeners();
  }

  /// Check if can load treat (note: caller should also check world.currentTreat == null)
  bool get canLoadTreat => remainingTreats > 0 && !isTreatLoaded;

  /// Check if game is over (note: caller should also check world.currentTreat == null)
  bool get isGameOver => remainingTreats == 0 && !isTreatLoaded;
}
