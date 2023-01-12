import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pongsense/esense/device.dart';
import 'package:pongsense/flame/esense.dart';
import 'package:pongsense/game/ai_paddle.dart';
import 'package:pongsense/game/ball.dart';
import 'package:pongsense/game/blocker.dart';
import 'package:pongsense/game/player_health.dart';
import 'package:pongsense/game/player_paddle.dart';
import 'package:pongsense/game/player_score.dart';
import 'package:pongsense/globals/connection.dart' as g;
import 'package:pongsense/util/callback.dart';

const pauseOverlayIdentifier = "PauseOverlay";
const endOverlayIdentifier = "EndOverlay";

class PongGame extends FlameGame
    with
        HasTappables,
        HasCollisionDetection,
        HasKeyboardHandlerComponents,
        HasESenseHandlerComponents {
  // game loop
  double score = 0;
  int playerMaxHealth = 3;
  late int playerHealth = playerMaxHealth;

  // esense connection
  Closer? _stateCallbackCloser;
  Closer? _eventCallbackCloser;
  Closer? _sensorCallbackCloser;

  // angler connection
  Closer? _angleChangedCallbackCloser;

  // game components
  late final PlayerPaddle player;
  late final AIPaddle ai;
  late final List<Blocker> blockers;
  late final Ball ball;

  @override
  void onDetach() {
    _stateCallbackCloser?.call();
    _eventCallbackCloser?.call();
    _sensorCallbackCloser?.call();
    _angleChangedCallbackCloser?.call();
    FlameAudio.bgm.pause();
    super.onDetach();
  }

  @override
  void onAttach() {
    super.onAttach();

    _sensorCallbackCloser = g.device.registerSensorCallback((event) {
      onSensorEvent(event);
    });
    _eventCallbackCloser = g.device.registerEventCallback((event) {
      onESenseEvent(event);
    });
    _angleChangedCallbackCloser =
        g.angler.registerAngleChangedCallback((event) {
      onAnglerEvent(event);
    });

    FlameAudio.bgm.resume();
  }

  @override
  Future<void> onLoad() async {
    player = PlayerPaddle();
    ai = AIPaddle();
    ball = Ball();

    await FlameAudio.audioCache.loadAll([
      'sfx/8-bit-jump-sound.mp3',
      'sfx/8-bit-pong-sound.mp3',
      'sfx/8-bit-score-sound.mp3',
      'sfx/8-bit-crash-sound.mp3',
      'sfx/8-bit-death-sound.mp3',
      'bg/gaming-arcade-intro.mp3',
    ]);

    addAll([
      ScreenHitbox(),
      player,
      ai,
      ball,
      PlayerHealth(),
      PlayerScore(),
    ]);

    blockers = addBlockers(player, ai);
    addAll(blockers);

    FlameAudio.bgm.play("bg/gaming-arcade-intro.mp3", volume: 0.2);

    pause();
  }

  List<Blocker> addBlockers(PlayerPaddle player, AIPaddle ai) {
    const gridPadding = 10;
    const gridGap = 10;
    const rows = 2;
    final blockerSize = Vector2(30, 30);
    final aiBottom = ai.paddle.toAbsoluteRect().bottom;

    final cols =
        (size.x - (2 * gridPadding) + gridGap) ~/ (gridGap + blockerSize.x);
    final overHangX =
        (size.x - (2 * gridPadding) + gridGap) % (gridGap + blockerSize.x);

    List<Blocker> blockers = [];
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        blockers.add(Blocker()
          ..size = blockerSize
          ..maxLives = 3
          ..position = Vector2(
            (overHangX / 2) + gridPadding + (col * (gridGap + blockerSize.x)),
            aiBottom + gridPadding + ((gridGap + blockerSize.y) * row),
          ));
      }
    }

    return blockers;
  }

  void damagePlayer({int amount = 1}) {
    playerHealth = max(0, playerHealth - amount);
    // show end overlay if player died
    if (playerHealth == 0) {
      FlameAudio.play("sfx/8-bit-death-sound.mp3");
      pauseEngine();
      overlays.add(endOverlayIdentifier);
    }
  }

  void healPlayer({int amount = 1}) {
    playerHealth = min(playerHealth + amount, playerMaxHealth);
  }

  // resets all game elements and resumes the engine
  // expects to currently show the end overlay
  void reset() {
    score = 0;
    playerHealth = playerMaxHealth;
    for (var b in blockers) {
      b.reset();
      if (b.parent == null) {
        add(b);
      }
    }
    ball.reset();

    if (overlays.isActive(endOverlayIdentifier)) {
      overlays.remove(endOverlayIdentifier);
    }
    resumeEngine();
  }

  void pause() {
    if (!paused) {
      paused = true;
    }
    if (!overlays.isActive(pauseOverlayIdentifier)) {
      overlays.add(pauseOverlayIdentifier);
    }
  }

  void unpause() {
    if (paused) {
      paused = false;
    }
    if (overlays.isActive(pauseOverlayIdentifier)) {
      overlays.remove(pauseOverlayIdentifier);
    }
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
    pause();
  }
}
