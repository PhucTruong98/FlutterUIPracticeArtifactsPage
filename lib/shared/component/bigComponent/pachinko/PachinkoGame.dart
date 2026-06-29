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
import 'theme/pixel_art_theme.dart';

/// Main Pachinko game screen
class PachinkoGame extends StatefulWidget {
  const PachinkoGame({super.key});

  @override
  State<PachinkoGame> createState() => _PachinkoGameState();
}

class _PachinkoGameState extends State<PachinkoGame> {
  late GameState gameState;
  late PachinkoGameWorld gameWorld;
  late ValueNotifier<bool> isPuppyHappyNotifier;
  late ValueNotifier<double> treatPreviewXNotifier; // Horizontal position for treat drop preview

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    gameWorld = PachinkoGameWorld(
      gameState: gameState,
    );
    isPuppyHappyNotifier = ValueNotifier<bool>(false);
    treatPreviewXNotifier = ValueNotifier<double>(0.0);

    // Listen to treatCaught to trigger puppy happiness animation
    gameState.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    gameState.removeListener(_onGameStateChanged);
    isPuppyHappyNotifier.dispose();
    treatPreviewXNotifier.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    // Trigger puppy happiness when treat is caught (based on status message)
    if (gameState.statusMessage?.contains('Collected') == true) {
      isPuppyHappyNotifier.value = true;
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          isPuppyHappyNotifier.value = false;
        }
      });
    }
  }


  void _loadTreat() {
    if (gameState.loadTreat() && gameWorld.currentTreat == null) {
      treatPreviewXNotifier.value = 0.0; // Reset preview to center
    }
  }

  void _dropTreat() {
    if (gameState.dropTreat()) {
      // Constrain X position between walls (with margin for treat radius)
      final maxX = PachinkoGameWorld.boardWidth / 2 - 1;
      final minX = -maxX;
      final clampedX = treatPreviewXNotifier.value.clamp(minX, maxX);

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
      // appBar: AppBar(
      //   title: const Text(
      //     'Pachinko - Feed the Puppy',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   backgroundColor: const Color(0xFF34495E),
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section - Inventory and Score (reactive to gameState)
            ListenableBuilder(
              listenable: gameState,
              builder: (context, child) {
                return Container(
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
                );
              },
            ),

            // Middle Section - Pachinko Board
            Expanded(
              child: Container(
                // margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // color: const Color(0xFF8B7355).withOpacity(0.3),
                  // borderRadius: BorderRadius.circular(16),
                  // border: Border.all(
                  //   color: const Color(0xFF6B4423),
                  //   width: 4,
                  // ),
                ),
                child: Stack(
                  children: [
                    // Game board
                    ClipRRect(
                      // borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 4/5,
                        child: GameWidget(
                          game: gameWorld,
                        ),
                      ),
                    ),

                    // Treat aiming overlay (shown when treat is loaded, not dropped yet)
                    ListenableBuilder(
                      listenable: gameState,
                      builder: (context, child) {
                        if (!gameState.isTreatLoaded) {
                          return const SizedBox.shrink();
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return ValueListenableBuilder(
                              valueListenable: treatPreviewXNotifier,
                              builder: (context, treatX, child) {
                                return GestureDetector(
                                  onHorizontalDragUpdate: (details) {
                                    // Update synchronously - no addPostFrameCallback needed
                                    final screenWidth = constraints.maxWidth;
                                    final boardWidth = PachinkoGameWorld.boardWidth;
                                    final normalizedX = (details.localPosition.dx / screenWidth) * 2 - 1;

                                    // Clamp immediately to match drop behavior
                                    final maxX = boardWidth / 2 - 1;
                                    final clampedX = (normalizedX * (boardWidth / 2)).clamp(-maxX, maxX);
                                    treatPreviewXNotifier.value = clampedX;
                                  },
                                  onTapDown: (details) {
                                    // Set position and drop
                                    final screenWidth = constraints.maxWidth;
                                    final boardWidth = PachinkoGameWorld.boardWidth;
                                    final normalizedX = (details.localPosition.dx / screenWidth) * 2 - 1;

                                    // Clamp immediately
                                    final maxX = boardWidth / 2 - 1;
                                    final clampedX = (normalizedX * (boardWidth / 2)).clamp(-maxX, maxX);
                                    treatPreviewXNotifier.value = clampedX;

                                    _dropTreat();
                                  },
                                  child: Stack(
                                    children: [
                                      // Visual indicator - vertical line at drop position
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: _TreatPreviewPainter(
                                            treatX: treatX,
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
                                          decoration: PixelArtTheme.pixelContainer(
                                            color: Colors.white,
                                          ),
                                          child: Text(
                                            'DRAG TO AIM - TAP TO DROP',
                                            style: PixelArtTheme.pixelText(
                                              fontSize: 8,
                                              color: PixelArtTheme.background,
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
                        );
                      },
                    ),

                    // Status message overlay (reactive to gameState)
                    ListenableBuilder(
                      listenable: gameState,
                      builder: (context, child) {
                        if (gameState.statusMessage == null) {
                          return const SizedBox.shrink();
                        }

                        return Positioned(
                          top: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: PixelArtTheme.pixelContainer(
                                color: PixelArtTheme.success,
                              ),
                              child: Text(
                                gameState.statusMessage!.toUpperCase(),
                                style: PixelArtTheme.pixelText(
                                  fontSize: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Section - Puppy and Energy (reactive to gameState)
            ListenableBuilder(
              listenable: gameState,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Compact row with Puppy and Energy
                      Row(
                        children: [
                          // Smaller Puppy (reactive to happiness notifier)
                          ValueListenableBuilder(
                            valueListenable: isPuppyHappyNotifier,
                            builder: (context, isHappy, child) {
                              return Container(
                                width: 60,
                                height: 60,
                                decoration: PixelArtTheme.pixelContainer(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderWidth: 2,
                                ),
                                child: CustomPaint(
                                  painter: PuppyPainter(
                                    isHappy: isHappy,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),

                          // Energy Gauge (expanded to fill remaining space)
                          Expanded(
                            child: EnergyGaugeWidget(
                              currentEnergy: gameState.puppyEnergy,
                              maxEnergy: GameState.maxPuppyEnergy,
                              targetEnergy: gameState.puppyEnergy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Load Treat Button
                      LoadTreatButton(
                        onPressed: _loadTreat,
                        enabled: gameState.canLoadTreat && gameWorld.currentTreat == null,
                      ),

                      // Game Over Message
                      if (gameState.isGameOver && gameWorld.currentTreat == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            children: [
                              Text(
                                'GAME OVER!',
                                style: PixelArtTheme.pixelText(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'PUPPY ENERGY: ${gameState.puppyEnergy.toInt()}',
                                style: PixelArtTheme.pixelText(
                                  fontSize: 8,
                                  color: PixelArtTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () {
                                  gameState.reset();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                  decoration: PixelArtTheme.pixelButton(
                                    color: PixelArtTheme.success,
                                  ),
                                  child: Text(
                                    'PLAY AGAIN',
                                    style: PixelArtTheme.pixelText(
                                      fontSize: 8,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
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
      ..color = Colors.yellow.withValues(alpha: 0.8)
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
      ..color = Colors.yellow.withValues(alpha: 0.9)
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
