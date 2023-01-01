import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:pongsense/game/pong_game.dart';

void main() {
  runApp(GameContainer());
}

class GameContainer extends StatelessWidget {
  final FlameGame _game = PongGame();

  GameContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: GameWidget(game: _game),
    );
  }
}