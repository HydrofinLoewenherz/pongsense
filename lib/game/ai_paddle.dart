import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/game/ball.dart';

class AIPaddle extends PositionComponent
    with HasGameRef<FlameGame>, CollisionCallbacks, KeyboardHandler {
  late final RectangleHitbox paddleHitBox;
  late final RectangleComponent paddle;
  final double speed = 400;

  @override
  Future<void>? onLoad() {
    final worldRect = gameRef.size.toRect();

    // create paddle
    size = Vector2(100, 10);
    position.x = worldRect.width / 2 - size.x / 2;
    position.y = worldRect.height * 0.1;
    paddle = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.red,
    );
    paddleHitBox = RectangleHitbox(
      size: size,
    );

    addAll([
      paddle,
      paddleHitBox,
    ]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final worldRect = gameRef.size.toRect();
    final ball = gameRef.children.firstWhere((child) => child is Ball) as Ball;

    final ballPositionWrtPaddleWidth = ball.x + (size.x);
    if (ball.y < worldRect.left ||
        ballPositionWrtPaddleWidth > worldRect.right) {
      return;
    }

    if (ball.x > position.x) {
      position.x += (speed * dt);
    }

    if (ball.x < position.x) {
      position.x -= (speed * dt);
    }
  }
}
