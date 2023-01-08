import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/esense/angler.dart';
import 'package:pongsense/flame/esense.dart';
import 'package:pongsense/game/pong_game.dart';
import 'package:pongsense/math/remap.dart';

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

    add(ESenseListenerComponent(anglerCallback: (event) {
      calcTarget(event);
      return true;
    }));

    return super.onLoad();
  }

  void calcTarget(AnglerEvent event) {
    final worldRect = gameRef.size.toRect();
    final targetX = event.percent
        .remapAndClamp(0, 1, worldRect.left, worldRect.right - paddle.width);
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
