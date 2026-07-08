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
  /// Delegates to energy controller with optional level-up callback.
  Future<void> onTreatCaught({
    required int finalScore,
    required double currentEnergy,
    void Function()? onEachLevelUp,
  }) async {
    await energy.onTreatCaught(
      finalScore,
      onLevelUp: onEachLevelUp,
    );

    // Reset round score
    score.resetRound();
  }

  void dispose() {
    energy.dispose();
    score.dispose();
  }
}
