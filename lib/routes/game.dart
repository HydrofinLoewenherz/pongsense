import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/game/pong_game.dart';
import 'package:pongsense/globals/connection.dart' as g;

class FrostedGlass extends BackdropFilter {
  FrostedGlass({super.key, super.child})
      : super(filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0));
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: g.game,
        initialActiveOverlays: const [pauseOverlayIdentifier],
        overlayBuilderMap: const {
          pauseOverlayIdentifier: _pauseMenuBuilder,
          endOverlayIdentifier: _endMenuBuilder,
          calibrateOverlayIdentifier: _calibrationMenuBuilder,
        },
      ),
    );
  }
}

Widget _endMenuBuilder(BuildContext buildContext, PongGame game) {
  return FrostedGlass(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'You Died!',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Score: ${game.score.floor()}',
            style: const TextStyle(color: Colors.white),
          ),
          ElevatedButton(
            onPressed: game.reset,
            child: const Text("Reset"),
          ),
        ],
      ),
    ),
  );
}

Widget _pauseMenuBuilder(BuildContext buildContext, PongGame game) {
  return FrostedGlass(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Paused',
            style: TextStyle(color: Colors.white),
          ),
          ElevatedButton(
            onPressed: game.togglePause,
            child: const Text("Continue"),
          ),
          ElevatedButton(
            onPressed: () {
              game.overlays.remove(pauseOverlayIdentifier);
              game.overlays.add(calibrateOverlayIdentifier);
            },
            child: const Text("Calibrate"),
          ),
        ],
      ),
    ),
  );
}

Widget _calibrationMenuBuilder(BuildContext buildContext, PongGame game) {
  final calibrateUp = game.upCalibration == null;

  return FrostedGlass(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            game.isCalibrated
                ? "Calibrated"
                : (calibrateUp ? "Calibrating 1/2" : "Calibrating 2/2"),
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            game.isCalibrated
                ? "You can now play the game"
                : (calibrateUp
                    ? "Hold your HEAD UPRIGHT"
                    : "LOOK DOWN in front of you"),
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            game.isCalibrated
                ? "have fun"
                : "and click the button on the EARABLE to calibrate.",
            style: TextStyle(color: Colors.white),
          ),
          ElevatedButton(
            onPressed: game.resetCalibration,
            child: const Text("Recalibrate"),
          ),
          ElevatedButton(
            onPressed: () {
              game.overlays.remove(calibrateOverlayIdentifier);
              game.overlays.add(pauseOverlayIdentifier);
            },
            child: const Text("Back"),
          ),
        ],
      ),
    ),
  );
}
