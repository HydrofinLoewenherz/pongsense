import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/game/pong_game.dart';

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

    addAll([
      hitBox,
    ]);

    return super.onLoad();
  }

  void get _resetBall {
    position = gameRef.size / 2;
    final spawnAngle = getSpawnAngle;

    final vx = math.cos(spawnAngle * degree) * speed;
    final vy = math.sin(spawnAngle * degree) * speed;
    velocity = Vector2(
      vx,
      vy,
    );
  }

  double get getSpawnAngle {
    final sideToThrow = math.Random().nextBool();

    final random = math.Random().nextDouble();
    final spawnAngle = sideToThrow
        ? lerpDouble(-35, 35, random)!
        : lerpDouble(145, 215, random)!;

    return spawnAngle;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  @mustCallSuper
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);
    final collisionPoint = intersectionPoints.first;

    if (other is ScreenHitbox) {
      // Left Side Collision
      if (collisionPoint.x == 0) {
        velocity.x = -velocity.x;
        velocity.y = velocity.y;
      }
      // Right Side Collision
      if (collisionPoint.x == gameRef.size.x) {
        velocity.x = -velocity.x;
        velocity.y = velocity.y;
      }
      // Top Side Collision
      if (collisionPoint.y == 0) {
        velocity.x = velocity.x;
        velocity.y = -velocity.y;
      }
      // Bottom Side Collision
      if (collisionPoint.y == gameRef.size.y) {
        velocity.x = velocity.x;
        velocity.y = -velocity.y;
      }
    }
  }
}