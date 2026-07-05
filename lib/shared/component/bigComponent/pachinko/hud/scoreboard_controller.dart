import 'package:flutter/material.dart';
import 'hud_element_controller.dart';
import '../config/PachinkoConfig.dart';

class ScoreboardController extends HudElementController {
  int score = 0;
  int collisionCount = 0;

  late final AnimationController pop = AnimationController(
    vsync: this,
    duration: PachinkoConfig.scorePopDuration,
  );

  Future<void> addPoints(int points) async {
    final gen = beginSequence();
    score += points;
    notifyListeners();
    pop.reset();
    await pop.forward();
    if (!isCurrent(gen)) return;
    await pop.reverse();
  }

    Future<void> addPointsAndCollision(int points) async {
    final gen = beginSequence();
    score += points;
    collisionCount++;
    notifyListeners();
    pop.reset();
    await pop.forward();
    if (!isCurrent(gen)) return;
    await pop.reverse();
  }

  Future<void> incrementCollision() async {
    final gen = beginSequence();
    collisionCount++;
    notifyListeners();
    pop.reset();
    await pop.forward();
    if (!isCurrent(gen)) return;
    await pop.reverse();
  }

  void resetRound() {
    score = 0;
    collisionCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    pop.dispose();
    super.dispose();
  }
}
