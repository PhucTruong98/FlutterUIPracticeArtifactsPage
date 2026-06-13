import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'models/GameState.dart';
import 'PachinkoGameWorld.dart';
import 'widgets/TreatInventoryWidget.dart';
import 'widgets/EnergyGaugeWidget.dart';
import 'widgets/ScoreDisplayWidget.dart';
import 'widgets/LoadTreatButton.dart';
import 'painters/puppy_painter.dart';

/// Main Pachinko game screen
class PachinkoGame extends StatefulWidget {
  const PachinkoGame({super.key});

  @override
  State<PachinkoGame> createState() => _PachinkoGameState();
}

class _PachinkoGameState extends State<PachinkoGame> {
  late GameState gameState;
  late PachinkoGameWorld gameWorld;
  bool isPuppyHappy = false;

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
      setState(() {});
      gameWorld.spawnTreat();
      gameWorld.overlays.add('tapToDrop');
    }
  }

  void _dropTreat() {
    if (gameState.dropTreat()) {
      setState(() {});
      gameWorld.overlays.remove('tapToDrop');
      // Treat is already spawned, physics will handle the drop
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
              padding: const EdgeInsets.all(16),
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
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      child: GameWidget(
                        game: gameWorld,
                        overlayBuilderMap: {
                          'tapToDrop': (context, game) {
                            return Center(
                              child: GestureDetector(
                                onTap: _dropTreat,
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
                                    '👆 Tap to Drop',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        },
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Puppy
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: CustomPaint(
                      painter: PuppyPainter(
                        isHappy: isPuppyHappy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Energy Gauge
                  EnergyGaugeWidget(
                    currentEnergy: gameState.puppyEnergy,
                    maxEnergy: gameState.maxPuppyEnergy,
                    targetEnergy: gameState.puppyEnergy,
                  ),
                  const SizedBox(height: 16),

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
