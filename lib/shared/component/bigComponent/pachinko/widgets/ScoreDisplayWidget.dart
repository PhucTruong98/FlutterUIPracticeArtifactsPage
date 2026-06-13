import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF9B59B6).withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildScoreItem('Score', score.toString()),
          const SizedBox(width: 20),
          Container(
            width: 2,
            height: 30,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(width: 20),
          _buildScoreItem('Hits', collisionCount.toString()),
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
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
