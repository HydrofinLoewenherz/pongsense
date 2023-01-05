import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/game/ai_paddle.dart';
import 'package:pongsense/game/player_paddle.dart';
import 'package:pongsense/game/pong_game.dart';

const maxGamePause = 0.2;

bool almostEqual(double a, double b, {double confidence = 0.001}) {
  return (a - b).abs() < confidence;
}

class Ball extends CircleComponent
    with HasGameRef<PongGame>, CollisionCallbacks {
  Ball() {
    paint = Paint()..color = Colors.white;
    radius = 10;
  }

  static const double speed = 500;
  late Vector2 velocity;
  static const degree = math.pi / 180;
  static const nudgeSpeed = 300;

  @override
  Future<void> onLoad() {
    _resetBall;
    final hitBox = CircleHitbox(
      radius: radius,
    );

    addAll([hitBox]);

    return super.onLoad();
  }

  void get _resetBall {
    position = gameRef.size / 2;
    final spawnAngle = getSpawnAngle;

    final vx = math.cos(spawnAngle * degree) * speed;
    final vy = math.sin(spawnAngle * degree) * speed;
    velocity = Vector2(vx, vy);
  }

  double get getSpawnAngle {
    final sideToThrow = math.Random().nextBool();

    final random = math.Random().nextDouble();
    final spawnAngle = sideToThrow
        ? lerpDouble(-135, -45, random)!
        : lerpDouble(45, 135, random)!;

    return spawnAngle;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt > maxGamePause) {
      return;
    }

    final worldRect = gameRef.size.toRect();
    if (position.y < (worldRect.top - 0.001)) {
      _resetBall;
      return;
    }
    if (position.y > (worldRect.bottom + 0.001)) {
      _resetBall;
      return;
    }

    position += velocity * dt;
  }

  @override
  @mustCallSuper
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is ScreenHitbox) {
      handleScreenCollide(intersectionPoints);
    }

    if (other is PlayerPaddle) {
      final paddleRect = other.paddle.toAbsoluteRect();
      handleRectCollide(paddleRect, intersectionPoints);
    }

    if (other is AIPaddle) {
      final paddleRect = other.paddle.toAbsoluteRect();
      handleRectCollide(paddleRect, intersectionPoints);
    }
  }

  void handleScreenCollide(final Set<Vector2> collisionPoints) {
    final worldRect = gameRef.size.toRect();
    final collisionPoint = collisionPoints.first;

    // left side collision
    if (almostEqual(collisionPoint.x, worldRect.left)) {
      velocity.x = -velocity.x;
    }
    // right side collision
    if (almostEqual(collisionPoint.x, worldRect.right)) {
      velocity.x = -velocity.x;
    }
  }

  void handleRectCollide(final Rect rect, final Set<Vector2> collisionPoints) {
    final collisionPoint = collisionPoints.first;

    // top side collision
    if (almostEqual(collisionPoint.y, rect.top) && (velocity.y > 0)) {
      velocity.y = -velocity.y;
    }
    // bottom side collision
    if (almostEqual(collisionPoint.y, rect.bottom) && (velocity.y < 0)) {
      velocity.y = -velocity.y;
    }
    // left side collision
    if (almostEqual(collisionPoint.x, rect.left) && (velocity.x > 0)) {
      velocity.x = -velocity.x;
    }
    // right side collision
    if (almostEqual(collisionPoint.x, rect.right) && (velocity.x < 0)) {
      velocity.x = -velocity.x;
    }
  }
}
