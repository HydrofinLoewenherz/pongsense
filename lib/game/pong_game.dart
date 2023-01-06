import 'dart:math';

import 'package:esense_flutter/esense.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pongsense/esense/sender.dart';
import 'package:pongsense/flame/esense.dart';
import 'package:pongsense/game/ai_paddle.dart';
import 'package:pongsense/game/ball.dart';
import 'package:pongsense/game/blocker.dart';
import 'package:pongsense/game/player_health.dart';
import 'package:pongsense/game/player_paddle.dart';

const pauseOverlayIdentifier = "PauseOverlay";
const endOverlayIdentifier = "EndOverlay";

class PongGame extends FlameGame
    with
        HasTappables,
        HasCollisionDetection,
        HasKeyboardHandlerComponents,
        HasESenseHandlerComponents {
  late final Sender _sender;
  late final ESenseManager _eSenseManager;

  double score = 0;
  int playerMaxHealth = 3;
  late int playerHealth = playerMaxHealth;

  PongGame(final ESenseManager eSenseManager, final Sender sender) {
    _sender = sender;
    _eSenseManager = eSenseManager;
  }

  @override
  Future<void> onLoad() async {
    final player = PlayerPaddle(_eSenseManager, _sender);
    final ai = AIPaddle();

    await FlameAudio.audioCache.load('sfx/8-bit-jump-sound.mp3');

    addAll(
      [ScreenHitbox(), player, ai, Ball(), PlayerHealth()],
    );

    final gridPadding = Vector2(10, size.y * 0.1);
    final aiBottom = ai.paddle.toAbsoluteRect().bottom;
    final playerTop = player.paddle.toAbsoluteRect().top;
    addBlockerGrid(Rect.fromPoints(
      Offset(gridPadding.x, aiBottom + gridPadding.y),
      Offset(size.x - gridPadding.x, playerTop - gridPadding.y),
    ));
  }

  void addBlockerGrid(Rect area, {double gap = 10.0, double emptyRad = 100}) {
    return;

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

        add(blocker);
      }
    }
  }

  void damagePlayer({int amount = 1}) {
    playerHealth = max(0, playerHealth - amount);

    if (playerHealth == 0) {
      pauseEngine();
      overlays.add(endOverlayIdentifier);
    }
  }

  void healPlayer({int amount = 1}) {
    playerHealth = min(playerHealth + amount, playerMaxHealth);
  }

  void reset() {
    // TODO implement me!
    print("reset");
  }

  void togglePause() {
    if (overlays.isActive(endOverlayIdentifier)) {
      return;
    }

    if (overlays.isActive(pauseOverlayIdentifier)) {
      overlays.remove(pauseOverlayIdentifier);
      resumeEngine();
    } else {
      overlays.add(pauseOverlayIdentifier);
      pauseEngine();
    }
  }

  @override
  @mustCallSuper
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    return KeyEventResult.handled;
  }

  @override
  @mustCallSuper
  ESenseEventResult onESenseEvent(ESenseEvent event) {
    super.onESenseEvent(event);

    return ESenseEventResult.handled;
  }

  @override
  void onLongTapDown(int pointerId, TapDownInfo info) {
    super.onLongTapDown(pointerId, info);

    togglePause();
  }
}
