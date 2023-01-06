import 'dart:math';

import 'package:esense_flutter/esense.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/esense/sender.dart';
import 'package:pongsense/flame/esense.dart';
import 'package:pongsense/math/remap.dart';

class PlayerPaddle extends PositionComponent
    with HasGameRef<FlameGame>, CollisionCallbacks {
  static const double speed = 400;

  late final Sender _sender;
  late final ESenseManager _eSenseManager;

  late final RectangleHitbox paddleHitBox;
  late final RectangleComponent paddle;

  late Vector2 targetPosition;

  ESenseConfig? eSenseConfig;
  bool calibrate = false;
  bool calibrating = false; // TODO: use this
  Vector3? calibrationNormal;
  DateTime? _lastValue;
  int _counter = 0;

  PlayerPaddle(final ESenseManager eSenseManager, final Sender sender) {
    _sender = sender;
    _eSenseManager = eSenseManager;
  }

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
          final now = DateTime.now();
          if (_lastValue != null) {
            if (_counter < 10) {
              _counter += 1;
            } else {
              _counter = 0;
              print('delay ${now.difference(_lastValue!).inMilliseconds}ms');
            }
          }
          _lastValue = now;

          final accRange = eSenseConfig?.accRange;
          if (accRange == null) {
            _sender.pushAll([
              _eSenseManager.getSensorConfig,
            ]);
            return false;
          }

          final rawAccel = Vector3(event.accel![0].toDouble(),
              event.accel![1].toDouble(), event.accel![2].toDouble());
          final accel = rawAccel / accRange.sensitivityFactor;

          if (calibrate) {
            calibrationNormal = accel;
            calibrate = false;
          }

          calcTarget(accel);
          return true;
        })));

    return super.onLoad();
  }

  void calcTarget(Vector3 accel) {
    final calibrationNormal = this.calibrationNormal;
    if (calibrationNormal == null) {
      // print("skipping calc target, not calibrated");
      return;
    }

    if (accel.length > 1.2) {
      print("skipping calc target, length too big ${accel.length}");
      return;
    }

    const maxAngle = 90.0 * (pi / 180.0);
    final angle = accel.angleToSigned(calibrationNormal, Vector3(1, 0, 0));
    final worldRect = gameRef.size.toRect();

    final targetX = angle.remap(-pi, pi, worldRect.left, worldRect.right);
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
