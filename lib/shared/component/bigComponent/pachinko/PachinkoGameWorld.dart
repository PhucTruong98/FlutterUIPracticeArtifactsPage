import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'components/TreatBody.dart';
import 'components/PegBody.dart';
import 'components/WallBody.dart';
import 'components/PuppyCatchZone.dart';

/// Main Forge2D game world for Pachinko physics simulation
class PachinkoGameWorld extends Forge2DGame with ContactCallbacks {
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
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Center camera on the board - zoom out to see the full board
    camera.viewfinder.position = Vector2(0, 0);
    camera.viewfinder.zoom = 8;

    // Initialize the board
    _createWalls();
    _createPegs();
    _createCatchZone();
  }

  @override
  void render(Canvas canvas) {
    // Draw background for the game board
    final bgPaint = Paint()
      ..color = const Color(0xFFD2B48C).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: const Offset(0, 0),
        width: boardWidth,
        height: boardHeight,
      ),
      bgPaint,
    );

    super.render(canvas);
  }

  /// Create side walls to keep treat on board
  void _createWalls() {
    // Left wall
    add(WallBody(
      start: Vector2(-boardWidth / 2, -boardHeight / 2),
      end: Vector2(-boardWidth / 2, boardHeight / 2),
      color: const Color(0xFF6B4423),
    ));

    // Right wall
    add(WallBody(
      start: Vector2(boardWidth / 2, -boardHeight / 2),
      end: Vector2(boardWidth / 2, boardHeight / 2),
      color: const Color(0xFF6B4423),
    ));

    // Bottom wall (backstop)
    add(WallBody(
      start: Vector2(-boardWidth / 2, boardHeight / 2),
      end: Vector2(boardWidth / 2, boardHeight / 2),
      color: const Color(0xFF6B4423),
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
        final x = -((pegsInRow - 1) * pegSpacing / 2) + (col * pegSpacing) + offset;

        final peg = PegBody(
          position: Vector2(x, y),
          radius: pegRadius,
        );

        pegs.add(peg);
        add(peg);
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
    add(catchZone);
  }

  /// Spawn a treat at the launch position
  void spawnTreat() {
    if (currentTreat != null) {
      return; // Only one treat at a time
    }

    currentTreat = TreatBody(
      position: Vector2(0, -boardHeight / 2 + 2), // Near top center
      radius: treatRadius,
      onPegHit: onPegHit,
      onCaught: onTreatCaught,
    );

    add(currentTreat!);
  }

  /// Remove current treat from the game
  void removeTreat() {
    if (currentTreat != null) {
      remove(currentTreat!);
      currentTreat = null;
    }
  }

  @override
  void beginContact(Object a, Object b) {
    // Check for treat-peg collision
    if (_isTreatPegCollision(a, b)) {
      _handlePegCollision(a, b);
    }

    // Check for treat-catch zone collision
    if (_isTreatCatchZoneCollision(a, b)) {
      _handleTreatCaught();
    }
  }

  bool _isTreatPegCollision(Object a, Object b) {
    return (a is TreatBody && b is PegBody) || (a is PegBody && b is TreatBody);
  }

  bool _isTreatCatchZoneCollision(Object a, Object b) {
    return (a is TreatBody && b is PuppyCatchZone) ||
        (a is PuppyCatchZone && b is TreatBody);
  }

  void _handlePegCollision(Object a, Object b) {
    final peg = a is PegBody ? a : b as PegBody;

    // Mark peg as hit
    peg.onHit();

    // Notify game of peg hit
    onPegHit?.call();
  }

  void _handleTreatCaught() {
    // Notify game that treat was caught
    onTreatCaught?.call();

    // Remove treat after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      removeTreat();
    });
  }
}
