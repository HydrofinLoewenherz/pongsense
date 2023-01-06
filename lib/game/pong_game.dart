import 'dart:ui';

import 'package:esense_flutter/esense.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
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

    addAll(
      [ScreenHitbox(), Ball(), player, ai],
    );

    final blockerSize = Vector2(20, 20);
    final gap = 10;
    final rows = 3;
    final columns = 10;
    addAll(List<Blocker>.generate(rows * columns, (index) {
      final row = index ~/ rows;
      final col = index % rows;

      return Blocker()
        ..size = blockerSize
        ..maxLives = 3
        ..position = Vector2(
          lerpDouble(gap, size.x - gap, col / columns)!,
          lerpDouble(
              player.y + 2 * player.size.y, ai.y - 2 * ai.size.y, row / rows)!,
        );
    }));
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
