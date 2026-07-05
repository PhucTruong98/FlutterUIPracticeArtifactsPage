import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Base for every HUD element controller.
/// - Is a TickerProvider so it can OWN AnimationControllers that outlive the
///   widget (this is what removes the GlobalKey-into-State fragility).
/// - Extends ChangeNotifier so it can also notify for non-animated display
///   changes (e.g. the level number text).
/// - Provides a generation token to cancel stale async sequences.
abstract class HudElementController extends ChangeNotifier
    implements TickerProvider {
  final Set<Ticker> _tickers = {};

  @override
  Ticker createTicker(TickerCallback onTick) {
    final ticker = Ticker(onTick);
    _tickers.add(ticker);
    return ticker;
  }

  int _generation = 0;

  /// Call at the start of every event. Capture the return value and re-check it
  /// with [isCurrent] after every `await` to detect supersession by a newer event.
  int beginSequence() => ++_generation;
  bool isCurrent(int gen) => gen == _generation;

  @override
  @mustCallSuper
  void dispose() {
    for (final t in _tickers) {
      t.dispose();
    }
    _tickers.clear();
    super.dispose();
  }
}
