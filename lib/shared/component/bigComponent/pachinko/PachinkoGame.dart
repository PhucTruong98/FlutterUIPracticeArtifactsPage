import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'models/GameState.dart';
import 'PachinkoGameWorld.dart';
import 'PuppyGameWorld.dart';
import 'hud/hud_controller.dart';
import 'widgets/TreatInventoryWidget.dart';
import 'widgets/HorizontalEnergyBar.dart';
import 'widgets/ScoreDisplayWidget.dart';
import 'widgets/LoadTreatButton.dart';
import 'theme/pixel_art_theme.dart';
import 'config/PachinkoConfig.dart';

/// Main Pachinko game screen
class PachinkoGame extends StatefulWidget {
  const PachinkoGame({super.key});

  @override
  State<PachinkoGame> createState() => _PachinkoGameState();
}

class _PachinkoGameState extends State<PachinkoGame> {
  late GameState gameState;
  late PachinkoGameWorld gameWorld;
  late PuppyGameWorld puppyGameWorld;
  late HudController hudController;
  late ValueNotifier<double> treatPreviewXNotifier; // Horizontal position for treat drop preview

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    hudController = HudController(maxEnergy: PachinkoConfig.maxPuppyEnergy);

    // Link GameState and HudController
    gameState.setHudController(hudController);

    gameWorld = PachinkoGameWorld(
      gameState: gameState,
    );
    puppyGameWorld = PuppyGameWorld(
      gameState: gameState,
    );
    treatPreviewXNotifier = ValueNotifier<double>(0.0);
  }

  @override
  void dispose() {
    hudController.dispose();
    treatPreviewXNotifier.dispose();
    super.dispose();
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
      backgroundColor: Colors.black, // Neutral background, won't bleed between sections
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
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/pachinko/cloudTop.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TreatInventoryWidget(
                        remainingTreats: gameState.remainingTreats,
                      ),
                      ScoreDisplayWidget(
                        controller: hudController.score,
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

            // Energy Bar Section - Full width between board and puppy world
            HorizontalEnergyBar(controller: hudController.energy),

            // Bottom Section - Puppy Animation World + UI Overlay
            ListenableBuilder(
              listenable: gameState,
              builder: (context, child) {
                return Container(
                  height: 150, // Fixed height for bottom section
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/pachinko/grassGroundBottom.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Layer 1: Puppy Game World (Flame animations)
                      Positioned.fill(
                        child: GameWidget(game: puppyGameWorld),
                      ),

                      // Layer 2: UI Overlay (Flutter widgets on top)
                      Positioned(
                        right: 16,
                        top: 8,
                        bottom: 8,
                        left: 250, // Leave space for puppy on left
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Load Treat Button
                            LoadTreatButton(
                              onPressed: _loadTreat,
                              enabled: gameState.canLoadTreat && gameWorld.currentTreat == null,
                            ),
                          ],
                        ),
                      ),

                      // Game Over Message
                      if (gameState.isGameOver && gameWorld.currentTreat == null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 16,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
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
                                  'PUPPY ENERGY: ${hudController.energy.displayEnergy.toInt()}',
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
