import 'package:flutter/material.dart';
import 'hud_element_controller.dart';
import '../config/PachinkoConfig.dart';

class EnergyBarController extends HudElementController {
  EnergyBarController({required this.maxEnergy});

  // ---- Display state (drives text; not animated) ----
  int level = 1;
  double maxEnergy;
  double displayEnergy = 0; // shown as "displayEnergy/maxEnergy"

  // ---- Owned animation controllers (stable references) ----
  late final AnimationController fill = AnimationController(
    vsync: this,
    duration: PachinkoConfig.energyFillDuration,
  );
  late final AnimationController flash = AnimationController(
    vsync: this,
    duration: PachinkoConfig.levelFlashDuration,
  );

  // Swapped on each fill; the widget reads `.value` off this.
  Animation<double> fillAnimation = const AlwaysStoppedAnimation(0.0);
  double _lastPercent = 0.0;

  // ---- Events (game rules live here, not in the widget) ----

  /// Normal energy gain with no level-up. Interrupts any in-flight sequence.
  Future<void> setEnergy(double current) async {
    final gen = beginSequence();
    displayEnergy = current;
    notifyListeners(); // update text immediately
    await _animateFill(_lastPercent, current / maxEnergy, gen);
  }

  /// Level-up: fill to full, flash cycles, reset, fill to the overflow amount.
  Future<void> levelUp({
    required int newLevel,
    required double overflow,
    required double newMax,
  }) async {
    final gen = beginSequence();

    if (!await _animateFill(_lastPercent, 1.0, gen)) return;
    if (!await _flashCycles(PachinkoConfig.levelFlashCycles, gen)) return;

    // Commit the new level at the moment of the flash.
    level = newLevel;
    maxEnergy = newMax;
    displayEnergy = overflow;
    notifyListeners();

    _lastPercent = 0.0;
    await _animateFill(0.0, overflow / newMax, gen);
  }

  // ---- Internals ----

  Future<bool> _animateFill(double from, double to, int gen) async {
    fill.reset();
    fillAnimation = Tween<double>(begin: from, end: to)
        .animate(CurvedAnimation(parent: fill, curve: Curves.easeInOut));
    await fill.forward();
    if (!isCurrent(gen)) return false; // a newer event superseded us
    _lastPercent = to;
    return true;
  }

  /// Counted cycles driven by the flash controller itself — NOT Future.delayed —
  /// so it is frame-synced and always ends cleanly at 0.
  Future<bool> _flashCycles(int cycles, int gen) async {
    for (var i = 0; i < cycles; i++) {
      flash.reset();
      await flash.forward();
      if (!isCurrent(gen)) return false;
      await flash.reverse();
      if (!isCurrent(gen)) return false;
    }
    flash.value = 0.0;
    return true;
  }

  @override
  void dispose() {
    fill.dispose();
    flash.dispose();
    super.dispose();
  }
}
