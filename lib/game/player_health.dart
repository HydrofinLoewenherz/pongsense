import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/game/pong_game.dart';

class PlayerHeart extends PositionComponent {
  late final CircleComponent icon;
  bool filled = true;
  bool _prevFilled = true;

  @override
  Future<void>? onLoad() {
    icon = CircleComponent(radius: 5);

    add(icon);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    icon.paint.color = filled ? Colors.white : Colors.white.withAlpha(100);

    if (filled != _prevFilled) {
      // TODO animation and sound effect
    }

    _prevFilled = filled;
    super.update(dt);
  }
}

class PlayerHealth extends PositionComponent with HasGameRef<PongGame> {
  late final List<PlayerHeart> hearts =
      List<PlayerHeart>.generate(gameRef.playerMaxHealth, (i) {
    return PlayerHeart()..position = Vector2(10.0 + (15 * i), 10);
  });

  @override
  Future<void>? onLoad() {
    addAll(hearts);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    for (var i = 0; i < gameRef.playerMaxHealth; i++) {
      hearts[i].filled = (i < gameRef.playerHealth);
    }

    super.update(dt);
  }
}
