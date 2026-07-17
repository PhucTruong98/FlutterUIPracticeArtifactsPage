import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'components/TreatBody.dart';
import 'components/PegBody.dart';
import 'components/WallBody.dart';
import 'components/SlotZone.dart';
import 'components/ConfettiEffect.dart';
import 'PachinkoAssets.dart';
import 'models/GameLogic.dart';
import 'config/PachinkoConfig.dart';

/// Main Forge2D game world for Pachinko physics simulation
class PachinkoGameWorld extends Forge2DGame with TapCallbacks {
  final GameLogic game;

  TreatBody? currentTreat;
  List<PegBody> pegs = [];
  List<SlotZone> slots = [];
  late PachinkoAssets pachinkoAssets;  // Asset manager instance
  TimerComponent? _treatMissTimer;  // Timer to detect missed treats

  // Board dimensions (in physics units) - now from config
  static double get boardWidth => PachinkoConfig.boardWidth;
  static double get boardHeight => PachinkoConfig.boardHeight;
  static double get pegRadius => PachinkoConfig.pegRadius;
  static double get treatRadius => PachinkoConfig.treatRadius;

  PachinkoGameWorld({
    required this.game,
  }) : super(
          gravity: Vector2(0, PachinkoConfig.gravity), // Downward gravity
          camera: CameraComponent.withFixedResolution(
            width: PachinkoConfig.boardWidth,
            height: PachinkoConfig.boardHeight,
          ),
          zoom: 1
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize assets with global image cache and preload all images
    pachinkoAssets = PachinkoAssets(Flame.images);
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
    final int rows = PachinkoConfig.pegRows;
    final int maxCols = PachinkoConfig.pegMaxCols;
    final double startY = PachinkoConfig.pegStartY;
    final double rowSpacing = PachinkoConfig.rowSpacing;
    final double pegSpacing = PachinkoConfig.pegSpacing;

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
          radius: PachinkoConfig.pegRadius,
          assets: pachinkoAssets,
        );

        pegs.add(peg);
        world.add(peg);
      }
    }
  }

  /// Create 5 slot zones at bottom with multipliers
  void _createSlots() {
    final double slotWallWidth = PachinkoConfig.slotWallWidth;
    final double slotWallHeight = PachinkoConfig.slotWallHeight;
    final int slotsAmount = PachinkoConfig.slotCount;

    final double slotWidth = PachinkoConfig.slotWidth;
    final double slotHeight = PachinkoConfig.slotHeight;
    final double slotY = PachinkoConfig.slotY;
    final double startX = -PachinkoConfig.boardWidth / 2;  // Left edge with margin
    // Multipliers for each slot: outer(1.2), inner(1.5), center(1.7)
    final multipliers = PachinkoConfig.slotMultipliers;

    // Create slot zones
    for (int i = 0; i < slotsAmount; i++) {
      final slotX = startX + (i * slotWidth) + i * slotWallWidth + slotWidth/2;

      final slot = SlotZone(
        position: Vector2(slotX, slotY),
        size: Vector2(slotWidth, slotHeight),  // Slightly smaller to avoid wall overlap
        multiplier: multipliers[i],
        slotNumber: i + 1,
        assets: pachinkoAssets,
        createLeftWall: i > 0, 
        wallHeight: slotWallHeight,  // Slots 2-5 create left wall dividers
      );

      slots.add(slot);
      world.add(slot);
    }
    // Wall creation now handled by individual SlotZones
  }

  /// Spawn a treat at the specified position or default launch position
  void spawnTreat({Vector2? position}) {
    if (currentTreat != null) {
      return; // Only one treat at a time
    }

    currentTreat = TreatBody(
      position: position ?? Vector2(0, -PachinkoConfig.boardHeight / 2 + 2), // Default to center-top
      radius: PachinkoConfig.treatRadius,
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

      // UI updates now handled by PachinkoGame coordinator via setState()
    }

    // // Cancel miss timer if active
    // _treatMissTimer?.removeFromParent();
    // _treatMissTimer = null;
  }

  /// Spawn confetti particle effect at the given position
  ///
  /// Called when treat lands in slot. Effect intensity varies by multiplier:
  /// - 1.2x: Small green burst
  /// - 1.5x: Medium orange burst
  /// - 1.7x: PREMIUM rainbow burst with sparkles
  void spawnConfetti(Vector2 position, double multiplier) {
    final confetti = ConfettiEffect(
      position: position,
      multiplier: multiplier,
    );
    world.add(confetti);
  }

  /// Spawn oscillating treat at top center of board
  /// Treat starts oscillating automatically (created with kinematic body)
  void spawnOscillatingTreat() {
    if (currentTreat != null) {
      return; // Only one treat at a time
    }

    currentTreat = TreatBody(
      position: Vector2(0, -PachinkoConfig.boardHeight / 2 + 2), // Center top
      radius: PachinkoConfig.treatRadius,
      assets: pachinkoAssets,
    );

    world.add(currentTreat!);
  }

  /// Handle tap events to drop oscillating treat
  @override
  void onTapDown(TapDownEvent event) {
    if (currentTreat?.isOscillating == true) {
      currentTreat!.drop();
      game.dropTreat(); // Update game logic state
    }
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
