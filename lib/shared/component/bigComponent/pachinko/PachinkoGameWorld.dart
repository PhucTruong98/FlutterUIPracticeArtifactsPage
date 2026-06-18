import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'components/TreatBody.dart';
import 'components/PegBody.dart';
import 'components/WallBody.dart';
import 'components/PuppyCatchZone.dart';

/// Main Forge2D game world for Pachinko physics simulation
class PachinkoGameWorld extends Forge2DGame {
  final Function()? onPegHit;
  final Function()? onTreatCaught;

  TreatBody? currentTreat;
  List<PegBody> pegs = [];
  late PuppyCatchZone catchZone;

  // Board dimensions (in physics units)
  static const double boardWidth = 20.0;
  static const double boardHeight = 30.0;
  static const double pegRadius = 0.3;
  static const double treatRadius = 0.5;

  PachinkoGameWorld({
    this.onPegHit,
    this.onTreatCaught,
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

    // Initialize the board (zoom is set in constructor)
    _createWalls();
    _createPegs();
    _createCatchZone();

    camera.viewfinder.anchor = Anchor.center;
  }



  /// Create side walls to keep treat on board
  void _createWalls() {
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
    const int rows = 7;
    const double startY = -10.0;
    const double rowSpacing = 3.0;
    const double pegSpacing = 2.5;

    for (int row = 0; row < rows; row++) {
      final y = startY + (row * rowSpacing);

      // Staggered pattern - alternate between even and odd peg counts
      final isEvenRow = row % 2 == 0;
      final pegsInRow = isEvenRow ? 6 : 5;
      final offset = isEvenRow ? 0.0 : pegSpacing / 2;

      for (int col = 0; col < pegsInRow; col++) {
        final x =  (col * pegSpacing) + offset -((5) * pegSpacing / 2);

        final peg = PegBody(
          position: Vector2(x, y),
          radius: pegRadius,
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
      onTreatCaught: onTreatCaught,
    );
    world.add(catchZone);
  }

  /// Spawn a treat at the launch position
  void spawnTreat() {
    if (currentTreat != null) {
      return; // Only one treat at a time
    }

    currentTreat = TreatBody(
      position: Vector2(1, -boardHeight / 2 + 2), // Near top center
      radius: treatRadius,
      onPegHit: onPegHit,
      onCaught: onTreatCaught,
    );

    world.add(currentTreat!);
  }

  /// Remove current treat from the game
  void removeTreat() {
    if (currentTreat != null) {
      world.remove(currentTreat!);
      currentTreat = null;
    }
  }

  /// Schedule treat removal after a short delay (for animation)
  void scheduleTreatRemoval({Duration delay = const Duration(milliseconds: 500)}) {
    Future.delayed(delay, () {
      removeTreat();
    });
  }
}
