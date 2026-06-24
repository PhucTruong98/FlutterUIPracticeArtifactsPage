import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'components/TreatBody.dart';
import 'components/PegBody.dart';
import 'components/WallBody.dart';
import 'components/PuppyCatchZone.dart';
import 'PachinkoAssets.dart';
import 'models/GameState.dart';

/// Main Forge2D game world for Pachinko physics simulation
class PachinkoGameWorld extends Forge2DGame {
  final GameState gameState;

  TreatBody? currentTreat;
  List<PegBody> pegs = [];
  late PuppyCatchZone catchZone;
  late PachinkoAssets pachinkoAssets;  // Asset manager instance
  TimerComponent? _treatMissTimer;  // Timer to detect missed treats

  // Board dimensions (in physics units)
  static const double boardWidth = 20.0;
  static const double boardHeight = 30.0;
  static const double pegRadius = 0.6;
  static const double treatRadius = 1.0;

  PachinkoGameWorld({
    required this.gameState,
  }) : super(
          gravity: Vector2(0, 25), // Downward gravity
          camera: CameraComponent.withFixedResolution(
            width: boardWidth,
            height: boardHeight,
          ),
          zoom: 1
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize assets with game's image cache and preload all images
    pachinkoAssets = PachinkoAssets(images);
    await pachinkoAssets.loadAll();

    // Initialize the board (zoom is set in constructor)
    _createBackground();  // Add background first so it renders behind everything
    _createWalls();
    _createPegs();
    _createCatchZone();

    camera.viewfinder.anchor = Anchor.center;
  }

  /// Create background sprite
  void _createBackground() {
    final background = SpriteComponent(
      sprite: pachinkoAssets.skyBackdrop,
      size: Vector2(boardWidth, boardHeight),
      position: Vector2.zero(),
      anchor: Anchor.center,
      paint: Paint()..filterQuality = FilterQuality.none, // Pixel-perfect rendering
    );

    world.add(background);
  }



  /// Create side walls to keep treat on board
  void _createWalls() {

    //top wall

    world.add(WallBody(
      start: Vector2(- boardWidth / 2, - boardHeight / 2), 
      end: Vector2(boardWidth / 2, - boardHeight / 2),
      color: const Color.fromARGB(255, 255, 0, 0),
      
      ));



    // Left wall
    world.add(WallBody(
      start: Vector2(-boardWidth / 2, -boardHeight / 2),

      end: Vector2(-boardWidth / 2, boardHeight / 2),

      color: const Color.fromARGB(255, 255, 0, 0),
    ));

    // Right wall
    world.add(WallBody(
      start: Vector2(boardWidth / 2, -boardHeight / 2),
      end: Vector2(boardWidth / 2, boardHeight / 2),
      color: const Color.fromARGB(255, 255, 0, 0),
    ));

    // Bottom wall (backstop)
    world.add(WallBody(
      start: Vector2(-boardWidth / 2, boardHeight / 2),
      end: Vector2(boardWidth / 2, boardHeight / 2),
      color: const Color.fromARGB(255, 255, 0, 0),
    ));
  }

  /// Create classic Pachinko peg layout
  void _createPegs() {
    const int rows = 5;
    const int maxCols = 4;
    const double startY = -10.0;
    const double rowSpacing = boardHeight / (rows + 1 );
    const double pegSpacing = boardWidth / (maxCols );

    for (int row = 0; row < rows; row++) {
      final y = startY + (row * rowSpacing);

      // Staggered pattern - alternate between even and odd peg counts
      final isEvenRow = row % 2 == 0;
      final pegsInRow = isEvenRow ? maxCols : maxCols - 1;
      final offset = isEvenRow ? 0.0 : pegSpacing / 2;

      for (int col = 0; col < pegsInRow; col++) {
        final x =  (col * pegSpacing) + offset -((maxCols - 1) * pegSpacing / 2);

        final peg = PegBody(
          position: Vector2(x, y),
          radius: pegRadius,
          assets: pachinkoAssets,
          gameState: gameState,
        );

        pegs.add(peg);
        world.add(peg);
      }
    }
  }

  /// Create catch zone at bottom for puppy
  void _createCatchZone() {
    catchZone = PuppyCatchZone(
      position: Vector2(0, boardHeight / 2 - 2),
      size: Vector2(boardWidth - 2, 2),
      gameState: gameState,
    );
    world.add(catchZone);
  }

  /// Spawn a treat at the specified position or default launch position
  void spawnTreat({Vector2? position}) {
    if (currentTreat != null) {
      return; // Only one treat at a time
    }

    currentTreat = TreatBody(
      position: position ?? Vector2(0, -boardHeight / 2 + 2), // Default to center-top
      radius: treatRadius,
      assets: pachinkoAssets,
      gameState: gameState,
    );

    world.add(currentTreat!);

    // // Start miss detection timer (10 seconds)
    // _treatMissTimer?.removeFromParent();
    // _treatMissTimer = TimerComponent(
    //   period: 10.0,
    //   repeat: false,
    //   onTick: () => _handleTreatMissed(),
    //   removeOnFinish: true,
    // );
    // world.add(_treatMissTimer!);
  }

  /// Remove current treat from the game
  void removeTreat() {
    if (currentTreat != null) {
      world.remove(currentTreat!);
      currentTreat = null;
    }

    // // Cancel miss timer if active
    // _treatMissTimer?.removeFromParent();
    // _treatMissTimer = null;
  }

  // /// Handle treat miss (timeout or settled)
  // void _handleTreatMissed() {
  //   if (currentTreat != null) {
  //     gameState.treatMissed();
  //     removeTreat();
  //   }
  // }

  /// Schedule treat removal after a short delay (for animation)
  // void scheduleTreatRemoval({Duration delay = const Duration(milliseconds: 500)}) {
  //   final timer = TimerComponent(
  //     period: delay.inMilliseconds / 1000.0,
  //     repeat: false,
  //     onTick: () => removeTreat(),
  //     removeOnFinish: true,
  //   );
  //   world.add(timer);
  // }
}
