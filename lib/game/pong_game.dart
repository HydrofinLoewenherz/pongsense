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
    addAll(
      [
        ScreenHitbox(),
        Ball(),
        Ball(),
        Ball(),
        Ball(),
        Ball(),
        Ball(),
        Ball(),
        PlayerPaddle(_eSenseManager, _sender),
        AIPaddle()
      ],
    );
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
