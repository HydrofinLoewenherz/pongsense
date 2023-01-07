import 'dart:math';

import 'package:esense_flutter/esense.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/esense/device.dart';
import 'package:pongsense/flame/esense.dart';
import 'package:pongsense/game/ai_paddle.dart';
import 'package:pongsense/game/ball.dart';
import 'package:pongsense/game/blocker.dart';
import 'package:pongsense/game/player_health.dart';
import 'package:pongsense/game/player_paddle.dart';
import 'package:pongsense/game/player_score.dart';
import 'package:pongsense/globals/connection.dart' as g;

const pauseOverlayIdentifier = "PauseOverlay";
const endOverlayIdentifier = "EndOverlay";
const calibrateOverlayIdentifier = "CalibrateOverlay";

class PongGame extends FlameGame
    with
        HasTappables,
        HasCollisionDetection,
        HasKeyboardHandlerComponents,
        HasESenseHandlerComponents {
  // game loop
  double score = 0;
  int playerMaxHealth = 3;
  late int playerHealth = playerMaxHealth;

  // esense connection
  Closer? _stateCallbackCloser;
  Closer? _eventCallbackCloser;
  Closer? _sensorCallbackCloser;

  // game components
  late final PlayerPaddle player;
  late final AIPaddle ai;
  late final List<Blocker> blocker;
  late final Ball ball;

  // calibration
  bool shouldCalibrate = false;
  Vector3? upCalibration;
  Vector3? forwardCalibration;
  bool get isCalibrated =>
      upCalibration != null && forwardCalibration != null && !shouldCalibrate;

  @override
  void onDetach() {
    _stateCallbackCloser?.call();
    _eventCallbackCloser?.call();
    _sensorCallbackCloser?.call();
    super.onDetach();
  }

  @override
  void onAttach() {
    super.onAttach();

    _stateCallbackCloser = g.device.registerStateCallback((state) {
      if (state == DeviceState.waiting) {
        togglePause();
      }
    });
    _sensorCallbackCloser = g.device.registerSensorCallback((event) {
      onSensorEvent(event);
    });
    _eventCallbackCloser = g.device.registerEventCallback((event) {
      onESenseEvent(event);
    });
  }

  @override
  Future<void> onLoad() async {
    player = PlayerPaddle();
    ai = AIPaddle();
    ball = Ball();

    await FlameAudio.audioCache.load('sfx/8-bit-jump-sound.mp3');

    addAll([
      ScreenHitbox(),
      player,
      ai,
      ball,
      PlayerHealth(),
      PlayerScore(),
    ]);

    blocker = addBlockers(player, ai);
    addAll(blocker);
  }

  List<Blocker> addBlockers(PlayerPaddle player, AIPaddle ai) {
    final gridPadding = Vector2(10, size.y * 0.2);
    final aiBottom = ai.paddle.toAbsoluteRect().bottom;
    final playerTop = player.paddle.toAbsoluteRect().top;
    return addBlockerGrid(Rect.fromPoints(
      Offset(gridPadding.x, aiBottom + gridPadding.y),
      Offset(size.x - gridPadding.x, playerTop - gridPadding.y),
    ));
  }

  List<Blocker> addBlockerGrid(Rect area,
      {double gap = 10.0, double emptyRad = 100}) {
    List<Blocker> blockers = [];

    final blockerSize = Vector2(30, 30);
    final emptyRect =
        Rect.fromCenter(center: area.center, width: emptyRad, height: emptyRad);

    // add one gap to width/height because its divided through one too much
    final rows = (area.height + gap) ~/ (gap + blockerSize.y);
    final cols = (area.width + gap) ~/ (gap + blockerSize.x);
    final overHangY = (area.height + gap) % (gap + blockerSize.y);
    final overHangX = (area.width + gap) % (gap + blockerSize.x);

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final blocker = Blocker()
          ..size = blockerSize
          ..maxLives = 3
          ..position = Vector2(
            (overHangX / 2) + area.left + (col * (gap + blockerSize.x)),
            (overHangY / 2) + area.top + (row * (gap + blockerSize.y)),
          );

        if (blocker.toAbsoluteRect().overlaps(emptyRect)) {
          continue;
        }

        blockers.add(blocker);
      }
    }
    return blockers;
  }

  void damagePlayer({int amount = 1}) {
    playerHealth = max(0, playerHealth - amount);
    // show end overlay if player died
    if (playerHealth == 0) {
      pauseEngine();
      overlays.add(endOverlayIdentifier);
    }
  }

  void healPlayer({int amount = 1}) {
    playerHealth = min(playerHealth + amount, playerMaxHealth);
  }

  // resets all game elements and resumes the engine
  // expects to currently show the end overlay
  void reset() {
    score = 0;
    playerHealth = playerMaxHealth;
    for (var b in blocker) {
      b.reset();
      if (b.parent == null) {
        add(b);
      }
    }
    ball.reset();

    if (overlays.isActive(endOverlayIdentifier)) {
      overlays.remove(endOverlayIdentifier);
    }
    resumeEngine();
  }

  // toggles the pause overlay (and engine)
  void togglePause() {
    if (overlays.isActive(pauseOverlayIdentifier)) {
      overlays.clear();
      resumeEngine();
    } else {
      overlays.add(pauseOverlayIdentifier);
      pauseEngine();
    }
  }

  void resetCalibration() {
    upCalibration = null;
    forwardCalibration = null;

    // idiot hack to update overlay
    if (overlays.isActive(calibrateOverlayIdentifier)) {
      overlays.remove(calibrateOverlayIdentifier);
      overlays.add(calibrateOverlayIdentifier);
    }
  }

  // if not calibrated, uses the events acc vector as the next calibration vector (first 'up' then 'forward').
  bool calibrate(SensorEvent event) {
    final eventAccel = event.accel;
    if (isCalibrated || eventAccel == null) {
      return false;
    }

    final accRange = g.device.deviceConfig?.accRange;
    if (accRange == null) {
      return false;
    }

    final rawAccel = Vector3(eventAccel[0].toDouble(), eventAccel[1].toDouble(),
        eventAccel[2].toDouble());
    final accel = rawAccel / accRange.sensitivityFactor;

    // update 'up' first and then 'forward'
    if (upCalibration == null) {
      upCalibration = accel;
    } else {
      forwardCalibration = accel;
    }

    // idiot hack to update overlay
    if (overlays.isActive(calibrateOverlayIdentifier)) {
      overlays.remove(calibrateOverlayIdentifier);
      overlays.add(calibrateOverlayIdentifier);
    }
    return true;
  }

  @override
  void onLongTapDown(int pointerId, TapDownInfo info) {
    super.onLongTapDown(pointerId, info);

    // don't allow to close end overlay (only via reset)
    if (!overlays.isActive(endOverlayIdentifier)) {
      togglePause();
    }
  }

  @override
  @mustCallSuper
  ESenseEventResult onESenseEvent(
    ESenseEvent event,
  ) {
    // update state to use the next sensor event to update the calibration
    // only if calibration overlay is open to prevent accidental calibration
    if (event is ButtonEventChanged &&
        event.pressed &&
        overlays.isActive(calibrateOverlayIdentifier)) {
      shouldCalibrate = true;
    }

    return super.onESenseEvent(event);
  }

  @override
  @mustCallSuper
  ESenseEventResult onSensorEvent(
    SensorEvent event,
  ) {
    if (shouldCalibrate) {
      calibrate(event);
      shouldCalibrate = false;
    }

    return super.onSensorEvent(event);
  }
}
