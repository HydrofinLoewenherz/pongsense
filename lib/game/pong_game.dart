import 'dart:ui';

import 'package:esense_flutter/esense.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pongsense/esense/sender.dart';
import 'package:pongsense/flame/esense.dart';
import 'package:pongsense/game/ai_paddle.dart';
import 'package:pongsense/game/ball.dart';
import 'package:pongsense/game/blocker.dart';
import 'package:pongsense/game/player_paddle.dart';

class PongGame extends FlameGame
    with
        HasTappables,
        HasCollisionDetection,
        HasKeyboardHandlerComponents,
        HasESenseHandlerComponents {
  late final Sender _sender;
  late final ESenseManager _eSenseManager;

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
      [ScreenHitbox(), player, ai, Ball()],
    );

    const gridPadding = 10.0;
    final aiBottom = ai.paddle.toAbsoluteRect().bottom;
    final playerTop = player.paddle.toAbsoluteRect().top;
    addBlockerGrid(Rect.fromPoints(
      Offset(gridPadding, aiBottom + gridPadding),
      Offset(size.x - gridPadding, playerTop - gridPadding),
    ));
  }

  void addBlockerGrid(Rect area, {double gap = 10.0, centerEmpty = true}) {
    final blockerSize = Vector2(30, 30);

    // add one gap to width/height because its divided through one too much
    final rows = (area.height + gap) ~/ (gap + blockerSize.y);
    final cols = (area.width + gap) ~/ (gap + blockerSize.x);
    final overHangY = (area.height + gap) % (gap + blockerSize.y);
    final overHangX = (area.width + gap) % (gap + blockerSize.x);

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if (centerEmpty &&
            (row - (rows - 1) / 2).abs() < 1 &&
            (col - (cols - 1) / 2).abs() < 1) {
          continue;
        }

        add(Blocker()
          ..size = blockerSize
          ..maxLives = 3
          ..position = Vector2(
            (overHangX / 2) + area.left + (col * (gap + blockerSize.x)),
            (overHangY / 2) + area.top + (row * (gap + blockerSize.y)),
          ));
      }
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
}
