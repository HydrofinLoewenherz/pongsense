import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pongsense/game/ball.dart';

class PongGame extends FlameGame
    with HasTappables, HasCollisionDetection, HasKeyboardHandlerComponents {
  PongGame();

  @override
  Future<void> onLoad() async {
    addAll(
      [
        ScreenHitbox(),
        Ball()
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
}