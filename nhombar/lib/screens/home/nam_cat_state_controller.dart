import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'lobby_cats.dart';

enum CatExpression { neutral, drowsy, content, annoyed, observing }

enum CatActivity {
  idle,
  blink,
  drowsy,
  sleep,
  touched,
  happy,
  annoyed,
  observing,
}

enum CatInteraction { none, headTap, bodyTap, tailTap, headStroke }

enum CatRegion { head, body, tail }

/// One independent idle clock and cancellable reactions per character.
class CatStateController extends ChangeNotifier {
  CatStateController(
    this.pose, {
    bool Function(CatPose, CatExpression)? hasFrame,
    Random? random,
    this.idleEnabled = true,
  }) : _hasFrame = hasFrame ?? ((_, _) => true),
       _random = random ?? Random() {
    _scheduleIdle();
  }
  final bool Function(CatPose, CatExpression) _hasFrame;
  final Random _random;
  CatPose pose;
  CatExpression expression = CatExpression.neutral;
  CatInteraction interaction = CatInteraction.none;
  CatActivity? _idleActivity;
  CatActivity get activity {
    if (busy) {
      return interaction == CatInteraction.headStroke
          ? CatActivity.happy
          : CatActivity.touched;
    }
    return _idleActivity ??
        (pose == CatPose.sleeping ? CatActivity.sleep : CatActivity.idle);
  }

  final List<Timer> _timers = [];
  Timer? _idleTimer;
  bool _active = true;
  bool _disposed = false;
  bool idleEnabled;
  bool _petting = false;
  bool get busy => interaction != CatInteraction.none;

  void _cancel() {
    _idleTimer?.cancel();
    _idleTimer = null;
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  void _later(Duration delay, VoidCallback action) {
    late final Timer timer;
    timer = Timer(delay, () {
      _timers.remove(timer);
      if (_active && !_disposed) {
        action();
        notifyListeners();
      }
    });
    _timers.add(timer);
  }

  void _scheduleIdle() {
    _idleTimer?.cancel();
    if (!_active || _disposed || !idleEnabled || busy) return;
    final sleeping = pose == CatPose.sleeping;
    _idleTimer = Timer(
      Duration(
        milliseconds: sleeping
            ? 14000 + _random.nextInt(11000)
            : 4000 + _random.nextInt(5500),
      ),
      () {
        if (!_active || _disposed || busy) return;
        final options = sleeping
            ? [CatExpression.drowsy]
            : [
                CatExpression.content,
                CatExpression.content,
                CatExpression.drowsy,
                CatExpression.annoyed,
              ];
        final available = options.where((e) => _hasFrame(pose, e)).toList();
        if (available.isEmpty) {
          _scheduleIdle();
          return;
        }
        expression = available[_random.nextInt(available.length)];
        _idleActivity = switch (expression) {
          CatExpression.content => CatActivity.blink,
          CatExpression.drowsy => CatActivity.drowsy,
          CatExpression.annoyed => CatActivity.annoyed,
          _ => CatActivity.idle,
        };
        notifyListeners();
        _later(
          Duration(
            milliseconds: expression == CatExpression.content
                ? 160 + _random.nextInt(100)
                : 650 + _random.nextInt(650),
          ),
          _reset,
        );
      },
    );
  }

  void setIdleEnabled(bool enabled) {
    if (idleEnabled == enabled) return;
    idleEnabled = enabled;
    if (!busy) {
      _cancel();
      _reset();
    }
  }

  void setPose(CatPose next, {bool notify = true}) {
    _cancel();
    pose = next;
    _reset();
    if (notify) notifyListeners();
  }

  void setActive(bool value) {
    if (_active == value) return;
    _active = value;
    if (!value) {
      _cancel();
      _reset();
    } else {
      _scheduleIdle();
    }
  }

  CatExpression _reaction(CatExpression preferred) =>
      _hasFrame(pose, preferred) ? preferred : CatExpression.neutral;

  void noticeEnvironment(LobbyGame game) {
    if (!_active ||
        _disposed ||
        !idleEnabled ||
        busy ||
        pose == CatPose.sleeping ||
        _idleActivity != null) {
      return;
    }
    const preferred = CatExpression.observing;
    // Use an authored expression in the SAME pose, or quietly skip it.
    if (!_hasFrame(pose, preferred)) return;
    _cancel();
    expression = preferred;
    _idleActivity = CatActivity.observing;
    notifyListeners();
    _later(const Duration(milliseconds: 2200), _reset);
  }

  void tap(CatRegion region) {
    if (!_active || _disposed) return;
    _cancel();
    _idleActivity = null;
    _petting = false;
    interaction = switch (region) {
      CatRegion.head => CatInteraction.headTap,
      CatRegion.body => CatInteraction.bodyTap,
      CatRegion.tail => CatInteraction.tailTap,
    };
    expression = _reaction(
      region == CatRegion.tail && pose != CatPose.sleeping
          ? CatExpression.annoyed
          : CatExpression.drowsy,
    );
    // Repeated taps restart this reaction, never force another pose or surface.
    _later(
      Duration(milliseconds: pose == CatPose.sleeping ? 1600 : 650),
      _reset,
    );
    notifyListeners();
  }

  void startHeadStroke() {
    if (!_active || _disposed || pose == CatPose.sleeping || _petting) return;
    _cancel();
    _idleActivity = null;
    interaction = CatInteraction.headStroke;
    _petting = true;
    expression = _reaction(CatExpression.drowsy);
    if (_hasFrame(pose, CatExpression.content)) {
      _later(
        const Duration(milliseconds: 180),
        () => expression = CatExpression.content,
      );
    }
    notifyListeners();
  }

  void endHeadStroke() {
    if (!_petting) return;
    _petting = false;
    _cancel();
    expression = _reaction(CatExpression.drowsy);
    _later(const Duration(milliseconds: 350), _reset);
    notifyListeners();
  }

  void _reset() {
    _petting = false;
    _idleActivity = null;
    interaction = CatInteraction.none;
    expression = CatExpression.neutral;
    _scheduleIdle();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancel();
    super.dispose();
  }
}
