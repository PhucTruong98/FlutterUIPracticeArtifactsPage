import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'components/TreatBody.dart';
import 'components/PegBody.dart';
import 'components/WallBody.dart';
import 'components/SlotZone.dart';
import 'PachinkoAssets.dart';
import 'models/GameState.dart';

/// Main Forge2D game world for Pachinko physics simulation
class PachinkoGameWorld extends Forge2DGame {
  final GameState gameState;

  TreatBody? currentTreat;
  List<PegBody> pegs = [];
  List<SlotZone> slots = [];
  late PachinkoAssets pachinkoAssets;  // Asset manager instance
  TimerComponent? _treatMissTimer;  // Timer to detect missed treats

  // Board dimensions (in physics units)
  static const double boardWidth = 20.0;
  static const double boardHeight = 25.0;
  static const double pegRadius = 0.6;
  static const double treatRadius = 0.8;

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
    _createSlots();

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
      
      ));



    // Left wall
    world.add(WallBody(
      start: Vector2(-boardWidth / 2, -boardHeight / 2),

      end: Vector2(-boardWidth / 2, boardHeight / 2),

    ));

    // Right wall
    world.add(WallBody(
      start: Vector2(boardWidth / 2, -boardHeight / 2),
      end: Vector2(boardWidth / 2, boardHeight / 2),
    ));

    // Bottom wall (backstop)
    world.add(WallBody(
      start: Vector2(-boardWidth / 2, boardHeight / 2),
      end: Vector2(boardWidth / 2, boardHeight / 2),
    ));
  }

  /// Create classic Pachinko peg layout
  void _createPegs() {
    const int rows = 4;
    const int maxCols = 4;
    const double startY = -7.0;
    const double rowSpacing = boardHeight / (rows + 2 );
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
        );

        pegs.add(peg);
        world.add(peg);
      }
    }
  }

  /// Create 5 slot zones at bottom with multipliers
  void _createSlots() {
    const double slotWallWidth = 0.2;
    const int slotsAmount = 5;

    const double slotWidth = (boardWidth - slotWallWidth * (slotsAmount - 1)) / 5;  // (boardWidth - 2) / 5 = 18 / 5
    const double slotHeight = 2.0;
    const double slotY = boardHeight / 2 - 1;  // Position near bottom
    const double startX = -boardWidth / 2 ;  // Left edge with margin
    // Multipliers for each slot: outer(1.2), inner(1.5), center(1.7)
    final multipliers = [1.2, 1.5, 1.7, 1.5, 1.2];

    // Create 5 slot zones
    for (int i = 0; i < 5; i++) {
      final slotX = startX + (i * slotWidth) + i * slotWallWidth + slotWidth/2;

      final slot = SlotZone(
        position: Vector2(slotX, slotY),
        size: Vector2(slotWidth, slotHeight),  // Slightly smaller to avoid wall overlap
        multiplier: multipliers[i],
        slotNumber: i + 1,
      );

      slots.add(slot);
      world.add(slot);
    }

    // Create 4 divider walls between the 5 slots
    const double wallHeight = 5;  // Walls extend above slot zones to guide treats
    const double wallY = boardHeight / 2 - wallHeight / 2;

    for (int i = 1; i < 5; i++) {

      final wallX = startX + (i * slotWidth)+ i * slotWallWidth - slotWallWidth;

      world.add(WallBody(
        start: Vector2(wallX, wallY),
        end: Vector2(wallX, boardHeight / 2),
        color: const Color.fromARGB(255, 139, 69, 19),  // Brown color for dividers
      ));
    }
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

      // Trigger UI update so button can re-evaluate enabled state
      gameState.triggerUpdate();
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
