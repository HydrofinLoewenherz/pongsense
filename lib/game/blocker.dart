import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/game/pong_game.dart';

class Blocker extends RectangleComponent
    with HasGameRef<PongGame>, CollisionCallbacks {
  double maxLives = 3;
  late double lives = maxLives;

  @override
  Future<void>? onLoad() {
    final hitBox = RectangleHitbox(
      size: size,
      isSolid: true,
    );

    paint.color = Colors.green;

    addAll([hitBox]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    paint.color = Color.lerp(Colors.red, Colors.green, lives / maxLives)!;

    super.update(dt);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    lives--;

    if (lives == 0) {
      removeFromParent();
      gameRef.score += 50;
    }
  }

  reset() {
    lives = maxLives;
  }
}
