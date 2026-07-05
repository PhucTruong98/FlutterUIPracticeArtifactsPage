import 'package:flutter/material.dart';
import '../theme/pixel_art_theme.dart';
import '../hud/scoreboard_controller.dart';

/// Widget to display current score and collision count with pop animation
/// Pure view - all animation state lives in the controller
class ScoreDisplayWidget extends StatelessWidget {
  const ScoreDisplayWidget({super.key, required this.controller});

  final ScoreboardController controller;

  @override
  Widget build(BuildContext context) {
    // Rebuild on: score changes (ChangeNotifier) + pop animation ticks
    return AnimatedBuilder(
      animation: Listenable.merge([controller, controller.pop]),
      builder: (context, _) {
        final popValue = controller.pop.value; // 0..1
        final scale = 1.0 + (popValue * 0.2); // Scale from 1.0 to 1.2

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: PixelArtTheme.pixelContainer(
              color: PixelArtTheme.secondary,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildScoreItem('SCORE', controller.score.toString()),
                const SizedBox(width: 8),
                Container(
                  width: 2,
                  height: 20,
                  color: PixelArtTheme.border,
                ),
                const SizedBox(width: 8),
                _buildScoreItem('HITS', controller.collisionCount.toString()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: PixelArtTheme.pixelText(
            fontSize: 6,
            color: PixelArtTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: PixelArtTheme.pixelText(
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
