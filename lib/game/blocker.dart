import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Blocker extends RectangleComponent
    with HasGameRef<FlameGame>, CollisionCallbacks {
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
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    lives--;

    paint.color = Color.lerp(Colors.red, Colors.green, lives / maxLives)!;

    if (lives == 0) {
      removeFromParent();
    }
  }
}
