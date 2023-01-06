import 'dart:math';

import 'package:esense_flutter/esense.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/flame/esense.dart';
import 'package:pongsense/math/remap.dart';
import 'package:pongsense/globals/connection.dart' as g;

class PlayerPaddle extends PositionComponent
    with HasGameRef<FlameGame>, CollisionCallbacks {
  static const double speed = 400;

  late final RectangleHitbox paddleHitBox;
  late final RectangleComponent paddle;

  late Vector2 targetPosition;

  int calibrate = -2;
  List<Vector3> calibrationNormals = [];
  Vector3? lastAccel;

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

    add(ESenseListenerComponent(
        eSenseCallbacks: {
          ButtonEventChanged: (event) {
            if ((event as ButtonEventChanged).pressed == false) {
              return true; // only care about button-down event
            }
            final accel = lastAccel;
            if (accel == null) return true;
            if (calibrate == -2) {
              calibrationNormals.add(accel);
              calibrate = -1;
              print('calibration added 1');
            } else if (calibrate == -1) {
              calibrationNormals.add(accel);
              calibrate = 0;
              print('calibrated');
            } else {
              calibrationNormals.clear();
              calibrate = -2;
              print('cleared');
            }
            return true;
          },
        },
        sensorCallback: ((event) {
          final accRange = g.device.deviceConfig?.accRange;
          if (accRange == null) {
            return false;
          }

          final rawAccel = Vector3(event.accel![0].toDouble(),
              event.accel![1].toDouble(), event.accel![2].toDouble());
          final accel = rawAccel / accRange.sensitivityFactor;
          lastAccel = accel;

          calcTarget(accel);
          return true;
        })));

    return super.onLoad();
  }

  void calcTarget(Vector3 accel) {
    if (calibrationNormals.length < 2) {
      print("skipping calc target, not calibrated");
      return;
    }

    // if (accel.length > 1.2) {
    //   print("skipping calc target, length too big ${accel.length}");
    //   return;
    // }

    const maxAngle = 90.0 * (pi / 180.0);
    final angle = accel.angleToSigned(
        calibrationNormals[0].normalized(), calibrationNormals[1].normalized());
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
