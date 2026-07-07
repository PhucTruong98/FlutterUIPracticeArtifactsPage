import 'energy_bar_controller.dart';
import 'scoreboard_controller.dart';

/// Thin facade coordinating HUD element controllers.
/// Holds only leaf controllers, coordination methods, and dispose.
/// No animation flags, no element state — those live on the leaves.
class HudController {
  HudController({required double maxEnergy})
      : energy = EnergyBarController(maxEnergy: maxEnergy);

  final EnergyBarController energy;
  final ScoreboardController score = ScoreboardController();

  /// Cross-element event: peg hit (update score and collision count together).
  Future<void> onPegHit(int points) {
    return Future.wait([
      score.addPointsAndCollision(points),
      // score.incrementCollision(),
    ]);
  }



  /// Cross-element event: treat caught.
  /// Check for level-up and route to appropriate energy method.
  Future<void> onTreatCaught({
    required int finalScore,
  }) async {
    // Calculate new energy
    // final newTotalEnergy = energy.displayEnergy + finalScore;

    // // Check if level-up occurred
    // if (newTotalEnergy >= energy.maxEnergy) {
    //   // Level up!
    //   final overflow = newTotalEnergy - energy.maxEnergy;
    //   await energy.levelUp(
    //     newLevel: energy.level + 1,
    //     overflow: overflow,
    //     newMax: energy.maxEnergy, // Keep same max for now
    //   );
    // } else {
    //   // Normal energy gain
    //   await energy.setEnergy(newTotalEnergy);
    // }

    await energy.onTreatCaught(finalScore);

    // Reset round score
    score.resetRound();
  }

  void dispose() {
    energy.dispose();
    score.dispose();
  }
}
