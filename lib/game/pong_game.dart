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

    addBlockerGrid(player, ai);
  }

  void addBlockerGrid(PlayerPaddle player, AIPaddle ai) {
    final blockerSize = Vector2(30, 30);
    // gap between and around
    const gap = 10;

    final rows =
        ((player.y - (ai.y + ai.size.y)) - gap) ~/ (gap + blockerSize.x);
    final cols = (size.x - gap) ~/ (gap + blockerSize.x);

    final actualGapX = size.x - (gap + cols * (gap + blockerSize.x));
    final actualGapY =
        (player.y - (ai.y + ai.size.y)) - (gap + rows * (gap + blockerSize.y));

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if ((row - (rows - 1) / 2).abs() < 1 &&
            (col - (cols - 1) / 2).abs() < 1) {
          continue;
        }

        add(Blocker()
          ..size = blockerSize
          ..maxLives = 3
          ..position = Vector2(actualGapX / 2, actualGapY / 2) +
              Vector2(
                gap + col * (gap + blockerSize.x),
                (ai.y + ai.size.y) + gap + row * (gap + blockerSize.y),
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
