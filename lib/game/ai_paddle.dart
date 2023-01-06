import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/game/ball.dart';

class AIPaddle extends PositionComponent
    with HasGameRef<FlameGame>, CollisionCallbacks, KeyboardHandler {
  late final RectangleHitbox paddleHitBox;
  late final RectangleComponent paddle;
  final double speed = 100;

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
      isSolid: true,
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

    if (ball.center.x > center.x) {
      position.x = min(position.x + (speed * dt), worldRect.right - size.x);
    }

    if (ball.center.x < center.x) {
      position.x = max(0, position.x - (speed * dt));
    }
  }
}
