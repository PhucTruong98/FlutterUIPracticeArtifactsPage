import 'package:flutter/material.dart';
import 'hud_element_controller.dart';
import '../config/PachinkoConfig.dart';
import '../models/GameEventBus.dart';

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

 

  // ---- Internals ----

  Future<bool> _animateFill(double from, double to, int gen) async {
    fill.reset();
    fillAnimation = Tween<double>(
      begin: from,
      end: to,
    ).animate(CurvedAnimation(parent: fill, curve: Curves.easeInOut));
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

  Future<void> onTreatCaught(int newScore) async {
    final gen = beginSequence();
    var newTotalEnergy = displayEnergy + newScore;

    while (newTotalEnergy >= maxEnergy) {
      //first pump
      if (!await _animateFill(displayEnergy / maxEnergy, 1.0, gen)) return;
      if (!await _flashCycles(PachinkoConfig.levelFlashCycles, gen)) return;

      // Emit level-up event after flash completes
      GameEventBus.instance.emit(const LevelUpEvent());

      //update text
      level++;
      displayEnergy = 0.0;
      notifyListeners();

      newTotalEnergy -= maxEnergy;
    }
    //animate left over energy
    // Animate leftover energy (if any)
    if (newTotalEnergy > 0 || displayEnergy > 0) {
      if (!await _animateFill(0.0, newTotalEnergy / maxEnergy, gen)) return;
    }

    // // Final state update
    // if (!isCurrent(gen)) return;

    displayEnergy = newTotalEnergy;
    notifyListeners();
  }

  @override
  void dispose() {
    fill.dispose();
    flash.dispose();
    super.dispose();
  }
}
