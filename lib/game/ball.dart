import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:async' as async;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/game/ai_paddle.dart';
import 'package:pongsense/game/blocker.dart';
import 'package:pongsense/game/player_paddle.dart';
import 'package:pongsense/game/pong_game.dart';
import 'package:pongsense/math/remap.dart';

bool almostEqual(double a, double b, {double confidence = 1}) {
  return (a - b).abs() < confidence;
}

class TraceParticleSystemComponent extends ParticleSystemComponent {
  static Paint paint(Particle p) => Paint()
    ..color = Colors.white.withOpacity(p.progress.remap(1, 0, 0, 0.2))
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  TraceParticleSystemComponent(Vector2 position, double radius, double lifespan)
      : super(
            position: position + Vector2(radius, radius),
            particle: ComputedParticle(
                lifespan: lifespan,
                renderer: (canvas, particle) {
                  canvas.drawCircle(Offset.zero, radius, paint(particle));
                }));
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
    final spawnAngle = calcSpawnAngle(30).degToRad();
    velocity = Vector2(
      math.cos(spawnAngle) * speed,
      math.sin(spawnAngle) * speed,
    );
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

    var particles = <TraceParticleSystemComponent>[];
    for (int i = 0; i < steps; i += 1) {
      particles.add(TraceParticleSystemComponent(position, _radius, 0.7));
      position += velocity.normalized() * stepSize;
      game.collisionDetection.run();
    }
    game.addAll(particles);
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
      case Blocker:
        return handleRectCollide(collisionRect);
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
    // hack to make sure, that ball prefers to bounce up
    if (collisionRect.width > collisionRect.height) {
      velocity.y *= -1;
    } else {
      velocity.x *= -1;
    }
  }
}
