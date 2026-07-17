import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'models/GameLogic.dart';
import 'models/GameEventBus.dart';
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
  late GameLogic game;  // Pure game logic
  late PachinkoGameWorld gameWorld;
  late PuppyGameWorld puppyGameWorld;
  late HudController hudController;

  // Event stream subscription (single stream for all events)
  late StreamSubscription<GameEvent> _eventSubscription;

  // Animation coordination
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    game = GameLogic();
    hudController = HudController(maxEnergy: PachinkoConfig.maxPuppyEnergy);

    gameWorld = PachinkoGameWorld(
      game: game,
    );
    puppyGameWorld = PuppyGameWorld();

    // Subscribe to all game events with type checking
    _eventSubscription = GameEventBus.instance.gameEvents.listen((event) {
      if (event is PegHitEvent) {
        onPegHit();
      } else if (event is TreatCaughtEvent) {
        onTreatCaught(event.multiplier);
      } else if (event is LevelUpEvent) {
        puppyGameWorld.playLevelUpAnimation();
      } else if (event is ConfettiSpawnEvent) {
        gameWorld.spawnConfetti(event.position, event.multiplier);
      }
    });
  }

  @override
  void dispose() {
    // Cancel event subscription to prevent memory leaks
    _eventSubscription.cancel();

    hudController.dispose();
    super.dispose();
  }

  // ===== Game Event Coordinators (called by game components) =====

  void onPegHit() {
    if (_isAnimating) return;  // Block during animations

    game.recordPegHit();
    unawaited(hudController.onPegHit(PachinkoConfig.pegHitPoints));
    setState(() {});
  }

  Future<void> onTreatCaught(double multiplier) async {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);

    final finalScore = game.treatCaught(multiplier: multiplier);

    // Execute animation sequence
    await _playTreatCaughtSequence(finalScore);

    setState(() => _isAnimating = false);
  }

  // ===== Animation Sequences =====

  Future<void> _playTreatCaughtSequence(int finalScore) async {
    // Start HUD and Puppy animations in parallel
    await Future.wait([
      _playHudSequence(finalScore),
      _playPuppyEatingSequence(),
    ]);
  }

  Future<void> _playHudSequence(int finalScore) async {
    await hudController.onTreatCaught(
      finalScore: finalScore,
      currentEnergy: hudController.energy.displayEnergy,
    );
  }

  Future<void> _playPuppyEatingSequence() async {
    await puppyGameWorld.playEatingSequence();
  }

  // ===== Button Handlers =====

  void _loadTreat() {
    if (_isAnimating) return;  // Block during animations

    if (game.loadTreat() && gameWorld.currentTreat == null) {
      gameWorld.spawnOscillatingTreat();
      setState(() {});
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
            // Top Section - Inventory and Score
            Container(
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
                    remainingTreats: game.remainingTreats,
                  ),
                  ScoreDisplayWidget(
                    controller: hudController.score,
                  ),
                ],
              ),
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

                    // Status message overlay
                    if (game.statusMessage != null)
                      Positioned(
                          top: game.statusMessageHeight,
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
                                game.statusMessage!.toUpperCase(),
                                style: PixelArtTheme.pixelText(
                                  fontSize: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),

            // Energy Bar Section - Full width between board and puppy world
            HorizontalEnergyBar(controller: hudController.energy),

            // Bottom Section - Puppy Animation World + UI Overlay
            Container(
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
                              enabled: !_isAnimating && game.canLoadTreat && gameWorld.currentTreat == null,
                            ),
                          ],
                        ),
                      ),
            
                      // Game Over Message
                      if (game.isGameOver && gameWorld.currentTreat == null)
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
                                    game.reset();
                                    setState(() {});
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
                ),
          ],
        ),
      ),
    );
  }
}
