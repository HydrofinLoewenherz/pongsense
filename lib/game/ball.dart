import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
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
  static const speed = 100.0;
  static const stepSize = _radius / 4.0;

  late Vector2 velocity;

  static const degree = math.pi / 180;
  static const nudgeSpeed = 5.0;

  @override
  Future<void> onLoad() async {
    reset();
    add(CircleHitbox(radius: radius, isSolid: true));
    return super.onLoad();
  }

  void reset() {
    position = (gameRef.size - size) / 2;
    final spawnAngle = calcSpawnAngle(45, gapDeg: 15).degToRad();
    velocity = Vector2(
      math.cos(spawnAngle) * speed,
      math.sin(spawnAngle) * speed,
    );
  }

  double calcSpawnAngle(double rangeDeg,
      {double offsetDeg = 0, double gapDeg = 0}) {
    final upDown = math.Random().nextBool();
    final diff = rangeDeg / 2;
    var randDeg = math.Random().nextDouble().remap(0, 1, -diff, diff);
    if (randDeg.abs() < (gapDeg / 2)) {
      randDeg += randDeg.sign * (gapDeg / 2);
    }
    return randDeg + 90 + (upDown ? 0 : 180) + offsetDeg;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // skip all updates where the time was to long because of the following collision check
    if (dt > 1) {
      return;
    }

    // reset ball if it manages to get out of bounds
    final infWorldRect = gameRef.size.toRect().inflate(2 * radius);
    if (!infWorldRect.contains(position.toOffset())) {
      reset();
    }

    // give score for being alive
    gameRef.score += dt;

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

    playCollisionSound();

    final collisionRect = Rect.fromPoints(
      intersectionPoints.first.toOffset(),
      intersectionPoints.last.toOffset(),
    );

    switch (other.runtimeType) {
      case ScreenHitbox:
        return handleScreenCollide(collisionRect);
      case PlayerPaddle:
        velocity += velocity.normalized() * nudgeSpeed;
        return handleRectCollide(
            collisionRect, (other as PlayerPaddle).paddle.toAbsoluteRect());
      case AIPaddle:
        velocity += velocity.normalized() * nudgeSpeed;
        return handleRectCollide(
            collisionRect, (other as AIPaddle).paddle.toAbsoluteRect());
      case Blocker:
        return handleRectCollide(collisionRect, other.toAbsoluteRect());
    }
  }

  void handleScreenCollide(final Rect collisionRect) {
    final worldRect = gameRef.size.toRect();

    // left side collision
    if (almostEqual(collisionRect.right, worldRect.left)) {
      velocity.x *= -1;
    }
    // right side collision
    if (almostEqual(collisionRect.left, worldRect.right)) {
      velocity.x *= -1;
    }
    // top collision
    if (almostEqual(collisionRect.bottom, worldRect.top)) {
      gameRef.healPlayer();
      gameRef.score += 100;
      reset();
    }
    // bottom collision
    if (almostEqual(collisionRect.top, worldRect.bottom)) {
      gameRef.damagePlayer();
      reset();
    }
  }

  void handleRectCollide(final Rect collisionRect, Rect other) {
    Vector2 nextVelocity = velocity.clone();

    // top side collision
    if (almostEqual(collisionRect.top, other.top) && (velocity.y > 0)) {
      nextVelocity.y = -velocity.y;
    }
    // bottom side collision
    if (almostEqual(collisionRect.bottom, other.bottom) && (velocity.y < 0)) {
      nextVelocity.y = -velocity.y;
    }
    // left side collision
    if (almostEqual(collisionRect.left, other.left) && (velocity.x > 0)) {
      nextVelocity.x = -velocity.x;
    }
    // right side collision
    if (almostEqual(collisionRect.right, other.right) && (velocity.x < 0)) {
      nextVelocity.x = -velocity.x;
    }

    velocity = nextVelocity;
  }

  void playCollisionSound() {
    FlameAudio.play("sfx/8-bit-pong-sound.mp3");
  }
}
