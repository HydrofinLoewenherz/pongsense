import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:async' as async;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/game/ai_paddle.dart';
import 'package:pongsense/game/player_paddle.dart';
import 'package:pongsense/game/pong_game.dart';
import 'package:pongsense/math/remap.dart';

bool almostEqual(double a, double b, {double confidence = 1}) {
  return (a - b).abs() < confidence;
}

class TraceComputedParticle extends ComputedParticle {
  final Vector2 moveDiff;

  TraceComputedParticle({
    required super.renderer,
    required this.moveDiff,
    super.lifespan,
  });
}

class Ball extends CircleComponent
    with HasGameRef<PongGame>, CollisionCallbacks {
  Ball() {
    paint = Paint()..color = Colors.white;
    radius = _radius;
  }

  static const _radius = 10.0;
  static const speed = 400.0;
  static const stepSize = _radius / 4.0;

  late Vector2 velocity;

  static const degree = math.pi / 180;
  static const nudgeSpeed = 300;

  @override
  Future<void> onLoad() {
    _resetBall();
    add(CircleHitbox(radius: radius, isSolid: true));
    return super.onLoad();
  }

  void _resetBall() {
    position = gameRef.size / 2;
    final spawnAngle = calcSpawnAngle(4, -50);

    final vx = math.cos(spawnAngle * degree) * speed;
    final vy = math.sin(spawnAngle * degree) * speed;
    velocity = Vector2(vx, vy);
  }

  double calcSpawnAngle(double rangeDeg, [double offsetDeg = 0]) {
    final sideToThrow = math.Random().nextBool();
    final diff = rangeDeg / 2;
    return math.Random().nextDouble().remap(0, 1, 90 - diff, 90 + diff) +
        (offsetDeg + (sideToThrow ? 0 : 180));
  }

  @override
  void update(double dt) {
    super.update(dt);

    final steps = ((velocity * dt).length / stepSize).ceil();

    for (int i = 0; i < steps; i += 1) {
      position += velocity.normalized() * stepSize;
      game.collisionDetection.run();

      game.add(ParticleSystemComponent(
          particle: ComputedParticle(
              lifespan: .6,
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = Color.lerp(this.paint.color.withOpacity(0.2),
                      Colors.transparent, particle.progress)!
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1;
                canvas.drawCircle(Offset.zero, radius, paint);
              }),
          position: position + Vector2(radius, radius)));
    }
  }

  @override
  @mustCallSuper
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    final collisionRect = Rect.fromPoints(
      intersectionPoints.first.toOffset(),
      intersectionPoints.last.toOffset(),
    );

    switch (other.runtimeType) {
      case ScreenHitbox:
        return handleScreenCollide(collisionRect);
      case PlayerPaddle:
        return handleRectCollide(collisionRect);
      case AIPaddle:
        return handleRectCollide(collisionRect);
      default:
        return;
    }
  }

  void handleScreenCollide(final Rect collisionRect) {
    if (collisionRect.width > collisionRect.height) {
      _resetBall();
    } else {
      velocity.x *= -1;
    }
  }

  void handleRectCollide(final Rect collisionRect) {
    if (collisionRect.width > collisionRect.height) {
      velocity.y *= -1;
    } else {
      velocity.x *= -1;
    }
  }
}
