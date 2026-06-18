import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'models/GameState.dart';
import 'PachinkoGameWorld.dart';
import 'widgets/TreatInventoryWidget.dart';
import 'widgets/EnergyGaugeWidget.dart';
import 'widgets/ScoreDisplayWidget.dart';
import 'widgets/LoadTreatButton.dart';
import 'painters/puppy_painter.dart';

/// Main Pachinko game screen
class PachinkoGame < T extends Game> extends StatefulWidget {
  const PachinkoGame({super.key});

  @override
  State<PachinkoGame> createState() => _PachinkoGameState();
}

class _PachinkoGameState extends State<PachinkoGame> {
  late GameState gameState;
  late PachinkoGameWorld gameWorld;
  bool isPuppyHappy = false;
  double _treatPreviewX = 0.0; // Horizontal position for treat drop preview

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    gameWorld = PachinkoGameWorld(
      onPegHit: _handlePegHit,
      onTreatCaught: _handleTreatCaught,
    );
  }

  void _handlePegHit() {
    setState(() {
      gameState.recordPegHit();
    });
  }

  void _handleTreatCaught() {
    setState(() {
      gameState.treatCaught();
      isPuppyHappy = true;

      // Schedule treat removal from the world
      gameWorld.scheduleTreatRemoval();

      // Reset puppy happiness after animation
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            isPuppyHappy = false;
          });
        }
      });
    });
  }

  void _loadTreat() {
    if (gameState.loadTreat()) {
      setState(() {
        _treatPreviewX = 0.0; // Reset preview to center
      });
      // Don't spawn yet - wait for user to choose position and tap
      gameWorld.overlays.add('tapToDrop');
    }
  }

  void _dropTreat() {
    if (gameState.dropTreat()) {
      setState(() {});
      gameWorld.overlays.remove('tapToDrop');

      // Constrain X position between walls (with margin for treat radius)
      final maxX = PachinkoGameWorld.boardWidth / 2 - 1;
      final minX = -maxX;
      final clampedX = _treatPreviewX.clamp(minX, maxX);

      // Now spawn treat at chosen position
      gameWorld.spawnTreat(
        position: Vector2(clampedX, -PachinkoGameWorld.boardHeight / 2 + 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        title: const Text(
          'Pachinko - Feed the Puppy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF34495E),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section - Inventory and Score
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TreatInventoryWidget(
                    remainingTreats: gameState.remainingTreats,
                  ),
                  ScoreDisplayWidget(
                    score: gameState.currentScore,
                    collisionCount: gameState.collisionCount,
                  ),
                ],
              ),
            ),

            // Middle Section - Pachinko Board
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7355).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6B4423),
                    width: 4,
                  ),
                ),
                child: Stack(
                  children: [
                    // Game board
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox.expand(
                        child: GameWidget(
                          game: gameWorld,
                          overlayBuilderMap: {
                            'tapToDrop': (context, game) {
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return GestureDetector(
                                    onHorizontalDragUpdate: (details) {
                                      setState(() {
                                        // Convert screen position to world X coordinate
                                        final screenWidth = constraints.maxWidth;
                                        final boardWidth = PachinkoGameWorld.boardWidth;

                                        // Map screen X (0 to screenWidth) to world X (-boardWidth/2 to +boardWidth/2)
                                        final normalizedX = (details.localPosition.dx / screenWidth) * 2 - 1; // -1 to +1
                                        _treatPreviewX = normalizedX * (boardWidth / 2);
                                      });
                                    },
                                    onTapDown: (details) {
                                      // Allow tap to also set position before dropping
                                      final screenWidth = constraints.maxWidth;
                                      final boardWidth = PachinkoGameWorld.boardWidth;
                                      final normalizedX = (details.localPosition.dx / screenWidth) * 2 - 1;

                                      setState(() {
                                        _treatPreviewX = normalizedX * (boardWidth / 2);
                                      });

                                      _dropTreat();
                                    },
                                    child: Stack(
                                      children: [
                                        // Visual indicator - vertical line at drop position
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: _TreatPreviewPainter(
                                              treatX: _treatPreviewX,
                                              boardWidth: PachinkoGameWorld.boardWidth,
                                            ),
                                          ),
                                        ),
                                        // Instruction text
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.9),
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Text(
                                              '← Drag to aim → Tap to Drop',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2C3E50),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          },
                        ),
                      ),
                    ),

                    // Status message overlay
                    if (gameState.statusMessage != null)
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27AE60).withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              gameState.statusMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom Section - Puppy and Energy
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Compact row with Puppy and Energy
                  Row(
                    children: [
                      // Smaller Puppy
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: CustomPaint(
                          painter: PuppyPainter(
                            isHappy: isPuppyHappy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Energy Gauge (expanded to fill remaining space)
                      Expanded(
                        child: EnergyGaugeWidget(
                          currentEnergy: gameState.puppyEnergy,
                          maxEnergy: gameState.maxPuppyEnergy,
                          targetEnergy: gameState.puppyEnergy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Load Treat Button
                  LoadTreatButton(
                    onPressed: _loadTreat,
                    enabled: gameState.canLoadTreat,
                  ),

                  // Game Over Message
                  if (gameState.isGameOver)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          const Text(
                            'Game Over!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Puppy Energy: ${gameState.puppyEnergy.toInt()}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                gameState.reset();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF27AE60),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Play Again',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw treat drop preview indicator
class _TreatPreviewPainter extends CustomPainter {
  final double treatX; // World X coordinate
  final double boardWidth; // World board width

  _TreatPreviewPainter({
    required this.treatX,
    required this.boardWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Convert world X coordinate to screen X coordinate
    // World X goes from -boardWidth/2 to +boardWidth/2
    // Screen X goes from 0 to size.width
    final normalizedX = (treatX / (boardWidth / 2) + 1) / 2; // 0 to 1
    final screenX = normalizedX * size.width;

    // Draw a dashed vertical line at the drop position
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw dashed line from top to bottom
    const dashHeight = 10.0;
    const dashSpace = 5.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(screenX, startY),
        Offset(screenX, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }

    // Draw a small circle at the top to indicate drop point
    final circlePaint = Paint()
      ..color = Colors.yellow.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(screenX, 20),
      8,
      circlePaint,
    );

    // Draw outline for circle
    final outlinePaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(screenX, 20),
      8,
      outlinePaint,
    );
  }

  @override
  bool shouldRepaint(_TreatPreviewPainter oldDelegate) {
    return oldDelegate.treatX != treatX;
  }
}
