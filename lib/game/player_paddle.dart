import 'dart:math';
import 'dart:ui';

import 'package:esense_flutter/esense.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pongsense/flame/esense.dart';

class PlayerPaddle extends PositionComponent
    with HasGameRef<FlameGame>, CollisionCallbacks {
  static const double speed = 400;

  late final RectangleHitbox paddleHitBox;
  late final RectangleComponent paddle;

  late Vector2 targetPosition;

  ESenseConfig? eSenseConfig;
  bool calibrate = false;
  Vector3? calibrationNormal;

  @override
  Future<void>? onLoad() {
    final worldRect = gameRef.size.toRect();

    // create paddle
    size = Vector2(10, 100);
    position.x = worldRect.width * 0.9 - 10;
    position.y = worldRect.height / 2 - size.y / 2;
    paddle = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blue,
    );
    paddleHitBox = RectangleHitbox(size: size);
    targetPosition = position;

    addAll([paddle, paddleHitBox]);

    add(ESenseListenerComponent(
        eSenseCallbacks: {
          ButtonEventChanged: (event) {
            if ((event as ButtonEventChanged).pressed == false) {
              return true; // only care about button-down event
            }
            calibrate = true;
            return true;
          },
          SensorConfigRead: (event) {
            var read = (event as SensorConfigRead);
            eSenseConfig = read.config;
            return true;
          }
        },
        sensorCallback: ((event) {
          final accRange = eSenseConfig?.accRange;
          if (accRange == null) {
            return false;
          }

          final rawAccel = Vector3(event.accel![0].toDouble(),
              event.accel![1].toDouble(), event.accel![2].toDouble());
          final accel = rawAccel / accRange.sensitivityFactor;

          if (calibrate) {
            calibrationNormal = accel;
          }

          calcTarget(accel);
          return true;
        })));

    return super.onLoad();
  }

  double remap(num number, num fromLow, num fromHigh, num toLow, num toHigh) {
    return (number - fromLow) * (toHigh - toLow) / (fromHigh - fromLow) + toLow;
  }

  void calcTarget(Vector3 accel) {
    final calibrationNormal = this.calibrationNormal;
    if (calibrationNormal == null) {
      print("skipping calc target, not calibrated");
      return;
    }

    if (accel.length > 2) {
      print("skipping calc target, length to big ${accel.length}");
      return;
    }

    const maxAngle = 30.0 * (pi / 180.0);
    final angle = accel.angleTo(calibrationNormal);
    final worldRect = gameRef.size.toRect();

    final targetX =
        remap(angle, -maxAngle, maxAngle, worldRect.left, worldRect.right);
    targetPosition.x = targetX;
  }

  @override
  void update(double dt) {
    super.update(dt);

    var moveVec = targetPosition - position;
    if (moveVec.length > speed) {
      moveVec.scaleTo(speed);
    }

    position.add(moveVec);
  }
}
