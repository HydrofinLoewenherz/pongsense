import 'dart:math';

import 'package:esense_flutter/esense.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/flame/esense.dart';
import 'package:pongsense/game/pong_game.dart';
import 'package:pongsense/math/remap.dart';
import 'package:pongsense/globals/connection.dart' as g;

class PlayerPaddle extends PositionComponent
    with HasGameRef<PongGame>, CollisionCallbacks {
  static const double speed = 400;

  late final RectangleHitbox paddleHitBox;
  late final RectangleComponent paddle;

  late Vector2 targetPosition;

  @override
  Future<void>? onLoad() {
    final worldRect = gameRef.size.toRect();

    // create paddle
    size = Vector2(100, 10);
    position.x = worldRect.width / 2 - size.x / 2;
    position.y = worldRect.height * 0.9 - 10;
    paddle = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blue,
    );
    paddleHitBox = RectangleHitbox(size: size);
    targetPosition = position;

    addAll([paddle, paddleHitBox]);

    add(ESenseListenerComponent(sensorCallback: ((event) {
      final accRange = g.device.deviceConfig?.accRange;
      if (accRange == null) {
        return false;
      }

      final rawAccel = Vector3(event.accel![0].toDouble(),
          event.accel![1].toDouble(), event.accel![2].toDouble());
      final accel = rawAccel / accRange.sensitivityFactor;

      calcTarget(accel);
      return true;
    })));

    return super.onLoad();
  }

  void calcTarget(Vector3 accel) {
    if (!gameRef.isCalibrated) {
      print("skipping calc target, not calibrated");
      return;
    }

    const maxAngle = 90.0 * (pi / 180.0);
    final angle = accel.angleToSigned(
      gameRef.upCalibration!.normalized(),
      gameRef.forwardCalibration!.normalized(),
    );
    final worldRect = gameRef.size.toRect();

    print(
        'A: ${(accel.x * 100).floor()}, ${(accel.y * 100).floor()}, ${(accel.z * 100).floor()}; A\': ${angle.radToDeg().floor()}');

    final targetX = angle.remapAndClamp(
        -(pi / 2), pi / 2, worldRect.left, worldRect.right - paddle.width);
    targetPosition.x = targetX.toDouble();
  }

  @override
  void update(double dt) {
    super.update(dt);

    var moveVec = targetPosition - center;
    if (moveVec.length > speed) {
      moveVec.scaleTo(speed);
    }

    center.add(moveVec);
  }
}
