import 'package:flutter/material.dart';
import '../theme/pixel_art_theme.dart';

/// Widget to display current score and collision count
class ScoreDisplayWidget extends StatelessWidget {
  final int score;
  final int collisionCount;

  const ScoreDisplayWidget({
    super.key,
    required this.score,
    required this.collisionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: PixelArtTheme.pixelContainer(
        color: PixelArtTheme.secondary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildScoreItem('SCORE', score.toString()),
          const SizedBox(width: 8),
          Container(
            width: 2,
            height: 20,
            color: PixelArtTheme.border,
          ),
          const SizedBox(width: 8),
          _buildScoreItem('HITS', collisionCount.toString()),
        ],
      ),
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
